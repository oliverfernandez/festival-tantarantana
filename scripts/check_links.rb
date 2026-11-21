#!/usr/bin/env ruby
# Cross-reference checker for the Tantarantana Jekyll collections.
# Usage (from the repo root): ruby scripts/check_links.rb
# Exits 1 if any reference between members, editions, series, movies and awards is broken.
require 'yaml'
require 'date'

ROOT = ARGV[0] || '.'
$errors = []
$warnings = []

def rel(path); path.sub("#{ROOT}/", ''); end
def err(file, msg); $errors   << "#{rel(file)}: #{msg}"; end
def warn(file, msg); $warnings << "#{rel(file)}: #{msg}"; end

def load_collection(dir)
  Dir.glob(File.join(ROOT, dir, '**', '*.md')).sort.map do |f|
    text = File.read(f)
    m = text.match(/\A---\s*\n(.*?)\n---/m)
    unless m
      err(f, 'no front matter found')
      next
    end
    data = YAML.safe_load(m[1], permitted_classes: [Date]) || {}
    [f, data]
  rescue Psych::Exception => e
    err(f, "invalid YAML: #{e.message.lines.first.strip}")
    nil
  end.compact
end

def blank?(v); v.nil? || v.to_s.strip.empty?; end

cols = {
  members:  load_collection('_members'),
  editions: load_collection('_editions'),
  series:   load_collection('_series'),
  movies:   load_collection('_movies'),
  awards:   load_collection('_awards'),
}

ids = {}
cols.each do |name, docs|
  ids[name] = {}
  docs.each do |f, d|
    oid = d['object-id']
    if blank?(oid)
      err(f, 'missing object-id')
      next
    end
    if ids[name][oid]
      # Same film in two editions is legitimate only if the files are separate copies; Jekyll's `where | first` picks one.
      err(f, "duplicate object-id #{oid} (also in #{rel(ids[name][oid])})")
    else
      ids[name][oid] = f
    end
  end
end

def suggest(id, pool)
  return '' if blank?(id)
  s = id.to_s
  cands = pool.keys.select { |k| k.start_with?(s) || s.start_with?(k) || k.downcase == s.downcase }
  cands.empty? ? '' : " (did you mean #{cands.join(' / ')}?)"
end

def check_ref(file, kind, value, pool, where)
  return if blank?(value)
  v = value.to_s
  if v != v.strip
    err(file, "#{where}: #{kind} #{v.inspect} has surrounding whitespace")
    v = v.strip
  end
  err(file, "#{where}: unknown #{kind} #{v}#{suggest(v, pool)}") unless pool.key?(v)
end

# ---------- editions ----------
serie_in_edition = Hash.new { |h, k| h[k] = [] }
cols[:editions].each do |f, d|
  Array(d['presidents-id']).each { |m| check_ref(f, 'member', m, ids[:members], 'presidents-id') }
  Array(d['series']).each do |s|
    check_ref(f, 'serie', s['serie-id'], ids[:series], 'series')
    serie_in_edition[s['serie-id']] << d['object-id']
  end
  Array(d['members']).each { |m| check_ref(f, 'member', m['member-id'], ids[:members], 'members') }
  Array(d['awards']).each do |a|
    check_ref(f, 'award', a['award-id'], ids[:awards], 'awards')
    %w[winners finalists].each do |k|
      Array(a[k]).each { |mv| check_ref(f, 'movie', mv['movie-id'], ids[:movies], "awards #{a['award-id']} #{k}") }
    end
  end
end

# ---------- series ----------
edition_members = cols[:editions].to_h { |_, d| [d['object-id'], Array(d['members']).map { |m| m['member-id'] }] }
serie_movies = {}
cols[:series].each do |f, d|
  sid = d['object-id']
  check_ref(f, 'edition', d['edition-id'], ids[:editions], 'edition-id')
  check_ref(f, 'member', d['member-id'], ids[:members], 'member-id')
  eds = serie_in_edition[sid]
  if eds.empty?
    warn(f, "serie #{sid} is not listed in any edition's series: (page is built but not linked from the edition)")
  elsif !blank?(d['edition-id']) && !eds.include?(d['edition-id'])
    err(f, "edition-id #{d['edition-id']} but listed in #{eds.join(', ')}")
  end
  serie_movies[sid] = {}
  Array(d['movies']).each do |mv|
    mid = mv['movie-id']
    check_ref(f, 'movie', mid, ids[:movies], 'movies')
    check_ref(f, 'member', mv['member-id'], ids[:members], "movies #{mid}")
    warn(f, "movie #{mid} listed twice") if !blank?(mid) && serie_movies[sid].key?(mid)
    serie_movies[sid][mid] = mv['member-id']
    member = blank?(mv['member-id']) ? d['member-id'] : mv['member-id']
    em = edition_members[d['edition-id']]
    if !blank?(member) && em && !em.empty? && ids[:members].key?(member) && !em.include?(member)
      warn(f, "movie #{mid}: member #{member} is not in #{d['edition-id']}'s members list")
    end
  end
end

# ---------- movies ----------
cols[:movies].each do |f, d|
  mid = d['object-id']
  sids = d['serie-ids'] ? Array(d['serie-ids']) : [d['serie-id']]
  err(f, 'no serie-id / serie-ids') if sids.all? { |s| blank?(s) }
  sids.each do |sid|
    next if blank?(sid)
    check_ref(f, 'serie', sid, ids[:series], 'serie-id')
    next unless serie_movies.key?(sid)
    unless serie_movies[sid].key?(mid)
      err(f, "serie #{sid} does not list this movie in its movies:")
      next
    end
    # The movie file's own member-id is not used by the layouts, but keep it in sync with the serie entry.
    sm = serie_movies[sid][mid]
    if !blank?(d['member-id']) && !blank?(sm) && d['member-id'] != sm
      err(f, "member-id #{d['member-id']} differs from #{sid} entry (#{sm})")
    end
  end
  check_ref(f, 'member', d['member-id'], ids[:members], 'member-id')
  if !blank?(mid) && d.dig('filmaffinity', 'url') && d['filmaffinity']['url'] != mid
    err(f, "object-id #{mid} differs from filmaffinity.url #{d['filmaffinity']['url']}")
  end
  if !blank?(mid) && mid =~ /film(\d+)\.html/ && File.basename(f, '.md') != "film#{$1}"
    warn(f, "filename does not match object-id #{mid}")
  end
end

# Movies listed in a serie whose movie file points to a different serie.
movie_series = cols[:movies].to_h { |_, d| [d['object-id'], d['serie-ids'] ? Array(d['serie-ids']) : [d['serie-id']]] }
cols[:series].each do |f, d|
  Array(d['movies']).each do |mv|
    ms = movie_series[mv['movie-id']]
    next unless ms
    unless ms.include?(d['object-id'])
      err(f, "lists #{mv['movie-id']} but that movie file has serie-id #{ms.compact.join(', ')} (its page won't show this serie)")
    end
  end
end

# ---------- member photos (used by edition/index/metadata templates) ----------
ids[:members].each do |mid, f|
  warn(f, "no photo assets/images/members/#{mid}.jpg") unless File.exist?(File.join(ROOT, 'assets/images/members', "#{mid}.jpg"))
end

puts "ERRORS (#{$errors.size})"
$errors.each { |e| puts "  #{e}" }
puts
puts "WARNINGS (#{$warnings.size})"
$warnings.each { |w| puts "  #{w}" }
exit($errors.empty? ? 0 : 1)
