// eslint-disable-next-line unicorn/prefer-node-protocol
import * as fs from 'fs/promises'
import {Document} from 'yaml'

export async function saveYamlMarkdown(obj: unknown, path: string): Promise<void> {
  const yaml = new Document(obj).toString()
  const markdown = `---\n${yaml}---`

  await fs.writeFile(path, markdown)
}
