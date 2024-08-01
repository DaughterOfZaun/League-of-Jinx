import { promises as fs } from 'fs'

let str = await fs.readFile('tools/files.list.txt', 'utf8')

str = str
.replace(/\..*?$/gm, '')
//.replace(/\/|\-|\_| |\d+|'/g, '\n')
.replace(/[^a-zA-Z]/g, '\n')
.replace(/([a-z])([A-Z])/g, '$1\n$2')
.replace(/([A-Z])([A-Z][a-z])/g, '$1\n$2')
.toLowerCase()

str = [...new Set(str.split('\n'))].join('\n')

await fs.writeFile('tools/files.words.txt', str, 'utf8')