import {saveYamlMarkdown} from '../utils/files'

type MovieSerie = {
  'movie-id': string
}

export type Serie = {
  'object-id': string,
  'edition-id': string,
  label: string,
  'member-id': string,
  name: string,
  description: string,
  movies: MovieSerie[]
}

// eslint-disable-next-line max-params
export function build(
  memberId: string,
  year: string,
  label: string,
  name: string,
  description: string,
  movies: string[],
): Serie {
  return {
    'object-id': `serie_${year}_${getHumanReadableId(label)}`,
    'edition-id': `edition_${year}`,
    label,
    'member-id': memberId,
    name,
    description,
    movies: movies.map(movie => ({'movie-id': movie})),
  }
}

export async function saveToDisk(serie: Serie, year: string): Promise<string> {
  const pathToSave = getPathForSerie(serie, year)

  await saveYamlMarkdown(serie, pathToSave)

  return Promise.resolve(pathToSave)
}

function getPathForSerie(serie: Serie, year: string): string {
  return `_series/${year}/${getHumanReadableId(serie.label)}.md`
}

function getHumanReadableId(label: string): string {
  return label.trim().toLowerCase().replace(/\s+/g, '_')
}
