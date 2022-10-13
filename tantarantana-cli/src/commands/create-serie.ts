import {Command, CliUx} from '@oclif/core'
import {build as buildSerie, saveToDisk as saveSerieToDisk} from '../tasks/serie'
import {create as createMovie} from '../tasks/movie'

export class CreateSerie extends Command {
  async run(): Promise<void> {
    const memberId = await CliUx.ux.prompt('Jury member ID (example: member_oliver)', {required: true})
    const year = await CliUx.ux.prompt('Year (example: 2021)', {required: true})
    const label = await CliUx.ux.prompt('Label (example: Febrero) ', {required: true})
    const name = await CliUx.ux.prompt('Name (example: Profesiones no tan comunes)', {required: true})
    const description = await CliUx.ux.prompt('Description (example: Profesiones no tan comunes)', {required: true})
    const movies: string = await CliUx.ux.prompt('Filmaffinity URLs separated by commas', {required: true})

    if (await CliUx.ux.confirm('Create serie?')) {
      const serie = buildSerie(
        memberId,
        year,
        label,
        name,
        description,
        movies.split(',').map(movieUrl => movieUrl.trim()),
      )

      const progressBar = CliUx.ux.progress()

      progressBar.start(serie.movies.length, 0)

      for (const movie of serie.movies) {
        console.log(`Creating movie ${movie['movie-id']}`)

        // eslint-disable-next-line no-await-in-loop
        await createMovie(
          movie['movie-id'],
          serie['object-id'],
          year,
        )

        progressBar.increment()
      }

      progressBar.stop()

      console.log('Movies created!')

      console.log('Creating serie...')

      const savedPath = await saveSerieToDisk(serie, year)

      console.log(`Created ${savedPath}`)
    } else {
      console.log('Abort')
    }
  }
}
