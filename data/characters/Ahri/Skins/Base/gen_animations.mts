const d = 300;
let fnames = [
	"Ahri_joke",
	"Ahri_channel_windup",
	"Ahri_crit",
	"Ahri_channel",
	"Ahri_attack2",
	"Ahri_attack1",
	"Ahri_idle5",
	"Ahri_idle4",
	"Ahri_idle3",
	"Ahri_idle2",
	"Ahri_idle1",
	"Ahri_hanbok_dance",
	"Ahri_death",
	"Ahri_dance",
	"Ahri_laugh",
	"Ahri_run",
	"Ahri_taunt",
	"Ahri_spell4",
	"Ahri_spell3",
	"Ahri_spell2",
	"Ahri_spell1",
];
let animations = Object.entries({
	Idle1: "Ahri_Idle1",
	Idle2: "Ahri_Idle2",
	Idle3: "Ahri_Idle3",
	Idle4: "Ahri_Idle4",
	Idle5: "Ahri_Idle5",
	
	Joke: "Ahri_Joke",
	Taunt: "Ahri_Taunt",
	//"Dance": "Ahri_hanbok_Dance",
	Dance: "Ahri_Dance",
	Laugh: "Ahri_Laugh",
	
	Run: "Ahri_Run",

	Attack1: "Ahri_attack1",
	Attack2: "Ahri_attack2",
	Crit: "Ahri_Crit",
	
	//Channel: "Ahri_channel",
	//Channel_WNDUP: "Ahri_channel_windup",
	Death: "Ahri_Death",

	Spell1: "Ahri_Spell1",
	Spell2: "Ahri_Spell2",
	Spell3: "Ahri_Spell3",
	Spell4: "Ahri_Spell4",
}).map(([alias, name], i, a) => ({
	id: i.toString(36).padStart(5, "0"),
	name: fnames.find((fname) => fname.toLowerCase() == name.toLowerCase()),
	alias,
	position: [
		d * -Math.cos(i * ((Math.PI * 2) / a.length)),
		d * Math.sin(i * ((Math.PI * 2) / a.length)),
	],
}));

let transitions: { id: string; from: string; to: string }[] = [];
///*
for (let i = 0; i < animations.length; i++)
	for (let j = 0; j < animations.length; j++)
		if (i != j)
			transitions.push({
				id: (transitions.length + animations.length)
					.toString(36)
					.padStart(5, "0"),
				from: animations[i].alias,
				to: animations[j].alias,
			});
//*/
let res = "";
res += `[gd_resource type="AnimationNodeStateMachine" load_steps=${animations.length + transitions.length} format=3 uid="uid://bj5tpjmt4q2fk"]\n`;
for (let animation of animations)
	res += `
[sub_resource type="AnimationNodeAnimation" id="AnimationNodeAnimation_${animation.id}"]
animation = &"${animation.name}"`;
for (let transition of transitions)
	res += `
[sub_resource type="AnimationNodeStateMachineTransition" id="AnimationNodeStateMachineTransition_${transition.id}"]
xfade_time = 0.2`;
res += `
[resource]`;
for (let animation of animations)
	res += `
states/${animation.alias}/node = SubResource("AnimationNodeAnimation_${animation.id}")
states/${animation.alias}/position = Vector2(${animation.position[0]}, ${animation.position[1]})`;
res += `
states/End/position = Vector2(${d + 100}, 0)
states/Start/position = Vector2(${-(d + 100)}, 0)`;
res += `
transitions = [`;
res += transitions
	.flatMap((transition) => [
		`"${transition.from}"`,
		`"${transition.to}"`,
		`SubResource("AnimationNodeStateMachineTransition_${transition.id}")`,
	])
	.join(", ");
res += `]`;
res += `
graph_offset = Vector2(${-(d + 200)}, ${-(d + 100)})`;

console.log(res);
