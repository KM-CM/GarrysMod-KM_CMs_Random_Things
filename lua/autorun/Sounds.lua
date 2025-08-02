////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////// SOUNDS CODE HERE ///////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////
sound.Add({
	name="glass.break.small",
	sound={
		"physics/glass/glass_pottery_break1.wav",
		"physics/glass/glass_pottery_break2.wav",
		"physics/glass/glass_pottery_break3.wav",
		"physics/glass/glass_pottery_break4.wav",
	},
	level=110,
	pitch=100,
	channel=CHAN_WEAPON,
})
sound.Add({
	name="glass.break",
	sound={
		"physics/glass/glass_sheet_break1.wav",
		"physics/glass/glass_sheet_break2.wav",
		"physics/glass/glass_sheet_break3.wav",
	},
	level=120,
	pitch=100,
	channel=CHAN_WEAPON,
})
sound.Add({
	name="glass.break.big",
	sound={
		"physics/glass/glass_largesheet_break1.wav",
		"physics/glass/glass_largesheet_break2.wav",
		"physics/glass/glass_largesheet_break3.wav",
	},
	level=130,
	pitch=100,
	channel=CHAN_WEAPON,
})

sound.Add({
	name="fire.ignite",
	sound="ambient/fire/ignite.wav",
	level=110,
	pitch=100,
	channel=CHAN_WEAPON,
})
sound.Add({
	name="fire.igniteshort",
	sound="ambient/fire/gascan_ignite1.wav",
	level=110,
	pitch=110,
	channel=CHAN_WEAPON,
})

sound.Add({
	name="player.flashlight.on",
	sound="flashlighton.wav",
	level=70,
	channel=CHAN_WEAPON,
})
sound.Add({
	name="player.flashlight.off",
	sound="flashlightoff.wav",
	level=70,
	channel=CHAN_WEAPON,
})
//Removing Bad and Forced-To-Play sounds.
local function RemoveSound(n) sound.Add({
	name=n,
	sound="common/null.wav",
	level=0,
	channel=CHAN_WEAPON,
}) end
RemoveSound("Weapon_357.OpenLoader")
RemoveSound("Weapon_357.RemoveLoader")
RemoveSound("Weapon_357.ReplaceLoader")
RemoveSound("Weapon_Shotgun.NPC_Reload")
RemoveSound("Weapon_Shotgun.Special1")
RemoveSound("Weapon.StepLeft")
RemoveSound("Weapon.StepRight")
RemoveSound("Weapon.ImpactSoft")
RemoveSound("Weapon_Pistol.Special1")
RemoveSound("Weapon_Pistol.Special2")
//Silenced gunshot sounds for weapons.
//29.07.2024: Its better than earlier versions, but it still SUCKS! I'm planning to rework it sometime later.
//31.07.2024: Reworked. Sounds GOOD.
sound.Add({
	name="weapon.silenced_shot",
	sound="gunfire/weapon_silenced_shot.wav",
	volume=.33,
	level=80,
	pitch=100,
	channel=CHAN_STATIC,
})