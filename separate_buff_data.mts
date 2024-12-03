import path from 'path'
import fs from "node:fs/promises"

const randomUID = () => (Math.random() * Math.pow(10, 18)).toString(36).slice(0, 12).padStart(12, '0')

const walk = async (dir: string) => {
    const dirents = await fs.readdir(dir, { withFileTypes: true })
    for(const dirent of dirents){
        if(dirent.isDirectory()){
            const res = path.resolve(dir, dirent.name)
            await walk(res)
        } else {
            const gdEnding = 'Buff.gd'
            if(dirent.name.endsWith(gdEnding)){
                const gd = dirent
                let csName = gd.name.replace(gdEnding, '.cs')
                const cs = dirents.find(dirent => dirent.name.toLowerCase() == csName.toLowerCase())
                if(!cs){
                    console.log(csName, 'not found')
                } else {
                    csName = cs.name
                    const csContent = await fs.readFile(path.resolve(dir, csName), 'utf8')
                    const m = csContent.match(/^( *)public override BuffScriptMetadata MetaData \{ get; \} = new\(\)\n\1\{\n((?:.|\n)*?)\1\};/m)
                    if(m != null){
                        const [_, spaces, body] = m
                        const resContent = `
[gd_resource type="Resource" script_class="BuffData" load_steps=2 format=3 uid="uid://${randomUID()}"]

[ext_resource type="Script" uid="uid://bouw5alvreplc" path="res://engine/buffs/buff_data.gd" id="1_a1gtg"]

[resource]
script = ExtResource("1_a1gtg")
${
    body.split(',\n').slice(0, -1).map(line => {
        let [key, value] = line.split('=')
        key = key.trim().replace(/(?<=[a-z])(?=[A-Z])/g, '_').toLowerCase()
        value = value.trim()
        value = value.replace(/new\[\] \{(.*?)\}/, '[$1]')
        if(key == 'auto_buff_activate_effect'){
            value = value.replace('[', 'Dictionary[String, PackedScene]({').replaceAll(',', ': null,').replace(']', '})')
        } else if(key == 'auto_buff_activate_attach_bone_name'){
            value = value.replace('[', 'Array[StringName]([').replace(/"(?!,)/g, '&"').replace(']', '])')
        } else if(key == 'float_statics_decimals' || key == 'float_vars_decimals'){
            value = value.replace('[', 'Array[int]([').replace(']', '])')
        }
        return `${key} = ${value}`
    }).join('\n')
}
metadata/_custom_type_script = ExtResource("1_a1gtg")
`.trimStart()

                        fs.writeFile(path.resolve(dir, gd.name.replace('.gd', '.tres')), resContent, 'utf8')
                    }
                }
            }
        }
    }
}
await walk(path.resolve('data'))