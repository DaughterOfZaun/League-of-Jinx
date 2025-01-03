import path from 'path'
import fs from "node:fs/promises"

function hash(s: string){
	let hashv = 5381
	for(let c of s){
		hashv = (((hashv << 5) + hashv) + c.charCodeAt(0)) | 0;
	}
	return hashv;
}

// https://developer.mozilla.org/en-US/docs/Web/API/SubtleCrypto/digest
async function sha256(message) {
    const msgUint8 = new TextEncoder().encode(message)
    const hashBuffer = await crypto.subtle.digest("SHA-256", msgUint8)
    const hashArray = Array.from(new Uint8Array(hashBuffer))
    const hashHex = hashArray.map((b) => b.toString(16).padStart(2, "0")).join("")
    return hashHex;
}

// https://stackoverflow.com/questions/33631041/javascript-async-await-in-replace#answer-75205316
const replaceAsync = async (str: string, regex: RegExp, asyncFn: (match: any, ...args: any) => Promise<any>) => {
    const promises: Promise<any>[] = []
    str.replace(regex, (match, ...args) => {
        promises.push(asyncFn(match, ...args))
        return match
    })
    const data = await Promise.all(promises)
    return str.replace(regex, () => data.shift())
}

const randomUID = (len: number) => (Math.random() * Math.pow(10, 16)).toString(36).slice(0, len).padStart(12, '0')
const walk = async (dir: string) => {
    const dirents = await fs.readdir(dir, { withFileTypes: true })
    for(const dirent of dirents){
        const res = path.resolve(dir, dirent.name)
        if(dirent.isDirectory()){
            await walk(res)
        } else if(res.endsWith('.tscn')){
            let ids: string[] = []
            let exts: string[] = []
            let tscn = await fs.readFile(res, 'utf8')
            tscn = await replaceAsync(tscn, /\[sub_resource type="Shader" id="(\w+)"\]\ncode = "((?:\\"|\n|.)*?)"\n/g, async (m, id, code) => {
                ids.push(id)
                code = code.replaceAll('\\', '')
                let hash = (await sha256(code)).slice(0, 12)
                let res = `engine/game/cache/${hash}.gdshader`
                /*await*/ fs.writeFile(res, code, 'utf8')
                exts.push(`[ext_resource type="Shader" uid="uid://${hash}" path="res://${res}" id="${id}"]`)
                return ''
            })
            if(exts.length > 0){
                for(let id of ids){
                    tscn = tscn.replaceAll(`SubResource("${id}")`, `ExtResource("${id}")`)
                }
                tscn = tscn.replace(/\[gd_scene load_steps=(\d+) format=(\d+) uid="uid:\/\/(\w+)"\]\n/, (_, steps, format, uid) => {
                    return `[gd_scene load_steps=${parseInt(steps) + exts.length} format=${format} uid="uid://${uid}"\]\n\n${exts.join('\n')}`
                })
                /*await*/ fs.writeFile(res, tscn, 'utf8')
            }
        }
    }
}
await walk(path.resolve('data'))