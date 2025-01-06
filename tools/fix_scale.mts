import path from 'path'
import fs from "node:fs/promises"

const rounded = '0.014'
const precise = '0.0142857142857'
const pair = [rounded, precise]
const replacements = [
    pair.map(f => `"scale_mesh": Vector3(${f}, ${f}, ${f})`),
    pair.map(f => `scale_mesh=Vector3(${f}, ${f}, ${f})`),
    pair.map(f => `nodes/root_scale=${f}`),
]

const walk = async (dir: string) => {
    const dirents = await fs.readdir(dir, { withFileTypes: true })
    for(const dirent of dirents){
        const res = path.resolve(dir, dirent.name)
        if(dirent.isDirectory()){
            /*await*/ walk(res)
        } else if(res.endsWith('.import') || res.endsWith('.godot')){
            let content = await fs.readFile(res, 'utf8')
            for(let [from, to] of replacements){
                content = content.replaceAll(from, to)
            }
            /*await*/ fs.writeFile(res, content, 'utf8')
        }
    }
}
await walk(path.resolve('.'))