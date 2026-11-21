// eslint-disable-next-line unicorn/prefer-node-protocol
import * as https from 'https'
// eslint-disable-next-line unicorn/prefer-node-protocol
import {readFileSync} from 'fs'
// eslint-disable-next-line unicorn/prefer-node-protocol
import {homedir} from 'os'

const POSTER_BASE = 'https://image.tmdb.org/t/p/w342'
const KEY_FILE = `${homedir()}/.config/tantarantana/tmdb_key`

export type Tmdb = {
  poster: string
}

function readApiKey(): string | null {
  if (process.env.TMDB_API_KEY) return process.env.TMDB_API_KEY.trim()
  try {
    return readFileSync(KEY_FILE, 'utf8').trim() || null
  } catch {
    return null
  }
}

function getJson(url: string, headers: Record<string, string> = {}): Promise<any> {
  return new Promise((resolve, reject) => {
    https.get(url, {headers}, res => {
      let body = ''
      res.on('data', chunk => {
        body += chunk
      })
      res.on('end', () => {
        if (res.statusCode === 404) return resolve(null)
        if (!res.statusCode || res.statusCode >= 400) return reject(new Error(`GET ${new URL(url).host} -> ${res.statusCode}`))
        resolve(JSON.parse(body))
      })
    }).on('error', reject)
  })
}

function tmdbGet(apiKey: string, path: string, params: Record<string, string> = {}): Promise<any> {
  const headers: Record<string, string> = {Accept: 'application/json'}
  const query = new URLSearchParams(params)
  if (apiKey.startsWith('eyJ')) {
    headers.Authorization = `Bearer ${apiKey}` // v4 read access token
  } else {
    query.set('api_key', apiKey) // v3 API key
  }

  return getJson(`https://api.themoviedb.org/3${path}?${query}`, headers)
}

async function tmdbIdFromWikidata(filmaffinityId: string): Promise<string | null> {
  const query = `SELECT ?tmdb WHERE { ?f wdt:P480 "${filmaffinityId}" ; wdt:P4947 ?tmdb } LIMIT 1`
  const url = `https://query.wikidata.org/sparql?${new URLSearchParams({query, format: 'json'})}`
  const data = await getJson(url, {'User-Agent': 'tantarantana-cli/1.0', Accept: 'application/sparql-results+json'})
  return data?.results?.bindings?.[0]?.tmdb?.value ?? null
}

const normalize = (s: string) => s.normalize('NFKD').replace(/[^\u0000-\u007F]/g, '').toLowerCase().replace(/[^a-z]/g, '')

// Search by title (+ year) and only accept a result whose director matches FilmAffinity's.
async function tmdbIdFromSearch(apiKey: string, titles: string[], year: string | null, directors: string | null): Promise<string | null> {
  const wanted = (directors ?? '').split(',').map(d => normalize(d)).filter(Boolean)
  if (wanted.length === 0) return null

  for (const title of titles) {
    for (const y of [year, null]) {
      const params: Record<string, string> = {query: title, language: 'es-ES'}
      if (y) params.year = y
      // eslint-disable-next-line no-await-in-loop
      const results: any[] = (await tmdbGet(apiKey, '/search/movie', params))?.results ?? []
      for (const result of results.slice(0, 5)) {
        // eslint-disable-next-line no-await-in-loop
        const credits = await tmdbGet(apiKey, `/movie/${result.id}/credits`)
        const got = (credits?.crew ?? []).filter((c: any) => c.job === 'Director').map((c: any) => normalize(c.name))
        if (got.some((d: string) => wanted.includes(d))) return String(result.id)
      }
    }
  }

  return null
}

export async function findTmdb(
  filmaffinityUrl: string,
  titles: Array<string | null>,
  year: string | null,
  directors: string | null,
): Promise<Tmdb | null> {
  const apiKey = readApiKey()
  if (!apiKey) {
    console.warn(`TMDB_API_KEY not set (nor ${KEY_FILE}): skipping tmdb poster`)
    return null
  }

  const filmaffinityId = filmaffinityUrl.match(/film(\d+)\.html/)?.[1]
  let tmdbId = filmaffinityId ? await tmdbIdFromWikidata(filmaffinityId).catch(() => null) : null
  if (!tmdbId) {
    // FilmAffinity adds alternative titles in parentheses, e.g. "Shichinin no Samurai (Seven Samurai)".
    const variants = titles.filter((t): t is string => Boolean(t)).flatMap(t => [t, t.replace(/\s*\(.*?\)\s*/g, ' ').trim()])
    const uniqueTitles = [...new Set(variants.filter(Boolean))]
    tmdbId = await tmdbIdFromSearch(apiKey, uniqueTitles, year, directors)
  }

  if (!tmdbId) {
    console.warn('No TMDB match found: skipping tmdb poster')
    return null
  }

  // language=es-ES returns the Spanish poster when TMDB has one, otherwise the default poster.
  const movie = await tmdbGet(apiKey, `/movie/${tmdbId}`, {language: 'es-ES'})
  if (!movie?.poster_path) {
    console.warn(`TMDB movie ${tmdbId} has no poster: skipping tmdb poster`)
    return null
  }

  return {poster: `${POSTER_BASE}${movie.poster_path}`}
}
