import puppeteer, {Page} from 'puppeteer'
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
  'member-id': string
}

class FilmaffinityPage {
  private pagePromise: Promise<Page>
  private url: string

  constructor(url: string) {
    this.url = url
    this.pagePromise = this.loadPage()
  }

  private async loadPage(): Promise<Page> {
    const browser = await puppeteer.launch({headless: true})
    const page = await browser.newPage()

    // Disable JavaScript - content is server-rendered
    await page.setJavaScriptEnabled(false)

    // Block unnecessary resources for faster loading
    await page.setRequestInterception(true)
    page.on('request', request => {
      const resourceType = request.resourceType()
      if (['image', 'stylesheet', 'font', 'media', 'script'].includes(resourceType)) {
        request.abort()
      } else {
        request.continue()
      }
    })

    await page.setUserAgent('Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36')
    await page.setExtraHTTPHeaders({
      'Accept-Language': 'es-ES,es;q=0.9,en;q=0.8',
    })

    await page.goto(this.url, {waitUntil: 'domcontentloaded', timeout: 15_000})

    return page
  }

  async getTitle(): Promise<string | null> {
    const page = await this.pagePromise
    return page.$eval('#main-title', (el: Element) => el.textContent?.trim() ?? null).catch(() => null)
  }

  async getDirector(): Promise<string | null> {
    const page = await this.pagePromise
    return page.$eval('.movie-info .directors', (el: Element) => el.textContent?.trim() ?? null).catch(() => null)
  }

  async getYear(): Promise<string | null> {
    const page = await this.pagePromise
    return page.$eval('.movie-info dd[itemprop=datePublished]', (el: Element) => el.textContent?.trim() ?? null).catch(() => null)
  }

  async getCountry(): Promise<string | null> {
    const page = await this.pagePromise
    return page.$$eval('.movie-info #country-img img', (elements: Element[]) =>
      elements.map((el: Element) => el.getAttribute('alt')).filter(Boolean).join(', ') || null,
    ).catch(() => null)
  }

  async getCast(): Promise<string | null> {
    const page = await this.pagePromise

    let cast = await page.$eval('.movie-info .card-cast', (el: Element) => el.textContent?.trim() ?? null).catch(() => null)

    if (!cast) {
      cast = await page.$$eval('.movie-info .credits-scroller li:not(.see-more-cre)', (elements: Element[]) =>
        elements.map((el: Element) => el.textContent?.trim()).filter(Boolean).join(', ') || null,
      ).catch(() => null)
    }

    return cast
  }

  async getSynopsis(): Promise<string | null> {
    const page = await this.pagePromise
    return page.$eval('.movie-info [itemprop=description]', (el: Element) => el.textContent?.trim() ?? null).catch(() => null)
  }

  async getCover(): Promise<string | null> {
    const page = await this.pagePromise
    return page.$eval('#movie-main-image-container img', (el: Element) => el.getAttribute('src')).catch(() => null)
  }

  async close(): Promise<void> {
    const page = await this.pagePromise
    await page.browser().close()
  }
}

export async function create(
  filmaffinityUrl: string,
  serieId: string,
  editionYear: string,
  memberId: string,
): Promise<string> {
  const movie = await extract(filmaffinityUrl, serieId, memberId)

  return saveToDisk(movie, editionYear)
}

export async function extract(
  filmaffinityUrl: string,
  serieId: string,
  memberId: string,
): Promise<Movie> {
  const filmaffinityPage = new FilmaffinityPage(filmaffinityUrl)

  try {
    return {
      'object-id': filmaffinityUrl,
      'serie-id': serieId,
      'member-id': memberId,
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
  } finally {
    await filmaffinityPage.close()
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
