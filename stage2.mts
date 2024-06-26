import { promises as fs } from 'fs';
import path from 'path'

class File {
    isItem = false
    usedBy: Set<File>
    uses: Set<File>
    saved = false
    path: string
    name: string
    ext: string
    constructor(p: string, n: string, e: string, isItem = false, uses = new Set<File>, usedBy = new Set<File>){
        this.uses = uses
        this.usedBy = usedBy
        this.isItem = isItem
        this.path = p
        this.name = n
        this.ext = e
    }
    use(f: File){
        this.uses.add(f)
        f.usedBy.add(this)
    }
}

let fileTemplates = JSON.parse(await fs.readFile('out.json', 'utf8'))
let filesArray: File[] = fileTemplates.map((f: any) => new File(f.path, f.name, f.ext, f.isItem))
filesArray.forEach((f, i) => {
    let t = fileTemplates[i]
    f.uses = new Set(t.uses.map((i: number) => {
        //console.assert(i >= 0 && i < filesArray.length, 'uses ' + i);
        return filesArray[i];
    } ))
    f.uses.delete(undefined!);
    f.usedBy = new Set(t.usedBy.map((i: number) => {
        //console.assert(i >= 0 && i < filesArray.length, 'usedBy ' + i);
        return filesArray[i];
    }))
    f.usedBy.delete(undefined!);
});
let files = Object.fromEntries(filesArray.map(f => [`${f.name}.${f.ext}`, f]))
for(let f of filesArray)
    f.name = `${path.basename(f.path).split('.', 2)[0]}.${f.ext}`

/*
let files = (await fs.readFile('out.puml', 'utf8')).split('\n').reduce<{ [key: string]: File }>((files, line) => {
    let m = line.match(/\((.*?)\) --> \((.*?)\)/)
    if(m !== null){
        let an = m[1].toLowerCase()
        let bn = m[2].toLowerCase()
        let fa = files[an] ?? (files[an] = new File(m[1]))
        let fb = files[bn] ?? (files[bn] = new File(m[2]))
        fa.use(fb)
    }
    return files
}, {})
*/

let str = '@startuml\n'
    str += 'left to right direction\n'

for(let f of filesArray){
    f.usedBy.delete(f)
    f.uses.delete(f)
}

let filesToRemove = new Set<File>()
for(let f of filesArray){
    for(let u of f.uses){
        let un = u.name.replace('CharScript', '').replace('.cs', '.ini')
        if(un.toLowerCase() === f.name.toLowerCase()){
            f.name = `${f.name} + ${u.name}`

            filesToRemove.add(u)
            
            f.uses = new Set([...f.uses, ...u.uses])
            f.uses.delete(f)
            f.uses.delete(u)

            f.usedBy = new Set([...f.usedBy, ...u.usedBy])
            f.usedBy.delete(f)
            f.usedBy.delete(u)

            //for(let uf of f.uses){
            for(let uf of filesArray){
                if(uf.usedBy.delete(u))
                    uf.usedBy.add(f);
            //}
            //for(let uf of f.usedBy){
                if(uf.uses.delete(u))
                    uf.uses.add(f);
            }
        }
    }
}

for(let f of filesToRemove){
    filesArray.splice(filesArray.indexOf(f), 1)
}

const unify = (name: string) => {
    return name.replace(/ \+ .*|\..*/, '').replace(/([a-z])([A-Z])/g, '$1_$2').replace(/ /g, '_').toLowerCase()
}

const simularity = (a: string, b: string) => {
    let i = 0
    let aus = unify(a).split('_')
    let bus = unify(b).split('_')
    let minlen = Math.min(aus.length, bus.length)
    while(i < minlen && aus[i] === bus[i]) i++;
    //return i / aus.length
    return i / minlen
}

const lca = (fs: File[]) => {
    if(fs.some(f => f.name.startsWith('AhriSeduce')))
        console.log('!')
    let ps: File[][][] = []
    if(fs.length == 0){
        return undefined
    } else if(fs.length == 1){
        return fs[0]
    }
    for(let c = 0; c < 100; c++){
        for(let i = 0; i < fs.length; i++){
            let fps = ps[i] || (ps[i] = [ [ fs[i] ] ]);
            let path = fps.shift()!
            let last = path.at(-1)!
            if(last.usedBy.size == 0){
                return undefined
            }
            for(let u of last.usedBy){
                fps.push(path.slice(0).concat([ u ]))
                if(ps.length === fs.length && ps.every(fps2 => (fps2 === fps) || fps2.some(fp => fp.includes(u)))){
                    return u
                }
            }
        }
    }
    console.log('limit exceeded', fs.map(f => f.name))
    return undefined
}

let root = new File('ROOT', 'ROOT', 'ROOT')

let toRemove = new Set()
for(let f of filesArray){
    if(f.usedBy.size > 1){
        let rating = [...f.usedBy].map(
            a => [ simularity(f.name, a.name), a ]
        ).sort(
            (a, b) => (b[0] as number) - (a[0] as number)
        )
        let users = rating.filter(e => e[0] == rating[0][0]).map(e => e[1]) as File[]

        users = [ lca(users) ?? (root.uses.add(f), root) ]

        for(let user of users)
            f.usedBy.delete(user)
        for(let u of f.usedBy){
            u.uses.delete(f)
        }
        f.usedBy.clear()
        for(let user of users)
            f.usedBy.add(user)
    }
}

const draw = (f: File) => {
    if(f.saved) return
       f.saved = true
    for(let u of f.uses){
        //if(u.usedBy.size > 1) continue
        //    str += `(Ahri.ini) --> (${u.name})\n`
        //else
            str += `(${f.name}) --> (${u.name})\n`
        draw(u)
    }
}
//draw(files['ahri.ini'])
draw(root)

str += '@enduml\n'

await fs.writeFile('out2.puml', str, 'utf8')