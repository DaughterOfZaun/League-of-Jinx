import { promises as fs } from 'fs'
import { argv } from 'process'
import path from 'path'

//@ts-ignore
import { csDir, iniDir, troyDir, binDir } from './paths.mjs'

async function* walk(dir: string): any {
    for await (const d of await fs.opendir(dir)) {
        const entry = path.join(dir, d.name);
        if (d.isDirectory()) yield* await walk(entry);
        else if (d.isFile()) yield entry;
    }
}

console.log('Building a file list...')

class File {
    isItem = false
    usedBy: Set<File> = new Set()
    uses: Set<File> = new Set()
    content: undefined|string[] = undefined
    contentStr: undefined|string = undefined
    saved = false
    path: string
    name: string
    ext: string
    constructor(p: string, n: string, e: string){
        this.path = p
        this.name = n
        this.ext = e.substring(1)
    }
    use(f: File){
        this.uses.add(f)
        f.usedBy.add(this)
    }
}

type Files = { [key: string]: File }

const iniFiles: Files = {}
const binFiles: Files = {}
const troyFiles: Files = {}
const csFiles: Files = {}
const csNames: Files = {}

const t2ns: {
    [key: string]: string
} = {
    'Buff': 'Buffs',
    'Spell': 'Spells',
    'Item': 'ItemPassives',
    'Talent': 'Talents',
    'Char': 'CharScripts',
}

const pushTo = (a: Files, n: string, f: File) => {
    //if(n in a) console.log('Collision for', n, 'between', f.path, 'and', a[n].path)
    a[n] = f
}

for await (let p of walk(csDir)){
    let op = p; p = p.replace(csDir, '').toLowerCase(); let n = path.basename(p); let e = path.extname(n)

    if(e != '.cs') continue
    n = n.replace('.cs', '')

    let f = new File(op, n, e)
    let c = (await fs.readFile(op, 'utf8'))
    f.content = c.split(/\b/g)
    f.contentStr = c.toLowerCase()

    let ms = c.matchAll(/class (\w+) ?: ?(Buff|Spell|Item|Talent|Char)Script/g)
    for(let [m, name, parent] of ms){
        m = t2ns[parent] + '.' + name
        pushTo(csNames, m, f)
    }
    pushTo(csFiles, n, f)
}

const getIniContent = async (op: string) => {
    return (await fs.readFile(op, 'utf8')).split('\n').reduce<string[]>((a, l) => {
        let p = l.split('=')
        if(p.length == 2 && !/Spell(\d+)DisplayName/.test(p[0]))
            a.push(p[1].trim().replace(/^"(.*)"$/, '$1').trim().toLowerCase())
        return a
    }, [])
}

for await (let p of walk(iniDir)){
    let op = p; p = p.replace(iniDir, '').toLowerCase(); let n = path.basename(p); let e = path.extname(n)

    if(e != '.ini') continue
    n = n.replace('.inibin.ini', '.ini')
    n = n.replace('.ini', '') // Nobody uses .ini

    let f = new File(op, n, e)
    f.content = await getIniContent(op)
    f.isItem = /^\d+$/.test(n)

    //TODO: Name and AlternateName?

    var csf = csFiles[n] || csFiles['charscript' + n]
    if(csf) f.use(csf)
    //else console.log('No matching CS file found for', op)

    pushTo(iniFiles, n, f) //WARN: False positives
}

for await (let p of walk(troyDir)){
    let op = p; p = p.replace(troyDir, '').toLowerCase(); let n = path.basename(p); let e = path.extname(n)

    if(e != '.troy') continue
    n = n.replace('.troybin.troy', '.troy')
    n = n.replace('.troy', '')

    let f = new File(op, n, e)
    f.content = await getIniContent(op)

    pushTo(troyFiles, n, f)
}

for await (let p of walk(binDir)){
    let op = p; p = p.replace(binDir, '').toLowerCase(); let n = path.basename(p); let e = path.extname(n)

    if(!['.anm', '.tga', '.dds', '.skn', '.skl', '.sco', '.scb'].includes(e)) continue
    //n = n.replace('.dds', '.tga').replace('.scb', '.sco')
    n = n.substring(0, n.length - 4)

    let f = new File(op, n, e)

    pushTo(binFiles, n, f)
}

console.log('Matching...')

const logProcess = (i: number, v: any[], t: string, sm: number) => {
    if(i % 100 == 0){
        console.log('Progress', i, t, 'of', v.length, '(', (i / v.length * 100).toFixed(2), ')', sm)
    }
}

let sm = 0
const simpleMatch = (f: File, k: string, u: File) => {
    if(u.isItem || f === u) return;
    if(f.content && f.content.indexOf(k) !== -1){
        f.use(u); sm++
    }
}
const heavyMatch = (f: File, k1: string, u: File, k2: string) => {
    let t = 0
    if(u.isItem || f === u) return;
    while((t = f.content!.indexOf(k1, t)) !== -1){
        if(k2 === undefined || (f.content![t + 1] === '.' && f.content![t + 2] === k2)){
            f.use(u); sm++
        }
        t++
    }
}

let i = 0
let v = Object.values(iniFiles)

let ini_kv = Object.entries(iniFiles)
let troy_bin_kv = Object.entries(troyFiles).concat(Object.entries(binFiles))
for(let f of v){
    logProcess(i++, v, 'ini', sm)
    if(f.content == undefined) continue
    for(let [k, u] of ini_kv)
        simpleMatch(f, k, u)
    for(let [k, u] of troy_bin_kv)
        simpleMatch(f, `${k}.${u.ext}`, u)
}

i = 0
sm = 0
v = Object.values(troyFiles)
let bin_kv = Object.entries(binFiles)
for(let f of v){
    logProcess(i++, v, 'troy', sm)
    if(f.content == undefined) continue
    for(let [k, u] of bin_kv)
        simpleMatch(f, `${k}.${u.ext}`, u)
}

i = 0
sm = 0
v = Object.values(csFiles)
let troy_kv = Object.entries(troyFiles)
let cs_names_kv = Object.entries(csNames)
for(let f of v){
    logProcess(i++, v, 'cs', sm)
    if(f.contentStr == undefined) continue
    //for(let [k, u] of troy_kv)
    //    simpleMatch(f, `"${k}.${u.ext}"`, u)
    for(let [k, u] of troy_kv)
        if(f.contentStr.indexOf(`"${k}.${u.ext}"`) !== -1){
            f.use(u); sm++
        }
    for(let [k, u] of ini_kv)
        if(f.contentStr.indexOf(`"${k}"`) !== -1){
            f.use(u); sm++
        }
    for(let [k, u] of cs_names_kv){
        let kn = k.split('.')
        heavyMatch(f, kn[0], u, kn[1])
    }
}

console.log('Saving...')

let files_v = [csFiles, iniFiles, troyFiles, binFiles].flatMap(fs => Object.values(fs))
for(let f of files_v){
    delete f.content;
    delete f.contentStr;
    delete (f as any).saved;
    (f as any).usedBy = [...f.usedBy].map(f => { let i = files_v.indexOf(f); console.assert(i != -1); return i; });
    (f as any).uses = [...f.uses].map(f => { let i = files_v.indexOf(f); console.assert(i != -1); return i; });
}
await fs.writeFile('out.json', JSON.stringify(files_v), 'utf8')

/*
let str = '@startuml\n'
    str += 'left to right direction\n'

const draw = (f: File) => {
    if(f.saved) return
       f.saved = true
    for(let u of f.uses){
        str += `(${path.basename(f.path)}) --> (${path.basename(u.path)})\n`
        draw(u)
    }
}
draw(iniFiles['ahri'])

str += '@enduml\n'

await fs.writeFile('out.puml', str, 'utf8')
*/