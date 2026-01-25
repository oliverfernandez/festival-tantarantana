import {Command} from '@oclif/core'
import {create as createMovie} from '../tasks/movie'

export class ExtractMovie extends Command {
  static args = [
    {
      name: 'filmaffinityUrl',
      required: true,
    },
    {
      name: 'serieId',
      required: true,
    },
    {
      name: 'editionYear',
      required: true,
    },
    {
      name: 'memberId',
      required: true,
    },
  ]

  async run(): Promise<void> {
    const {args} = await this.parse(ExtractMovie)

    const movieSavedPath = await createMovie(
      args.filmaffinityUrl,
      args.serieId,
      args.editionYear,
      args.memberId,
    )

    console.log(`Created ${movieSavedPath}`)
  }
}
