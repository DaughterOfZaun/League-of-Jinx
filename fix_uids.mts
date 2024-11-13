import fs from "node:fs/promises"
const log = await fs.readFile('log.txt', 'utf8')
for(let [_, file, uid, path] of log.matchAll(/(res:\/\/.*?\.(?:tres|tscn|gltf)).*?(?:invalid UID).*?(uid:\/\/\w+).*?(?:using text path instead).*?(res:\/\/.*?\.(?:webp|tres))/g)){
    file = file.replace('res://', '')
    path = path.replace('res://', '').replace('.webp', '.webp.import')
    let fileContents = await fs.readFile(file, 'utf8')
    let pathContents = await fs.readFile(path, 'utf8')
    let newUID = pathContents.match(/^uid="(uid:\/\/\w+)"/m)?.at(1)
    console.assert(newUID)
    //console.log(uid, '->', newUID)
    fileContents = fileContents.replaceAll(uid, newUID!)
    /*await*/ fs.writeFile(file, fileContents, 'utf8')
}
