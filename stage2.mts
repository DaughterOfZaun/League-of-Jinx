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

let root = new File('ROOT', 'ROOT', 'ROOT')

let characters = [
    'Zilean',
    'YoungLizard',
    'YorickSpectralGhoul',
    'YorickRavenousGhoul',
    'YorickDecayedGhoul',
    'Yorick',
    'XinZhao',
    'XerathArcaneBarrageLauncher',
    'Xerath',
    'WriggleLantern',
    'Wraith',
    'Worm',
    'wolf',
    'Warwick',
    'Volibear',
    'Vladimir',
    'VisionWard',
    'ViktorFF',
    'Viktor',
    'Veigar',
    'Vayne',
    'Urgot',
    'Urf',
    'UdyrTurtle',
    'UdyrTiger',
    'UdyrPhoenix',
    'Udyr',
    'Twitch',
    'TwistedYoungLizard',
    'TwistedTinyWraith',
    'TwistedTinyLizard',
    'TwistedSmallWolf',
    'TwistedLizardElder',
    'TwistedGolem',
    'TwistedGiantWolf',
    'TwistedFate',
    'TwistedBlueWraith',
    'Tutorial_Red_Minion_Wizard',
    'Tutorial_Red_Minion_Basic',
    'Tutorial_Blue_Minion_Wizard',
    'Tutorial_Blue_Minion_Basic',
    'Tryndamere',
    'TrundleWall',
    'Trundle',
    'Tristana',
    'Test_CubeSphere',
    'TestCubeRender10Vision',
    'TestCubeRender',
    'TestCube',
    'TempMovableChar',
    'TeemoMushroom',
    'Teemo',
    'Taric',
    'Talon',
    'SwainRaven',
    'SwainNoBird',
    'SwainBeam',
    'Swain',
    'Summoner_Rider_Order',
    'Summoner_Rider_Chaos',
    'SummonerBeacon',
    'SpellBook1',
    'Soraka',
    'Sona',
    'SmallGolem',
    'Skarner',
    'Sivir',
    'Sion',
    'Singed',
    'SightWard',
    'ShyvanaDragon',
    'Shyvana',
    'ShopKeeper',
    'Shop',
    'Shen',
    'ShacoBox',
    'Shaco',
    'Sejuani',
    'Ryze',
    'Rumble',
    'Riven',
    'Renekton',
    'Red_Minion_Wizard',
    'Red_Minion_Melee',
    'Red_Minion_MechRange',
    'Red_Minion_MechMelee',
    'Red_Minion_MechCannon',
    'Red_Minion_Basic',
    'redDragon',
    'RammusPB',
    'RammusDBC',
    'Rammus',
    'RabidWolf',
    'Poppy',
    'Pantheon',
    'OriannaNoBall',
    'OriannaBall',
    'Orianna',
    'OrderTurretTutorial',
    'OrderTurretShrine',
    'OrderTurretNormal2',
    'OrderTurretNormal',
    'OrderTurretDragon',
    'OrderTurretAngel',
    'OrderNexus',
    'OrderInhibitor_D',
    'OrderInhibitor',
    'OlafAxe',
    'Olaf',
    'Odin_Windmill_Propellers',
    'Odin_Windmill_Gears',
    'OdinTestCubeRender',
    'OdinSpeedShrine',
    'Odin_SOG_Order_Crystal',
    'Odin_SoG_Order',
    'Odin_SOG_Chaos_Crystal',
    'Odin_SoG_Chaos',
    'Odin_skeleton',
    'OdinShieldRelic',
    'OdinRockSaw',
    'OdinRedSuperminion',
    'Odin_Red_Minion_Caster',
    'OdinQuestIndicator',
    'OdinQuestBuff',
    'OdinOrderTurretShrine',
    'OdinOpeningBarrier',
    'OdinNeutralGuardian',
    'OdinMinionSpawnPortal',
    'OdinMinionGraveyardPortal',
    'Odin_Minecart',
    'Odin_Lifts_Crystal',
    'Odin_Lifts_Buckets',
    'Odin_Drill',
    'OdinCrane',
    'OdinClaw',
    'OdinChaosTurretShrine',
    'OdinCenterRelic',
    'OdinBlueSuperminion',
    'Odin_Blue_Minion_Caster',
    'Nunu',
    'Nocturne',
    'Nidalee_Spear',
    'Nidalee_Cougar',
    'Nidalee',
    'Nasus',
    'Morgana',
    'Mordekaiser',
    'MonkeyKingFlying',
    'MonkeyKingClone',
    'MonkeyKing',
    'MissFortune',
    'MasterYi',
    'MaokaiSproutling',
    'Maokai',
    'MalzaharVoidling',
    'Malzahar',
    'Malphite',
    'Lux',
    'LizardElder',
    'Lizard',
    'LesserWraith',
    'Leona',
    'LeeSin',
    'Leblanc',
    'KogMawDead',
    'KogMaw',
    'Kennen',
    'Kayle',
    'Katarina',
    'Kassadin',
    'Karthus',
    'Karma',
    'Jax',
    'JarvanIVWall',
    'JarvanIVStandard',
    'JarvanIV',
    'Janna',
    'Irelia',
    'HeimerTYellow',
    'HeimerTRed',
    'HeimerTGreen',
    'HeimerTBlue',
    'Heimerdinger',
    'Graves',
    'Gragas',
    'GolemODIN',
    'Golem',
    'GiantWolf',
    'Ghast',
    'Garen',
    'Gangplank',
    'Galio',
    'FizzShark',
    'FizzBait',
    'Fizz',
    'FiddleSticks',
    'Ezreal',
    'Evelynn',
    'DrMundo',
    'Dragon',
    'DestroyedTower',
    'DestroyedNexus',
    'DestroyedInhibitor',
    'crystal_platform',
    'Corki',
    'Chogath',
    'ChaosTurretWorm2',
    'ChaosTurretWorm',
    'ChaosTurretTutorial',
    'ChaosTurretShrine',
    'ChaosTurretNormal',
    'ChaosTurretGiant',
    'ChaosNexus',
    'ChaosInhibitor_D',
    'ChaosInhibitor',
    'Cassiopeia_Death',
    'Cassiopeia',
    'CaitlynTrap',
    'Caitlyn',
    'Brand',
    'Blue_Minion_Wizard',
    'Blue_Minion_Melee',
    'Blue_Minion_MechMelee',
    'Blue_Minion_MechCannon',
    'Blue_Minion_Healer',
    'Blue_Minion_Basic',
    'blueDragon',
    'Blitzcrank',
    'Ashe',
    'AnnieTibbers',
    'Annie',
    'AniviaIceblock',
    'AniviaEgg',
    'Anivia',
    'AncientGolem',
    'Amumu',
    'Alistar',
    'Akali',
    'Ahri'
]
//*
for(let c of characters){
    c = c.toLowerCase() + '.ini'
    let f = files[c]
    if(f !== undefined){
        root.use(f)
    }
}
/*/
root.use(files['ahri.ini'])
/*/

/*
for(let i = filesArray.length - 1; i >= 0; i--){
    let f = filesArray[i]
    if(f.usedBy.size === 0 && f.name !== 'Ahri.ini')
        filesArray.splice(i, 1)
}
*/
   
for(let f of filesArray){
    f.usedBy.delete(f)
    f.uses.delete(f)
}

const unify = (name: string) => {
    return name.replace(/CharScript/g, '').replace(/(?: \+ |\.).*/, '').replace(/([a-z])([A-Z])/g, '$1_$2').replace(/ /g, '_').toLowerCase()
    //return name.toLowerCase().replace(/(?: \+ |\.).*/, '').replace(/[_ ]|charscript/g, '')
}

let filesToRemove = new Set<File>()
for(let f of filesArray){
    while(true){
        let restart = false
        for(let u of f.uses){
            //.replace('.cs', '.ini')
            if(f.ext === 'ini' && u.ext === 'cs' && unify(u.name) === unify(f.name)){
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

                // Because f.uses changed
                //restart = true
                break
            }
        }
        if(!restart)
            break;
    }
}

for(let f of filesToRemove){
    filesArray.splice(filesArray.indexOf(f), 1)
}

const simularity = (a: string, b: string) => {

    let aus = unify(a).split('_')
    let bus = unify(b).split('_')
    
    let maxi = 0, maxao = 0, maxbo = 0
    for(let ao = 0; ao < aus.length; ao++){
        for(let bo = 0; bo < bus.length; bo++){
            let i = 0
            for(; i < Math.min(aus.length - ao, bus.length - bo) && aus[i + ao] === bus[i + bo]; i++);
            if(i > maxi){
                [maxi, maxao, maxbo] = [i, ao, bo]
            }
        }
    }
    //console.log(maxi, aus.slice(maxao, maxao + maxi), bus.slice(maxbo, maxbo + maxi))
    return maxi //(maxi / Math.max(aus.length, bus.length))
}

const lca = (_for: File, fs: File[]) => {
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
            //if(last === root){
            if(last.usedBy.size === 0){ //TODO: Push undefined?
                //return undefined
                fps.push(path)
            } else {
                //for(let u of ((last.usedBy.size !== 0) ? last.usedBy : [ root ])){
                for(let u of last.usedBy){
                    fps.push(path.slice(0).concat([ u ]))
                    if(ps.length === fs.length && ps.every(fps2 => (fps2 === fps) || fps2.some(fp => fp.includes(u)))){
                        return u
                    }
                }
            }
        }
    }
    console.log('limit exceeded', _for.name, 'used by', fs.map(f => f.name))
    return undefined
}

for(let f of filesArray){
    if(f.usedBy.size > 1){

        if(f.name.toLowerCase() === 'OdinScoreBigRelic.cs'.toLowerCase())
            console.log('!')

        let rating = [...f.usedBy].map(
            a => [ simularity(f.name, a.name), a ]
        )  as [number, File][]
        rating = rating.sort(
            (a, b) => b[0] - a[0]
        )
        rating = rating.filter(
            e => e[0] == rating[0][0]
        )

        if(rating[0][0] > 0)
            rating = [ rating.sort((a, b) => unify(a[1].name).length - unify(b[1].name).length)[0] ]
        
        let users = rating.map(e => e[1]) as File[]
        

        let user = lca(f, users)
        users = user ? [ user ] : [] //[ (root.uses.add(f), root) ]
        if(user === root) root.use(f) // Ensure connection

        for(let user of users)
            f.usedBy.delete(user)
        for(let u of f.usedBy){
            u.uses.delete(f)
        }
        f.usedBy.clear()
        for(let user of users)
            f.usedBy.add(user)
    } 
    /*
    else if(f.usedBy.size === 0){
        root.use(f)
    }
    */
}

let str = '@startuml\n'
    str += 'left to right direction\n'

const draw = (f: File) => {
    if(f.saved) return
       f.saved = true
    for(let u of f.uses){
        str += `(${f.name}) --> (${u.name})\n`
        draw(u)
    }
}
draw(root)

str += '@enduml\n'

await fs.writeFile('out2.puml', str, 'utf8')