import {JSDOM} from 'jsdom'
import {saveYamlMarkdown} from '../utils/files'

type Filmaffinity = {
  cover?: string|null,
  url: string
}

type Movie = {
  'object-id': string,
  'serie-id': string,
  name?: string|null
  label?: string|null,
  director?: string|null
  year?: string|null,
  country?: string|null,
  cast?: string|null,
  synopsis?: string|null
  filmaffinity: Filmaffinity
}

class FilmaffinityPage {
  jsdom: Promise<JSDOM>

  constructor(url: string) {
    this.jsdom = JSDOM.fromURL(url)
  }

  async getTitle() {
    return (await this.jsdom).window.document.querySelector('#main-title')?.textContent?.trim()
  }

  async getDirector() {
    return (await this.jsdom).window.document.querySelector('.movie-info .directors')?.textContent?.trim()
  }

  async getYear() {
    return (await this.jsdom).window.document.querySelector('.movie-info dd[itemprop=datePublished]')?.textContent?.trim()
  }

  async getCountry() {
    const countries = [...(await this.jsdom).window.document.querySelectorAll('.movie-info #country-img img')]

    return countries.map(countryElement => countryElement.getAttribute('alt')).join(', ')
  }

  async getCast() {
    const document = (await this.jsdom).window.document
    let cast

    cast = document.querySelector('.movie-info .card-cast')?.textContent?.trim()

    if (!cast) {
      cast = ([...document.querySelectorAll('.movie-info .credits-scroller li:not(.see-more-cre)')]).map(actor => actor.textContent).join(', ')
    }

    return cast
  }

  async getSynopsis() {
    return (await this.jsdom).window.document.querySelector('.movie-info [itemprop=description]')?.textContent?.trim()
  }

  async getCover() {
    return (await this.jsdom).window.document.querySelector('#movie-main-image-container img')?.getAttribute('src')
  }
}

export async function create(
  filmaffinityUrl: string,
  serieId: string,
  editionYear: string,
): Promise<string> {
  const movie = await extract(filmaffinityUrl, serieId)

  return saveToDisk(movie, editionYear)
}

export async function extract(
  filmaffinityUrl: string,
  serieId: string,
): Promise<Movie> {
  const filmaffinityPage = new FilmaffinityPage(filmaffinityUrl)

  return {
    'object-id': filmaffinityUrl,
    'serie-id': serieId,
    name: await filmaffinityPage.getTitle(),
    label: await filmaffinityPage.getTitle(),
    director: await filmaffinityPage.getDirector(),
    year: await filmaffinityPage.getYear(),
    country: await filmaffinityPage.getCountry(),
    cast: await filmaffinityPage.getCast(),
    synopsis: await filmaffinityPage.getSynopsis(),
    filmaffinity: {
      cover: await filmaffinityPage.getCover(),
      url: filmaffinityUrl,
    },
  }
}

export async function saveToDisk(movie: Movie, editionYear: string): Promise<string> {
  const pathToSave = getPathForMovie(movie, editionYear)

  await saveYamlMarkdown(movie, pathToSave)

  return Promise.resolve(pathToSave)
}

function getPathForMovie(movie: Movie, editionYear: string) {
  const filename = movie.filmaffinity.url.split('/').pop()?.split('.')[0]

  return `_movies/${editionYear}/${filename}.md`
}
