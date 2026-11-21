#!/usr/bin/env ruby
# Adds a `tmdb.poster` attribute to every movie in _movies that doesn't have one yet,
# and replaces the hotlinked FilmAffinity posters in 67th-ciff.md.
#
# FilmAffinity id -> TMDB id comes from Wikidata (P480 -> P4947); movies missing there are
# searched on TMDB by title + year and only accepted when the director matches.
#
# Usage (from the repo root):
#   TMDB_API_KEY=... ruby scripts/add_tmdb_posters.rb [--dry-run]
# The key can also be stored in ~/.config/tantarantana/tmdb_key.
# Accepts either a TMDB v3 API key or a v4 read access token.
require 'net/http'
require 'json'
require 'uri'

DRY_RUN = ARGV.include?('--dry-run')
POSTER_BASE = 'https://image.tmdb.org/t/p/w342'
CIFF_PAGE = '67th-ciff.md'

KEY = (ENV['TMDB_API_KEY'] || begin
  File.read(File.expand_path('~/.config/tantarantana/tmdb_key'))
rescue Errno::ENOENT
  nil
end).to_s.strip
abort 'Missing TMDB_API_KEY (or ~/.config/tantarantana/tmdb_key)' if KEY.empty?

def http_get_json(url, headers = {})
  uri = URI(url)
  5.times do |attempt|
    req = Net::HTTP::Get.new(uri)
    headers.each { |k, v| req[k] = v }
    begin
      res = Net::HTTP.start(uri.host, uri.port, use_ssl: true, open_timeout: 15, read_timeout: 60) { |h| h.request(req) }
    rescue Net::OpenTimeout, Net::ReadTimeout, Errno::ECONNRESET, Errno::ECONNREFUSED, SocketError, OpenSSL::SSL::SSLError
      sleep(2**attempt)
      next
    end
    return JSON.parse(res.body) if res.is_a?(Net::HTTPSuccess)
    return nil if res.code == '404'
    if res.code == '429' || res.code.start_with?('5')
      sleep(2**attempt)
      next
    end
    raise "GET #{uri.host}#{uri.path} -> #{res.code}"
  end
  raise "GET #{uri.host}#{uri.path} failed after retries"
end

def tmdb(path, params = {})
  headers = { 'Accept' => 'application/json' }
  if KEY.start_with?('eyJ')
    headers['Authorization'] = "Bearer #{KEY}"
  else
    params = params.merge(api_key: KEY)
  end
  sleep 0.03 # stay well below TMDB's rate limit
  http_get_json("https://api.themoviedb.org/3#{path}?#{URI.encode_www_form(params)}", headers)
end

def wikidata_tmdb_ids(fa_ids)
  result = {}
  fa_ids.each_slice(300) do |slice|
    values = slice.map { |id| "\"#{id}\"" }.join(' ')
    query = "SELECT ?fa (SAMPLE(?tmdb) AS ?t) WHERE { VALUES ?fa { #{values} } ?f wdt:P480 ?fa ; wdt:P4947 ?tmdb } GROUP BY ?fa"
    url = "https://query.wikidata.org/sparql?#{URI.encode_www_form(query: query, format: 'json')}"
    data = http_get_json(url, 'User-Agent' => 'tantarantana-poster-backfill/1.0', 'Accept' => 'application/sparql-results+json')
    data['results']['bindings'].each { |b| result[b['fa']['value']] = b['t']['value'] }
  end
  result
end

def normalize(s)
  s.to_s.unicode_normalize(:nfkd).gsub(/[^\x00-\x7F]/, '').downcase.gsub(/[^a-z]/, '')
end

# Fallback for movies not on Wikidata: search by title + year, accept only if a director matches.
def search_tmdb_id(name, year, directors)
  return nil if name.to_s.empty?
  wanted = directors.to_s.split(',').map { |d| normalize(d) }.reject(&:empty?)
  return nil if wanted.empty?
  # FilmAffinity adds suffixes such as "(TV)" or alternative titles in parentheses.
  [name, name.gsub(/\s*\(.*?\)\s*/, ' ').strip].uniq.reject(&:empty?).each do |title|
    [year, nil].uniq.each do |y|
      params = { query: title, language: 'es-ES' }
      params[:year] = y if y
      results = (tmdb('/search/movie', params) || {})['results'] || []
      results.first(5).each do |r|
        crew = (tmdb("/movie/#{r['id']}/credits") || {})['crew'] || []
        got = crew.select { |c| c['job'] == 'Director' }.map { |c| normalize(c['name']) }
        return r['id'].to_s if (got & wanted).any?
      end
    end
  end
  nil
end

# 67th-ciff.md has no director: take the first result released in the festival years (2021-2022), to be reviewed.
def search_ciff_tmdb_id(name)
  results = (tmdb('/search/movie', query: name) || {})['results'] || []
  r = results.find { |x| %w[2021 2022].include?(x['release_date'].to_s[0, 4]) }
  r && r['id'].to_s
end

# Manual matches for titles that Wikidata and the movie search can't resolve (FilmAffinity id => TMDB "type/id").
# TV episodes use their series poster.
OVERRIDES = {
  '287852' => 'tv/19885',    # Sherlock: Estudio en rosa (TV)
  '428557' => 'tv/42009',    # Black Mirror: San Junipero (TV)
  '992177' => 'tv/42009',    # Black Mirror: Blanca Navidad (TV)
  '566155' => 'tv/74577',    # The End of the F***ing World (Serie de TV)
  '769447' => 'tv/86449',    # El mundo conectado / Welt am Draht (TV)
  '425154' => 'movie/997519', # Arnold Is a Model Student (67th-ciff.md, released 2023)
  '637119' => 'movie/807420', # Ballywalter (67th-ciff.md, released 2023)
}.freeze

$tmdb_years = {}
def poster_url(tmdb_id)
  type, id = tmdb_id.include?('/') ? tmdb_id.split('/') : ['movie', tmdb_id]
  # language=es-ES returns the Spanish poster when TMDB has one, otherwise the default poster.
  movie = tmdb("/#{type}/#{id}", language: 'es-ES')
  $tmdb_years[tmdb_id] = movie && (movie['release_date'] || movie['first_air_date']).to_s[0, 4]
  path = movie && movie['poster_path']
  path ? "#{POSTER_BASE}#{path}" : nil
end

def front_matter_value(text, key)
  text[/^#{key}: *"?(.*?)"?\s*$/, 1]
end

# ---------- collect ----------
movies = Dir.glob('_movies/**/*.md').sort.map do |f|
  text = File.read(f)
  next if text =~ /^tmdb:/
  fa_id = text[%r{^object-id: https://www\.filmaffinity\.com/\w+/film(\d+)\.html}, 1]
  next warn("skip #{f}: no FilmAffinity object-id") unless fa_id
  { file: f, fa: fa_id, name: front_matter_value(text, 'name'), year: front_matter_value(text, 'year'),
    director: front_matter_value(text, 'director') }
end.compact

ciff_text = File.read(CIFF_PAGE)
ciff = ciff_text.scan(%r{^## \[(.*?)\]\(https://www\.filmaffinity\.com/\w+/film(\d+)\.html\)\s*\n\s*<img class="ciff-cover" src="(https://pics\.filmaffinity\.com/[^"]+)"}m)
                .map { |name, fa, src| { name: name, fa: fa, src: src } }

puts "Movies without tmdb: #{movies.size}, #{CIFF_PAGE} posters: #{ciff.size}"

fa_ids = (movies.map { |m| m[:fa] } + ciff.map { |c| c[:fa] }).uniq
tmdb_ids = wikidata_tmdb_ids(fa_ids)
puts "Wikidata matched #{tmdb_ids.size} of #{fa_ids.size} FilmAffinity ids"
tmdb_ids.merge!(OVERRIDES.select { |fa, _| fa_ids.include?(fa) })

searched = []
movies.each do |m|
  next if tmdb_ids[m[:fa]]
  id = search_tmdb_id(m[:name], m[:year], m[:director])
  if id
    tmdb_ids[m[:fa]] = id
    searched << "#{m[:file]}: #{m[:name]} (#{m[:year]}, #{m[:director]}) -> https://www.themoviedb.org/movie/#{id}"
  end
end

ciff.each do |c|
  next if tmdb_ids[c[:fa]]
  id = search_ciff_tmdb_id(c[:name])
  next unless id
  tmdb_ids[c[:fa]] = id
  searched << "#{CIFF_PAGE}: #{c[:name]} -> https://www.themoviedb.org/movie/#{id}"
end

# ---------- apply ----------
posters = {}
poster_for = ->(fa) { tmdb_ids[fa] && (posters.key?(fa) ? posters[fa] : (posters[fa] = poster_url(tmdb_ids[fa]))) }

missing = []
year_mismatch = []
updated = 0
movies.each do |m|
  url = poster_for.call(m[:fa])
  unless url
    missing << "#{m[:file]}: #{m[:name]} (#{m[:year]}, #{m[:director]})#{tmdb_ids[m[:fa]] ? " tmdb #{tmdb_ids[m[:fa]]} has no poster" : ''}"
    next
  end
  ty = $tmdb_years[tmdb_ids[m[:fa]]].to_i
  if !OVERRIDES.key?(m[:fa]) && ty > 0 && m[:year].to_i > 0 && (ty - m[:year].to_i).abs > 1
    year_mismatch << "#{m[:file]}: #{m[:name]} (#{m[:year]}) -> https://www.themoviedb.org/movie/#{tmdb_ids[m[:fa]]} (#{ty})"
  end
  text = File.read(m[:file])
  # Insert the block right before the closing --- of the front matter, keeping the rest untouched.
  new_text = text.sub(/\A(---\s*\n.*?\n)(---)/m) { "#{$1}tmdb:\n  poster: #{url}\n#{$2}" }
  next warn("could not place tmdb block in #{m[:file]}") if new_text == text
  File.write(m[:file], new_text) unless DRY_RUN
  updated += 1
end

ciff_missing = []
ciff.each do |c|
  url = poster_for.call(c[:fa])
  next ciff_missing << "#{CIFF_PAGE}: #{c[:name]} (film#{c[:fa]})" unless url
  ciff_text = ciff_text.sub(c[:src], url)
end
File.write(CIFF_PAGE, ciff_text) unless DRY_RUN

puts "#{DRY_RUN ? 'Would update' : 'Updated'} #{updated} movies and #{ciff.size - ciff_missing.size} #{CIFF_PAGE} posters"
unless searched.empty?
  puts "\nMatched by TMDB search (director verified) — please review:"
  searched.each { |s| puts "  #{s}" }
end
unless year_mismatch.empty?
  puts "\nYear differs by more than 1 between FilmAffinity and TMDB — please review:"
  year_mismatch.each { |s| puts "  #{s}" }
end
unless (missing + ciff_missing).empty?
  puts "\nNo TMDB poster found:"
  (missing + ciff_missing).each { |s| puts "  #{s}" }
end
