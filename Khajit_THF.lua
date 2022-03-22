-------------------------------------------------------------------------------------------------------------------
-- Setup functions for this job.  Generally should not be modified.
-------------------------------------------------------------------------------------------------------------------

--[[
    Custom commands:

    gs c cycle treasuremode (set on ctrl-= by default): Cycles through the available treasure hunter modes.
    Treasure hunter modes:
        None - Will never equip TH gear
        Tag - Will equip TH gear sufficient for initial contact with a mob (either melee, ranged hit, or Aeolian Edge AOE)
        SATA - Will equip TH gear sufficient for initial contact with a mob, and when using SATA
        Fulltime - Will keep TH gear equipped fulltime

--]]

-- Initialization function for this job file.
function get_sets()
    mote_include_version = 2
    
    -- Load and initialize the include file.
    include('Mote-Include.lua')
	include('organizer-lib')
	    require('vectors')	
	
end

-- Setup vars that are user-independent.  state.Buff vars initialized here will automatically be tracked.
function job_setup()
    state.Buff['Sneak Attack'] = buffactive['sneak attack'] or false
    state.Buff['Trick Attack'] = buffactive['trick attack'] or false
    state.Buff['Feint'] = buffactive['feint'] or false
    
    include('Mote-TreasureHunter')

    -- For th_action_check():
    -- JA IDs for actions that always have TH: Provoke, Animated Flourish
    info.default_ja_ids = S{35, 204}
    -- Unblinkable JA IDs for actions that always have TH: Quick/Box/Stutter Step, Desperate/Violent Flourish
    info.default_u_ja_ids = S{201, 202, 203, 205, 207}
	
	    state.HasteMode = M{['description']='Haste Mode', 'Haste I', 'Haste II'}
	state.MarchMode = M{['description']='March Mode', 'Trusts', '3', '7', 'Honor'}
    state.Runes = M{['description']='Runes', "Ignis", "Gelus", "Flabra", "Tellus", "Sulpor", "Unda", "Lux", "Tenebrae"}
    state.UseRune = M(false, 'Use Rune')
	state.CapacityMode = M(false, 'Capacity Point Mantle')
    run_sj = player.sub_job == 'RUN' or false

--    select_ammo()
	    update_combat_form()

    state.warned = M(false)
	
	
	    RandomLockstyleGenerator = 'true'
	    -- List of Equipment Sets created for Random Lockstyle Generator
    -- (If you want to have the same Lockstyle every time, reduce the list to a single Equipset #)
    random_lockstyle_list = {21,42,3,44,45,48,49,50,51,55,63,65,66,67,69,70,71,}
	-- Random Lockstyle generator.
    if RandomLockstyleGenerator == 'true' then
        local randomLockstyle = random_lockstyle_list[math.random(1, #random_lockstyle_list)]
        send_command('@wait 5;input /lockstyleset '.. randomLockstyle)
    end
	
	
	
end

-------------------------------------------------------------------------------------------------------------------
-- User setup functions for this job.  Recommend that these be overridden in a sidecar file.
-------------------------------------------------------------------------------------------------------------------

-- Setup vars that are user-dependent.  Can override this function in a sidecar file.
function user_setup()
    state.OffenseMode:options ('Normal', 'Acc', 'Acc2', 'Acc3')
    state.HybridMode:options('Normal', 'Evasion', 'PDT','MDT')
    state.RangedMode:options('Normal', 'Acc')
    state.WeaponskillMode:options('Normal', 'Acc', 'Mod')
    state.PhysicalDefenseMode:options( 'PDT','Evasion')
	state.MagicalDefenseMode:options('MagicEvasion', 'MDT')
    state.IdleMode:options('Normal', 'PDT', 'MEVA', 'Regain', 'Regen')
    gear.default.weaponskill_neck = "Assassin's Gorget +2"
    gear.default.weaponskill_waist = "Fotia Belt"
--    gear.AugQuiahuiz = {name="Quiahuiz Trousers", augments={'Haste+2','"Snapshot"+2','STR+8'}}

    -- Additional local binds
	
	send_command('bind !` gs c cycle HasteMode')
	send_command('bind @` gs c cycle MarchMode')
    send_command('bind @[ gs c cycle Runes')
    send_command('bind ^] gs c toggle UseRune')
	send_command('bind ` input /jump')
	
	
	
    send_command('bind ^` input /ja "Flee" <me>')
    send_command('bind ^= gs c cycle treasuremode')
    send_command('bind !- gs c cycle targetmode')

    select_default_macro_book()
end

-- Called when this job file is unloaded (eg: job change)
function user_unload()
    send_command('unbind ^`')
    send_command('unbind !-')
end

-- Define sets and vars used by this job file.
function init_gear_sets()
    --------------------------------------
    -- Special sets (required by rules)
    --------------------------------------

    sets.TreasureHunter = {
	--ammo="Perfect Lucky Egg",
	hands="Plunderer's Armlets +2",
	legs={ name="Herculean Trousers", augments={'Rng.Atk.+4','VIT+9','"Treasure Hunter"+2','Accuracy+4 Attack+4',}},
	--feet="Skulker's Poulaines +1"
	}
    sets.ExtraRegen = {Neck="Bathy Choker +1",ear1="Infused Earring",ear2="Dawn Earring",
		ring1="Sheltered Ring",ring2="Paguroidea Ring"}
    sets.Kiting = {feet="Jute Boots +1"}

    sets.buff['Sneak Attack'] = {ammo="Yetshila +1",
        head="Adhemar Bonnet +1",
		neck="Assassin's Gorget +2",
		ear1="Sherida Earring",ear2="Odr Earring",
--        body="Meghanada Curie +2",
        body="Plunderer's Vest +3",
		hands="Skulker's Armlets +1",ring1="Ilabrat Ring",ring2="Regal Ring",
        --back="Toutatis's Cape",
        legs="Pillager's Culottes +3",
		feet="Plunderer's Poulaines +3"}

    sets.buff['Trick Attack'] = {ammo="Yetshila +1",
        head="Adhemar Bonnet +1",
		neck="Assassin's Gorget +2",
		--ear1="Dudgeon Earring",ear2="Heartseeker Earring",
        body="Plunderer's Vest +3",
		hands="Pillager's Armlets +3",
		ring1="Ilabrat Ring",ring2="Gere Ring",
        --back={ name="Canny Cape", augments={'DEX+4','AGI+2','"Dual Wield"+1','Crit. hit damage +2%',}},
        legs="Pillager's Culottes +3",
		feet="Plunderer's Poulaines +3"}

		
		
    -- Actions we want to use to tag TH.
    sets.precast.Step = sets.TreasureHunter
    sets.precast.Flourish1 = sets.TreasureHunter
    sets.precast.JA.Provoke = sets.TreasureHunter
    sets.precast.JA.Bully = sets.TreasureHunter


    --------------------------------------
    -- Precast sets
    --------------------------------------

    -- Precast sets to enhance JAs
    sets.precast.JA['Collaborator'] = {head="Skulker's Bonnet +1"}
    sets.precast.JA['Accomplice'] = {head="Skulker's Bonnet +1"}
    sets.precast.JA['Flee'] = {feet="Pillager's Poulaines +1"}
    sets.precast.JA['Hide'] = {body="Pillager's Vest +3"}
    sets.precast.JA['Conspirator'] = {body="Skulker's Vest +1"}
    sets.precast.JA['Steal'] = {head="Plunderer's Bonnet +3",hands="Pillager's Armlets +3",legs="Pillager's Culottes +3",feet="Pillager's Poulaines +1"}
    sets.precast.JA['Despoil'] = {legs="Skulker's Culottes +1",feet="Skulker's Poulaines +1"}
    
    sets.precast.JA['Mug'] = {head="Plunderer's Bonnet +3",
        neck="Caro Necklace",ear1="Sherida Earring",ear2="Dawn Earring",
        body="Pillager's Vest +3",hands="Pillager's Armlets +3",ring1="Ilabrat Ring",ring2="Regal Ring",
        back="Toutatis's Cape",legs="Pillager's Culottes +3",feet="Plunderer's Poulaines +3"}


    sets.precast.JA['Perfect Dodge'] = {hands="Plunderer's Armlets +2"}
    sets.precast.JA['Feint'] =  {legs="Plunderer's Culottes +1"}

    sets.precast.JA['Sneak Attack'] = sets.buff['Sneak Attack']
    sets.precast.JA['Trick Attack'] = sets.buff['Trick Attack']

    sets.precast.JA.Jump = {
--        ammo="Yamarang",
		ammo="Aurgelmir Orb +1",
		head="Malignance Chapeau",
		neck="Anu Torque",
		Ear1="Sherida Earring",
		Ear2="Dedition Earring",
        body="Malignance Tabard",
		hands="Malignance gloves",
		left_ring	=	{name="Moonlight Ring", bag="wardrobe"}, -- I do this to prevent issues with lag sometimes if 2 ring are the same in same bag GS sometimes only equips 1 of them        
		right_ring	=	{name="Moonlight Ring", bag="wardrobe2"},
		back={ name="Toutatis's Cape", augments={'DEX+20','Accuracy+20 Attack+20','DEX+10','"Store TP"+10','Occ. inc. resist. to stat. ailments+10',}},
		waist="Kentarch Belt +1",
		legs="Samnuha Tights",
		feet="Malignance Boots"

		}
    sets.precast.JA['High Jump'] = set_combine(sets.precast.JA.Jump, {
	--legs="Pteroslaver Brais +2"
    })



    -- Waltz set (chr and vit)
    sets.precast.Waltz = {ammo="Yamarang",
        --head="Iuitl Headgear +1",
       -- body="Plunderer's Vest +1",hands="Pillager's Armlets +1",ring1="Asklepian Ring",
        --back="Iximulew Cape",waist="Warwolf Belt",legs="Taeon Tights",feet="Plunderer's Poulaines +3"
		}

    -- Don't need any special gear for Healing Waltz.
    sets.precast.Waltz['Healing Waltz'] = {}


    -- Fast cast sets for spells
    sets.precast.FC = {
	ammo="Impatiens",
    head={ name="Herculean Helm", augments={'"Mag.Atk.Bns."+1','"Fast Cast"+6','STR+3','Mag. Acc.+14',}},
    body="Dread Jupon",
    hands={ name="Leyline Gloves", augments={'Accuracy+15','Mag. Acc.+15','"Mag.Atk.Bns."+15','"Fast Cast"+3',}},
    legs={ name="Rawhide Trousers", augments={'MP+50','"Fast Cast"+5','"Refresh"+1',}},
    feet={ name="Herculean Boots", augments={'"Mag.Atk.Bns."+13','"Fast Cast"+7','Accuracy+5 Attack+5',}},
    neck="Voltsurge Torque",
    waist="Flume Belt",
    left_ear="Etiolation Earring",
    right_ear={ name="Odnowa Earring +1", augments={'Path: A',}},
    left_ring="Rahab Ring",
    right_ring="Weather. Ring",
    back={ name="Toutatis's Cape", augments={'INT+20','Eva.+20 /Mag. Eva.+20','"Fast Cast"+10','Mag. Evasion+15',}},

	}

    sets.precast.FC.Utsusemi = set_combine(sets.precast.FC, {body="Passion Jacket",neck="Magoraga Beads"})


    -- Ranged snapshot gear
    sets.precast.RA = {head="Aurore Beret",hands="Iuitl Wristbands +1",legs="Kaabnax Trousers",feet="Wurrukatte Boots"}


    -- Weaponskill sets

    -- Default set for any weaponskill that isn't any more specifically defined
    sets.precast.WS = {ammo="Seething Bomblet +1",
        head="Pillager's Bonnet +3",neck="Foita Gorget",ear1="Sherida Earring",ear2="Odr Earring",
        body={ name="Herculean Vest", augments={'Pet: STR+7','STR+4','Weapon skill damage +9%','Mag. Acc.+17 "Mag.Atk.Bns."+17',}},
		hands="Meghanada Gloves +2",ring1="Ilabrat Ring",ring2="Regal Ring",
            back={ name="Toutatis's Cape", augments={'DEX+20','Accuracy+20 Attack+20','DEX+10','Weapon skill damage +10%',}},
			waist="Foita Belt",
			legs="Plunderer's Culottes +2",
--			legs="Samnuha Tights",
			
			feet={ name="Herculean Boots", augments={'Pet: Accuracy+2 Pet: Rng. Acc.+2','Rng.Acc.+5 Rng.Atk.+5','Weapon skill damage +9%','Accuracy+16 Attack+16',}},

			
			
}
    sets.precast.WS.Acc = set_combine(sets.precast.WS, {ammo="Seething Bomblet"})

    -- Specific weaponskill sets.  Uses the base set if an appropriate WSMod version isn't found.
    sets.precast.WS['Exenterator'] = set_combine(sets.precast.WS, {})
    sets.precast.WS['Exenterator'].Acc = set_combine(sets.precast.WS['Exenterator'], {ammo="Seething Bomblet +1", back="Toutatis's Cape",})
    sets.precast.WS['Exenterator'].Mod = set_combine(sets.precast.WS['Exenterator'], {head="Adhemar Bonnet +1",waist=gear.ElementalBelt})
    sets.precast.WS['Exenterator'].SA = set_combine(sets.precast.WS['Exenterator'].Mod, {ammo="Yetshila +1",body="Meghanada Curie +2",hands="Skulker's Armlets +1"})
    sets.precast.WS['Exenterator'].TA = set_combine(sets.precast.WS['Exenterator'].Mod, {ammo="Yetshila +1",body="Meghanada Curie +2"})
    sets.precast.WS['Exenterator'].SATA = set_combine(sets.precast.WS['Exenterator'].Mod, {ammo="Yetshila +1",body="Meghanada Curie +2",hands="Skulker's Armlets +1"})

    sets.precast.WS['Dancing Edge'] = set_combine(sets.precast.WS, {Ammo="Aurgelmir Orb +1"})
    sets.precast.WS['Dancing Edge'].Acc = set_combine(sets.precast.WS['Dancing Edge'], {ammo="Seething Bomblet +1", "Toutatis's Cape",})
    sets.precast.WS['Dancing Edge'].Mod = set_combine(sets.precast.WS['Dancing Edge'], {waist=gear.ElementalBelt})
    sets.precast.WS['Dancing Edge'].SA = set_combine(sets.precast.WS['Dancing Edge'].Mod, {ammo="Yetshila"})
    sets.precast.WS['Dancing Edge'].TA = set_combine(sets.precast.WS['Dancing Edge'].Mod, {ammo="Yetshila"})
    sets.precast.WS['Dancing Edge'].SATA = set_combine(sets.precast.WS['Dancing Edge'].Mod, {ammo="Yetshila"})

    sets.precast.WS['Evisceration'] = set_combine(sets.precast.WS, {ammo="Yetshila +1",
        head="Pillager's Bonnet +3",neck="Foita Gorget",ear1="Odr Earring",ear2="Moonshade Earring",
        --body="Meghanada Curie +2",
		body="Plunderer's Vest +3",
		--Ring1="Begrudging ring"
		    back={ name="Toutatis's Cape", augments={'DEX+20','Accuracy+20 Attack+20','DEX+10','Crit.hit rate+10','Phys. dmg. taken-10%',}},
				legs="Lustratio Subligar +1",
		feet="Lustratio Leggings +1"})
    sets.precast.WS['Evisceration'].Acc = set_combine(sets.precast.WS['Evisceration'], { body="Meghanada Curie +2", 
	
	})
    sets.precast.WS['Evisceration'].Mod = set_combine(sets.precast.WS['Evisceration'], {back="Toutatis's Cape",waist="Foita Belt"})
    sets.precast.WS['Evisceration'].SA = set_combine(sets.precast.WS['Evisceration'].Mod, {})
    sets.precast.WS['Evisceration'].TA = set_combine(sets.precast.WS['Evisceration'].Mod, {})
    sets.precast.WS['Evisceration'].SATA = set_combine(sets.precast.WS['Evisceration'].Mod, {})

    sets.precast.WS["Rudra's Storm"] = set_combine(sets.precast.WS, {
				ammo="Aurgelmir Orb +1",
				head="Pillager's Bonnet +3",ear2="Ishvara Earring",ear1="Moonshade Earring",hands="Meghanada Gloves +2",})
 
 sets.precast.WS["Rudra's Storm"].Acc = set_combine(sets.precast.WS["Rudra's Storm"], {
 --ammo="Seething Bomblet +1", 
				back={ name="Toutatis's Cape", augments={'DEX+20','Accuracy+20 Attack+20','DEX+10','Weapon skill damage +10%',}}									
				})
    sets.precast.WS["Rudra's Storm"].Mod = set_combine(sets.precast.WS["Rudra's Storm"], {
	
--		hands="Gleti's Gauntlets",
		waist="Kentarch Belt +1",
	--	legs="Gleti's Breeches",
	--	feet="Gleti's Boots",
	
	
	})
    sets.precast.WS["Rudra's Storm"].SA = set_combine(sets.precast.WS["Rudra's Storm"].Mod, {ammo="Yetshila +1",
        --body="Meghanada Curie +2",
		body="Plunderer's Vest +3",
		hands="Meghanada Gloves +2",
		legs="Lustratio Subligar +1",
		feet="Lustratio Leggings +1"
		})
    sets.precast.WS["Rudra's Storm"].TA = set_combine(sets.precast.WS["Rudra's Storm"].Mod, {ammo="Yetshila +1",
		--body="Meghanada Curie +2",
		body="Plunderer's Vest +3",
		legs="Lustratio Subligar +1",
		feet="Lustratio Leggings +1"
		})
    sets.precast.WS["Rudra's Storm"].SATA = set_combine(sets.precast.WS["Rudra's Storm"].Mod, {ammo="Yetshila +1",
        --body="Meghanada Curie +2",
		body="Plunderer's Vest +3",
		legs="Lustratio Subligar +1",
		feet="Lustratio Leggings +1"
		})


    sets.precast.WS["Mercy Stroke"] = set_combine(sets.precast.WS, {head="Pillager's Bonnet +3",ammo="Seething Bomblet +1",ear1="Sherida Earring",ear2="Ishvara Earring"})
    sets.precast.WS["Mercy Stroke"].Acc = set_combine(sets.precast.WS["Mercy Stroke"], {   })
    sets.precast.WS["Mercy Stroke"].Mod = set_combine(sets.precast.WS["Mercy Stroke"], {   })
    sets.precast.WS["Mercy Stroke"].SA = set_combine(sets.precast.WS["Mercy Stroke"].Mod, {ammo="Yetshila +1",
        body="Meghanada Curie +2",
		legs="Samnuha Tights"})
    sets.precast.WS["Mercy Stroke"].TA = set_combine(sets.precast.WS["Mercy Stroke"].Mod, {ammo="Yetshila +1",
        body="Meghanada Curie +2",
		legs="Samnuha Tights"})
    sets.precast.WS["Mercy Stroke"].SATA = set_combine(sets.precast.WS["Mercy Stroke"].Mod, {ammo="Yetshila +1",
        body="Meghanada Curie +2",
		legs="Samnuha Tights"})


    sets.precast.WS["Shark Bite"] = set_combine(sets.precast.WS, {ammo="Aurgelmir Orb +1",
																	head="Adhemar Bonnet +1",ear1="Brutal Earring",ear2="Moonshade Earring"})
    sets.precast.WS['Shark Bite'].Acc = set_combine(sets.precast.WS['Shark Bite'], {   })
    sets.precast.WS['Shark Bite'].Mod = set_combine(sets.precast.WS['Shark Bite'], {
											})
    sets.precast.WS['Shark Bite'].SA = set_combine(sets.precast.WS['Shark Bite'].Mod, {ammo="Yetshila +1",
        body="Plunderer's Vest +3",legs="Lustratio Subligar +1"})
    sets.precast.WS['Shark Bite'].TA = set_combine(sets.precast.WS['Shark Bite'].Mod, {ammo="Yetshila +1",
        body="Plunderer's Vest +3",legs="Lustratio Subligar +1"})
    sets.precast.WS['Shark Bite'].SATA = set_combine(sets.precast.WS['Shark Bite'].Mod, {ammo="Yetshila +1",
        body="Plunderer's Vest +3",hands="Skulker's Armlets +1",legs="Lustratio Subligar +1"})

    sets.precast.WS['Mandalic Stab'] = set_combine(sets.precast.WS, {ammo="Aurgelmir Orb +1", 
						ear1="Sherida Earring",ear2="Moonshade Earring"})
    sets.precast.WS['Mandalic Stab'].Acc = set_combine(sets.precast.WS['Mandalic Stab'], {})
    sets.precast.WS['Mandalic Stab'].Mod = set_combine(sets.precast.WS['Mandalic Stab'], {})
    sets.precast.WS['Mandalic Stab'].SA = set_combine(sets.precast.WS['Mandalic Stab'].Mod, {ammo="Yetshila +1",
        body="Pillager's Vest +3",	
		legs="Lustratio Subligar +1"})
    sets.precast.WS['Mandalic Stab'].TA = set_combine(sets.precast.WS['Mandalic Stab'].Mod, {ammo="Yetshila +1",
       -- body="Meghanada Curie +2",
		legs="Lustratio Subligar +1"})
    sets.precast.WS['Mandalic Stab'].SATA = set_combine(sets.precast.WS['Mandalic Stab'].Mod, {ammo="Yetshila +1",
       -- body="Meghanada Curie +2",
		legs="Lustratio Subligar +1"})



    sets.precast.WS['Savage Blade'] = set_combine(sets.precast.WS, {
	ammo={ name="Seeth. Bomblet +1", augments={'Path: A',}},
    head="Gleti's Mask",
    body="Gleti's Cuirass",
    hands="Gleti's Gauntlets",
    legs="Gleti's Breeches",
    feet="Gleti's Boots",
    neck="Caro Necklace",
    waist={ name="Sailfi Belt +1", augments={'Path: A',}},
    left_ear="Sherida Earring",
    right_ear={ name="Moonshade Earring", augments={'Attack+4','TP Bonus +250',}},
    left_ring="Regal Ring",
    right_ring="Gere Ring",
    back={ name="Toutatis's Cape", augments={'DEX+20','Accuracy+20 Attack+20','DEX+10','Weapon skill damage +10%','Phys. dmg. taken-10%',}},	
	
	})
    sets.precast.WS['Savage Blade'].Acc = set_combine(sets.precast.WS['Savage Blade'], {})
    sets.precast.WS['Savage Blade'].Mod = set_combine(sets.precast.WS['Savage Blade'], {})
    sets.precast.WS['Savage Blade'].SA = set_combine(sets.precast.WS['Savage Blade'].Mod, {
	    ammo="Yetshila +1",
    head="Pill. Bonnet +3",
    body="Gleti's Cuirass",
    hands="Meg. Gloves +2",
    legs={ name="Plun. Culottes +2", augments={'Enhances "Feint" effect',}},
    feet="Gleti's Boots",
    neck={ name="Asn. Gorget +2", augments={'Path: A',}},
    waist={ name="Kentarch Belt +1", augments={'Path: A',}},
    left_ear="Sherida Earring",
    right_ear={ name="Moonshade Earring", augments={'Attack+4','TP Bonus +250',}},
    left_ring="Regal Ring",
    right_ring="Gere Ring",
    back={ name="Toutatis's Cape", augments={'DEX+20','Accuracy+20 Attack+20','DEX+10','Weapon skill damage +10%','Phys. dmg. taken-10%',}},		
		})
    sets.precast.WS['Savage Blade'].TA = set_combine(sets.precast.WS['Savage Blade'].Mod, {
	    ammo="Yetshila +1",
    head="Pill. Bonnet +3",
    body="Gleti's Cuirass",
    hands="Meg. Gloves +2",
    legs={ name="Plun. Culottes +2", augments={'Enhances "Feint" effect',}},
    feet="Gleti's Boots",
    neck={ name="Asn. Gorget +2", augments={'Path: A',}},
    waist={ name="Kentarch Belt +1", augments={'Path: A',}},
    left_ear="Sherida Earring",
    right_ear={ name="Moonshade Earring", augments={'Attack+4','TP Bonus +250',}},
    left_ring="Regal Ring",
    right_ring="Gere Ring",
    back={ name="Toutatis's Cape", augments={'DEX+20','Accuracy+20 Attack+20','DEX+10','Weapon skill damage +10%','Phys. dmg. taken-10%',}},
		})
    sets.precast.WS['Savage Blade'].SATA = set_combine(sets.precast.WS['Savage Blade'].Mod, {
	    ammo="Yetshila +1",
    head="Pill. Bonnet +3",
    body="Gleti's Cuirass",
    hands="Meg. Gloves +2",
    legs={ name="Plun. Culottes +2", augments={'Enhances "Feint" effect',}},
    feet="Gleti's Boots",
    neck={ name="Asn. Gorget +2", augments={'Path: A',}},
    waist={ name="Kentarch Belt +1", augments={'Path: A',}},
    left_ear="Sherida Earring",
    right_ear={ name="Moonshade Earring", augments={'Attack+4','TP Bonus +250',}},
    left_ring="Regal Ring",
    right_ring="Gere Ring",
    back={ name="Toutatis's Cape", augments={'DEX+20','Accuracy+20 Attack+20','DEX+10','Weapon skill damage +10%','Phys. dmg. taken-10%',}},
		})
















    sets.precast.WS['Aeolian Edge'] = {
	    ammo={ name="Seeth. Bomblet +1", augments={'Path: A',}},
    head="Nyame Helm",
    body={ name="Herculean Vest", augments={'Pet: STR+7','STR+4','Weapon skill damage +9%','Mag. Acc.+17 "Mag.Atk.Bns."+17',}},
    hands={ name="Herculean Gloves", augments={'Mag. Acc.+24','Magic burst dmg.+9%','Weapon skill damage +10%','Mag. Acc.+9 "Mag.Atk.Bns."+9',}},
    legs={ name="Herculean Trousers", augments={'INT+10','"Mag.Atk.Bns."+23','Accuracy+1 Attack+1','Mag. Acc.+19 "Mag.Atk.Bns."+19',}},
    feet="Nyame Sollerets",
    neck="Sanctity Necklace",
    waist="Eschan Stone",
    left_ear={ name="Moonshade Earring", augments={'Attack+4','TP Bonus +250',}},
    right_ear="Friomisi Earring",
    left_ring="Ilabrat Ring",
    right_ring="Dingir Ring",
    back={ name="Toutatis's Cape", augments={'DEX+20','Accuracy+20 Attack+20','DEX+10','Weapon skill damage +10%','Phys. dmg. taken-10%',}},
		}

    sets.precast.WS['Aeolian Edge'].TH = set_combine(sets.precast.WS['Aeolian Edge'], sets.TreasureHunter)


    --------------------------------------
    -- Midcast sets
    --------------------------------------

    sets.midcast.FastRecast = {
		ammo="Impatiens",
    head={ name="Herculean Helm", augments={'"Mag.Atk.Bns."+1','"Fast Cast"+6','STR+3','Mag. Acc.+14',}},
    body="Dread Jupon",
    hands={ name="Leyline Gloves", augments={'Accuracy+15','Mag. Acc.+15','"Mag.Atk.Bns."+15','"Fast Cast"+3',}},
    legs={ name="Rawhide Trousers", augments={'MP+50','"Fast Cast"+5','"Refresh"+1',}},
    feet={ name="Herculean Boots", augments={'"Mag.Atk.Bns."+13','"Fast Cast"+7','Accuracy+5 Attack+5',}},
    neck="Voltsurge Torque",
    waist="Flume Belt",
    left_ear="Etiolation Earring",
    right_ear={ name="Odnowa Earring +1", augments={'Path: A',}},
    left_ring="Rahab Ring",
    right_ring="Weather. Ring",
    back={ name="Toutatis's Cape", augments={'INT+20','Eva.+20 /Mag. Eva.+20','"Fast Cast"+10','Mag. Evasion+15',}},
		
		}

    -- Specific spells
    sets.midcast.Utsusemi = {
	
	ammo="Impatiens",
    head={ name="Herculean Helm", augments={'"Mag.Atk.Bns."+1','"Fast Cast"+6','STR+3','Mag. Acc.+14',}},
    body="Dread Jupon",
    hands={ name="Leyline Gloves", augments={'Accuracy+15','Mag. Acc.+15','"Mag.Atk.Bns."+15','"Fast Cast"+3',}},
    legs={ name="Rawhide Trousers", augments={'MP+50','"Fast Cast"+5','"Refresh"+1',}},
    feet={ name="Herculean Boots", augments={'"Mag.Atk.Bns."+13','"Fast Cast"+7','Accuracy+5 Attack+5',}},
    neck="Voltsurge Torque",
    waist="Flume Belt",
    left_ear="Etiolation Earring",
    right_ear={ name="Odnowa Earring +1", augments={'Path: A',}},
    left_ring="Rahab Ring",
    right_ring="Weather. Ring",
    back={ name="Toutatis's Cape", augments={'INT+20','Eva.+20 /Mag. Eva.+20','"Fast Cast"+10','Mag. Evasion+15',}},
	}
	
    -- Ranged gear
    sets.midcast.RA = {
        head="Whirlpool Mask",neck="Sanctity Necklace",ear1="Clearview Earring",ear2="Volley Earring",
        body="Iuitl Vest",hands="Iuitl Wristbands +1",ring1="Beeline Ring",ring2="Hajduk Ring",
        back="Libeccio Mantle",waist="Aquiline Belt",legs="Kaabnax Trousers",feet="Iuitl Gaiters +1"}

    sets.midcast.RA.Acc = {
        head="Pillager's Bonnet +3",neck="Caro Necklace",ear1="Clearview Earring",ear2="Volley Earring",
        body="Iuitl Vest",hands="Buremte Gloves",ring1="Beeline Ring",ring2="Hajduk Ring",
        back="Libeccio Mantle",waist="Aquiline Belt",legs="Thurandaut Tights +1",feet="Pillager's Poulaines +1"}


    --------------------------------------
    -- Idle/Lustratio Subligar/defense sets
    --------------------------------------

    -- Resting sets
    sets.resting = {head="Turms Cap",neck="Loricate Torque +1",
        ring1="Sheltered Ring",ring2="Paguroidea Ring"}


    -- Idle sets (default idle set not needed since the other three are defined, but leaving for testing purposes)

    sets.idle = {ammo="Yamarang",
		head="Turms Cap",neck="Sanctity Necklace",ear1="Infused Earring",ear2="Dawn Earring",
		body="Turms Harness",hands="Turms Mittens +1",ring1="Sheltered Ring",ring2="Meghanada Ring",
		    back={ name="Toutatis's Cape", augments={'INT+20','Eva.+20 /Mag. Eva.+20','"Fast Cast"+10','Mag. Evasion+15',}},
		waist="Flume Belt",legs="Turms Subligar",feet="Jute Boots +1"}



   sets.idle.PDT = {ammo="Staunch Tathlum +1",
		head="Malignance Chapeau",
		neck="Loricate Torque +1",
		Ear2="Odnowa Earring +1",
        body="Malignance Tabard",
		hands="Malignance gloves",
		left_ring	=	{name="Moonlight Ring", bag="wardrobe"}, -- I do this to prevent issues with lag sometimes if 2 ring are the same in same bag GS sometimes only equips 1 of them        
		right_ring	=	{name="Moonlight Ring", bag="wardrobe2"},
    back={ name="Toutatis's Cape", augments={'DEX+20','Accuracy+20 Attack+20','DEX+10','Crit.hit rate+10','Phys. dmg. taken-10%',}},
		--waist="Flume Belt",
		legs="Gleti's Breeches",
		feet="Malignance Boots"
		
		
		}

   sets.idle.MEVA = {ammo="Yamarang",
		head="Malignance Chapeau",neck="Warder's Charm +1",ear1="Eabani Earring",Ear2="Hearty Earring",
       body="Malignance Tabard",
		hands="Malignance Gloves",
		ring1="Vengeful Ring",ring2="Purity Ring",
              back={ name="Toutatis's Cape", augments={'INT+20','Eva.+20 /Mag. Eva.+20','"Fast Cast"+10','Mag. Evasion+15',}},
		waist="Carrier's Sash",legs="Turms Subligar",feet="Malignance Boots"
		}

   sets.idle.Regain = {ammo="Yamarang",
		head="Turms Cap",neck="Sanctity Necklace",ear1="Infused Earring",ear2="Dawn Earring",
		body="Gleti's Cuirass",hands="Gleti's Gauntlets",ring1="Sheltered Ring",ring2="Meghanada Ring",
		    back={ name="Toutatis's Cape", augments={'INT+20','Eva.+20 /Mag. Eva.+20','"Fast Cast"+10','Mag. Evasion+15',}},
		waist="Flume Belt",legs="Gleti's Breeches",feet="Gleti's Boots"}

   sets.idle.Regen = {ammo="Yamarang",
		head="Turms Cap",neck="Sanctity Necklace",ear1="Infused Earring",ear2="Dawn Earring",
		body="Turms Harness",hands="Turms Mittens +1",ring1="Sheltered Ring",ring2="Meghanada Ring",
		    back={ name="Toutatis's Cape", augments={'INT+20','Eva.+20 /Mag. Eva.+20','"Fast Cast"+10','Mag. Evasion+15',}},
		waist="Flume Belt",legs="Turms Subligar",feet="Jute Boots +1"}























    sets.idle.Town = {ammo="Yamarang",
        head="Turms Cap",neck="Loricate Torque +1",
		--ear1="Dudgeon Earring",ear2="Heartseeker Earring",
        body="Turms Harness",hands="Turms Mittens +1",ring1="Sheltered Ring",ring2="Meghanada Ring",
		back="Shadow Mantle",waist="Flume Belt",legs="Turms Subligar",feet="Jute Boots +1"}

    sets.idle.Weak = {ammo="Yamarang",
	head="Turms Cap",neck="Bathy Choker +1",ear1="Infused Earring",ear2="Dawn Earring",
		body="Turms Harness",hands="Turms Mittens +1",ring1="Sheltered Ring",ring2="Meghanada Ring",
		    back={ name="Toutatis's Cape", augments={'INT+20','Eva.+20 /Mag. Eva.+20','"Fast Cast"+10','Mag. Evasion+15',}},
		waist="Flume Belt",legs="Turms Subligar",feet="Jute Boots +1"}


    -- Defense sets

    sets.defense.Evasion = {
--	ammo="Amar Cluster",
ammo="Yamarang",
        head="Gleti's Mask",
		neck="Assassin's Gorget +2",
	ear1="Novia Earring",ear2="Eabani Earring",
       body="Malignance Tabard",
	   hands="Turms Mittens +1",
	   
		ring1="Ilabrat Ring",ring2="Moonlight Ring",
            back={ name="Toutatis's Cape", augments={'AGI+20','Eva.+20 /Mag. Eva.+20','Evasion+5','"Fast Cast"+10',}},
		waist="Reiki Yotai",legs="Gleti's Breeches",
		feet="Malignance Boots"
		}

    sets.defense.PDT = {
	--ammo="Iron Gobbet",
        head="Malignance Chapeau",
		--neck="Loricate Torque +1",
        body="Malignance Tabard",
		hands="Malignance gloves",
		left_ring	=	{name="Moonlight Ring", bag="wardrobe"}, -- I do this to prevent issues with lag sometimes if 2 ring are the same in same bag GS sometimes only equips 1 of them        
		right_ring	=	{name="Moonlight Ring", bag="wardrobe2"},
    back={ name="Toutatis's Cape", augments={'DEX+20','Accuracy+20 Attack+20','DEX+10','Crit.hit rate+10','Phys. dmg. taken-10%',}},
		--waist="Flume Belt",
		legs="Gleti's Breeches",
		feet="Malignance Boots"
		
			}

    sets.defense.MDT = {ammo="Demonry Stone",
        head="Malignance Chapeau",
		neck="Warder's Charm +1",
        body="Malignance Tabard",
		hands="Malignance gloves",
		ring1="Defending Ring",ring2="Shadow Ring",
        back="Engulfer Cape +1",waist="Flume Belt",legs="Iuitl Tights +1",feet="Malignance Boots"}

		sets.defense.MagicEvasion = {ammo="Yamarang",
        head="Malignance Chapeau",neck="Warder's Charm +1",ear1="Eabani Earring",Ear2="Hearty Earring",
       body="Malignance Tabard",
		hands="Malignance Gloves",
		ring1="Vengeful Ring",ring2="Purity Ring",
              back={ name="Toutatis's Cape", augments={'INT+20','Eva.+20 /Mag. Eva.+20','"Fast Cast"+10','Mag. Evasion+15',}},
		waist="Carrier's Sash",legs="Turms Subligar",feet="Malignance Boots"}

    --------------------------------------
    -- Melee sets
    --------------------------------------

		

	----------------------------------
	-- Engaged Sets (No Haste)
	----------------------------------
	-- Variations for TP weapon and (optional) offense/defense modes.  Code will fall back on previous
	-- sets if more refined versions aren't defined.
	-- If you create a set with both offense and defense modes, the offense mode should be first.
	-- EG: sets.engaged.Dagger.Accuracy.Evasion

	-- Acc 1145/1120 (???/???|??/??)) :: Acc 1186/1140 (???/???|???/???) :: Acc ??? (???/???)
	-- DW Total in Gear: 44~45 DW to cap
	sets.engaged = {ammo="Aurgelmir Orb +1",
		head="Taeon Chapeau",
		neck="Assassin's Gorget +2",
		ear1="Suppanomimi",ear2="Eabani Earring",
		body="Adhemar Jacket +1",
		hands="Floral Gauntlets",
		ring1="Hetairoi Ring",ring2="Gere Ring",
		    back={ name="Toutatis's Cape", augments={'DEX+20','Accuracy+20 Attack+20','DEX+10','"Store TP"+10','Occ. inc. resist. to stat. ailments+10',}},

		--back={ name="Toutatis's Cape", augments={'DEX+20','Accuracy+20 Attack+20','DEX+10','"Dual Wield"+6',}},
	--	back={ name="Toutatis's Cape", augments={'DEX+20','Accuracy+20 Attack+20','Crit.hit rate+10',}},
		waist="Windbuffet Belt +1",legs="Samnuha Tights",
		feet="Plunderer's Poulaines +3"
		}
		
	-- Acc Tier 1: 1166/1141 (Heishi/Ochu|Kikoku/Ochu) :: Acc 1207/1161 (???/???|????/????) :: Acc ??? (???/???)
	-- DW Total in Gear: 37 DW
	sets.engaged.Acc = set_combine(sets.engaged, {Ammo="Yamarang",neck="Combatant's Torque",ear2="Odnowa Earring +1"
	
	
													})

	-- Acc Tier 2: 1183/1158 (Heishi/Ochu|Kikoku/Ochu) :: Acc 1224/1178 (???/???|????/????) :: Acc ??? (???/???)
	-- DW Total in Gear: 37 DW
	sets.engaged.Acc2 = set_combine(sets.engaged.Acc, {ring1="Moonlight Ring",
	    feet={ name="Herculean Boots", augments={'Accuracy+25','"Triple Atk."+3',}}
		})
	
	-- Acc Tier 3: 1223/1198 (Heishi/Ochu|Kikoku/Ochu) :: Acc 1264/1218 (???/???|????/????) :: Acc ??? (???/???)
	-- DW Total in Gear: 20 DW
	sets.engaged.Acc3 = set_combine(sets.engaged.Acc2, {
			neck="Assassin's Gorget +2",
	        ring1="Ramuh Ring +1",
        ring2="Regal Ring",
        hands="Adhemar Wristbands +1",
        waist="Kentarch Belt +1",
	
				})
	
    sets.engaged.AM3 	   = sets.engaged
    sets.engaged.AM3.Acc = sets.engaged.Acc
    sets.engaged.AM3.Acc2 = sets.engaged.Acc2
    sets.engaged.AM3.Acc3 = sets.engaged.Acc3

	----------------------------------
	-- Defensive Sets
	----------------------------------
	--Flesh These "Hybrid" sets out?
    sets.NormalPDT =  sets.engaged.PDT
    sets.AccPDT =  sets.engaged.PDT
    sets.engaged.PDT 		= sets.defense.PDT
    sets.engaged.Acc.PDT 	= set_combine(sets.engaged.Acc, sets.defense.PDT)
    sets.engaged.Acc2.PDT 	= set_combine(sets.engaged.Acc2, sets.defense.PDT)
    sets.engaged.Acc3.PDT 	= set_combine(sets.engaged.Acc3, sets.defense.PDT)
    sets.engaged.AM3.PDT 	= set_combine(sets.engaged.AM3, sets.defense.PDT)
    sets.engaged.AM3.Acc.PDT = sets.engaged.Acc.PDT
    sets.engaged.AM3.Acc2.PDT = sets.engaged.Acc2.PDT
    sets.engaged.AM3.Acc3.PDT = sets.engaged.Acc3.PDT
    sets.engaged.HastePDT 	= sets.defense.PDT

	----------------------------------
    -- MaxHaste Sets (6%DW Needed)
	----------------------------------
	-- Acc 1084/1059 (Heishi/Ochu|Kikoku/Ochu)) :: Acc 1125/1079 (???/???|????/????) :: Acc ??? (???/???)
	-- DW Total in Gear: 6 DW
	sets.engaged.MaxHaste = {ammo="Aurgelmir Orb +1",
        head="Adhemar Bonnet +1",
		--head="Dampening Tam",
		neck="Assassin's Gorget +2",
		ear1="Sherida Earring",
		ear2="Dedition Earring",
		body="Pillager's Vest +3",
		hands="Adhemar Wristbands +1",
		ring1="Hetairoi Ring",ring2="Gere Ring",
		back={ name="Toutatis's Cape", augments={'DEX+20','Accuracy+20 Attack+20','DEX+10','"Store TP"+10','Occ. inc. resist. to stat. ailments+10',}},
		--back={ name="Toutatis's Cape", augments={'DEX+20','Accuracy+20 Attack+20','DEX+10','"Dual Wield"+6',}},
		waist="Reiki Yotai",
		--waist="Windbuffet Belt +1",
--		legs="Samnuha Tights",
		legs="Pillager's Culottes +3",
		feet="Plunderer's Poulaines +3"
		}
		
	-- Acc 1105/1080 (Heishi/Ochu|Kikoku/Ochu)) :: Acc 1146/1100 (???/???|????/????) :: Acc ??? (???/???)
	-- DW Total in Gear: 6 DW
    sets.engaged.Acc.MaxHaste = set_combine(sets.engaged.MaxHaste, {ear2="Telos Earring",})
	
	-- Acc 1151/1126 (Heishi/Ochu|Kikoku/Ochu)) :: Acc 1192/1146 (???/???|????/????) :: Acc ??? (???/???)
	-- DW Total in Gear: 6 DW
    sets.engaged.Acc2.MaxHaste = set_combine(sets.engaged.Acc.MaxHaste, {head="Dampening Tam",neck="Assassin's Gorget +2",ring1="Ramuh Ring +1",Ring2="Regal Ring",ear2="Telos Earring",
	--Body="Pillager's Vest +3",waist="Reiki Yotai",
	legs="Pillager's Culottes +3"})
	
	-- Acc 1211/1188 (Heishi/Ochu|Kikoku/Ochu)) :: Acc 1252/1208 (???/???|????/????) :: Acc ??? (???/???)
	-- DW Total in Gear: 6 DW
	sets.engaged.Acc3.MaxHaste = set_combine(sets.engaged.Acc2.MaxHaste, {head="Pillager's Bonnet +3",neck="Assassin's Gorget +2",
	hands="Adhemar Wristbands +1",
	ring2="Regal Ring"})
	
    sets.engaged.AM3.MaxHaste     = sets.engaged.MaxHaste
    sets.engaged.AM3.Acc.MaxHaste = sets.engaged.Acc.MaxHaste
    sets.engaged.AM3.Acc2.MaxHaste = sets.engaged.Acc2.MaxHaste
    sets.engaged.AM3.Acc3.MaxHaste = sets.engaged.Acc3.MaxHaste

    -- Defensive sets
    sets.engaged.PDT.MaxHaste 		= set_combine(sets.engaged.MaxHaste, sets.engaged.HastePDT)
    sets.engaged.Acc.PDT.MaxHaste 	= set_combine(sets.engaged.Acc.MaxHaste, sets.engaged.HastePDT)
    sets.engaged.Acc2.PDT.MaxHaste 	= set_combine(sets.engaged.Acc2.MaxHaste, sets.engaged.HastePDT)
    sets.engaged.Acc3.PDT.MaxHaste 	= set_combine(sets.engaged.Acc3.MaxHaste, sets.AccPDT)
    sets.engaged.AM3.PDT.MaxHaste = set_combine(sets.engaged.AM3.MaxHaste, sets.NormalPDT)
    sets.engaged.AM3.Acc.PDT.MaxHaste = sets.engaged.Acc.PDT.MaxHaste
    sets.engaged.AM3.Acc2.PDT.MaxHaste = sets.engaged.Acc2.PDT.MaxHaste
    sets.engaged.AM3.Acc3.PDT.MaxHaste = sets.engaged.Acc3.PDT.MaxHaste

	----------------------------------
    -- 35% Haste (~20-24%DW Needed)
	----------------------------------
	-- Acc 1095/1070 (Heishi/Ochu|Kikoku/Ochu)) :: Acc 1136/1099 (???/???|????/????) :: Acc ??? (???/???)
	-- DW Total in Gear: 25 DW
    sets.engaged.Haste_35 = set_combine(sets.engaged.MaxHaste, {
	ammo="Yamarang",
        head="Taeon Chapeau",
		neck="Assassin's Gorget +2",
		ear1="Sherida Earring",ear2="Eabani Earring",
        body="Adhemar Jacket +1",hands="Floral Gauntlets",ring1="Hetairoi Ring",ring2="Gere Ring",
		back={ name="Toutatis's Cape", augments={'DEX+20','Accuracy+20 Attack+20','DEX+10','"Dual Wield"+6',}},
		waist="Windbuffet Belt +1",legs="Samnuha Tights",
		feet="Plunderer's Poulaines +3"

	--waist="Reiki Yotai",
	--ear1="Suppanomimi",
	
	})
	
	-- Acc 1127/1102 (Heishi/Ochu|Kikoku/Ochu)) :: Acc 1168/1122 (???/???|????/????) :: Acc ??? (???/???)
	-- DW Total in Gear: 25 DW
    sets.engaged.Acc.Haste_35 = set_combine(sets.engaged.Acc.MaxHaste, {body="Adhemar Jacket +1",
		--waist="Reiki Yotai",
		ear1="Brutal Earring",})
	
	-- Acc 1159/1134 (Heishi/Ochu|Kikoku/Ochu)) :: Acc 1200/1154 (???/???|????/????) :: Acc ??? (???/???)
	-- DW Total in Gear: 25 DW
    sets.engaged.Acc2.Haste_35 = set_combine(sets.engaged.Acc2.MaxHaste,
		{	body="Adhemar Jacket +1",
	--	waist="Reiki Yotai"
	}
	)
	
	-- Acc 1217/1192 (Heishi/Ochu|Kikoku/Ochu)) :: Acc 1258/1212 (???/???|????/????) :: Acc ??? (???/???)
	-- DW Total in Gear: 25 DW
    sets.engaged.Acc3.Haste_35 = set_combine(sets.engaged.Acc3.MaxHaste, {})

    sets.engaged.AM3.Haste_35 	= sets.engaged.Haste_35
    sets.engaged.AM3.Acc.Haste_35 = sets.engaged.Acc.Haste_35
    sets.engaged.AM3.Acc2.Haste_35 = sets.engaged.Acc2.Haste_35
    sets.engaged.AM3.Acc3.Haste_35 = sets.engaged.Acc3.Haste_35

    sets.engaged.PDT.Haste_35 = set_combine(sets.engaged.Haste_35, sets.engaged.HastePDT)
    sets.engaged.Acc.PDT.Haste_35 = set_combine(sets.engaged.Acc.Haste_35, sets.engaged.HastePDT)
    sets.engaged.Acc2.PDT.Haste_35 = set_combine(sets.engaged.Acc2.Haste_35, sets.engaged.HastePDT)
    sets.engaged.Acc3.PDT.Haste_35 = set_combine(sets.engaged.Acc3.Haste_35, sets.engaged.AccPDT)

    sets.engaged.AM3.PDT.Haste_35 = set_combine(sets.engaged.AM3.Haste_35, sets.engaged.HastePDT)
    sets.engaged.AM3.Acc.PDT.Haste_35 = sets.engaged.Acc.PDT.Haste_35
    sets.engaged.AM3.Acc2.PDT.Haste_35 = sets.engaged.Acc2.PDT.Haste_35
    sets.engaged.AM3.Acc3.PDT.Haste_35 = sets.engaged.Acc3.PDT.Haste_35

	----------------------------------
    -- 30% Haste (~30%DW Needed)
	----------------------------------
	-- Acc  (Heishi/Ochu|Kikoku/Ochu)) :: Acc  (???/???|????/????) :: Acc ??? (???/???)
	-- DW Total in Gear: 25 DW
    sets.engaged.Haste_30 = {ammo="Yamarang",
        Head="Adhemar Bonnet +1",
		--head="Taeon Chapeau",
		neck="Assassin's Gorget +2",ear1="Sherida Earring",ear2="Brutal Earring",
        body="Adhemar Jacket +1",hands="Floral Gauntlets",ring1="Hetairoi Ring",ring2="Gere Ring",
   		back={ name="Toutatis's Cape", augments={'DEX+20','Accuracy+20 Attack+20','DEX+10','"Dual Wield"+6',}},
		waist="Reiki Yotai",legs="Samnuha Tights",
		feet="Plunderer's Poulaines +3"
		}
	
	-- +22 Acc
    sets.engaged.Acc.Haste_30 = set_combine(sets.engaged.Haste_30, {
					ear1="Sherida Earring",ear2="Cessance Earring",
					ring1="Ilabrat Ring"})
	
	-- +
    sets.engaged.Acc2.Haste_30 = set_combine(sets.engaged.Acc.Haste_30, {ring2="Regal Ring",legs="Pillager's Culottes +3"})
	
    sets.engaged.Acc3.Haste_30 = set_combine(sets.engaged.Acc2.Haste_30, {head="Pillager's Bonnet +3",neck="Assassin's Gorget +2",waist="Reiki Yotai",
	    

		--feet={ name="Herculean Boots", augments={'Accuracy+25','"Triple Atk."+3',}}
	
	})

    sets.engaged.AM3.Haste_30 = sets.engaged.Haste_30
    sets.engaged.AM3.Acc.Haste_30 = sets.engaged.Acc.Haste_30
    sets.engaged.AM3.Acc2.Haste_30 = sets.engaged.Acc2.Haste_30
    sets.engaged.AM3.Acc3.Haste_30 = sets.engaged.Acc3.Haste_30

    sets.engaged.PDT.Haste_30 = set_combine(sets.engaged.Haste_30, sets.engaged.HastePDT)
    sets.engaged.Acc.PDT.Haste_30 = set_combine(sets.engaged.Acc.Haste_30, sets.engaged.HastePDT)
    sets.engaged.Acc2.PDT.Haste_30 = set_combine(sets.engaged.Acc2.Haste_30, sets.engaged.HastePDT)
    sets.engaged.Acc3.PDT.Haste_30 = set_combine(sets.engaged.Acc3.Haste_30, sets.engaged.AccPDT)

    sets.engaged.AM3.PDT.Haste_30 = set_combine(sets.engaged.AM3.Haste_30, sets.engaged.HastePDT)
    sets.engaged.AM3.Acc.PDT.Haste_30 = sets.engaged.Acc.PDT.Haste_30
    sets.engaged.AM3.Acc2.PDT.Haste_30 = sets.engaged.Acc2.PDT.Haste_30
    sets.engaged.AM3.Acc3.PDT.Haste_30 = sets.engaged.Acc3.PDT.Haste_30


    ----------------------------------
    -- 15% Haste (~32%DW Needed)
	----------------------------------
	-- Acc 1145/1120 (Heishi/Ochu|Kikoku/Ochu)) :: Acc 1186/1140 (???/???|????/????) :: Acc ??? (???/???)
	-- DW Total in Gear: 32 DW
    sets.engaged.Haste_15 = {
	ammo="Yamarang",
		head="Taeon Chapeau",
		neck="Assassin's Gorget +2",ear1="Suppanomimi",ear2="Eabani Earring",
		body="Adhemar Jacket +1",hands="Floral Gauntlets",ring1="Hetairoi Ring",ring2="Gere Ring",
				back={ name="Toutatis's Cape", augments={'DEX+20','Accuracy+20 Attack+20','DEX+10','"Dual Wield"+6',}},
		waist="Reiki Yotai",legs="Samnuha Tights",
		feet="Plunderer's Poulaines +3"
	}
		
	-- Acc Tier 1: 1166/1141 (Heishi/Ochu|Kikoku/Ochu) :: Acc 1207/1161 (???/???|????/????) :: Acc ??? (???/???)
	-- DW Total in Gear: 32 DW
	sets.engaged.Acc.Haste_15 = set_combine(sets.engaged.Haste_15, {neck="Assassin's Gorget +2",ear2="Odnowa Earring +1"})

	-- Acc Tier 2: 1183/1158 (Heishi/Ochu|Kikoku/Ochu) :: Acc 1224/1178 (???/???|????/????) :: Acc ??? (???/???)
	-- DW Total in Gear: 32 DW
	sets.engaged.Acc2.Haste_15 = set_combine(sets.engaged.Acc.Haste_15, {ring1="Ilabrat Ring",legs="Pillager's Culottes +3"})
	
	-- Acc Tier 3: 1223/1198 (Heishi/Ochu|Kikoku/Ochu) :: Acc 1264/1218 (???/???|????/????) :: Acc ??? (???/???)
	-- DW Total in Gear: 20 DW
	sets.engaged.Acc3.Haste_15 = set_combine(sets.engaged.Acc2.Haste_15, {ear1="Odnowa Earring +1",ring2="Regal Ring",waist="Olseni Belt"})
    
    sets.engaged.AM3.Haste_15 = sets.engaged.Haste_15
    sets.engaged.AM3.Acc.Haste_15 = sets.engaged.Acc.Haste_15
    sets.engaged.AM3.Acc2.Haste_15 = sets.engaged.Acc2.Haste_15
    sets.engaged.AM3.Acc3.Haste_15 = sets.engaged.Acc3.Haste_15
    
    sets.engaged.PDT.Haste_15 = set_combine(sets.engaged.Haste_15, sets.engaged.HastePDT)
    sets.engaged.Acc.PDT.Haste_15 = set_combine(sets.engaged.Acc.Haste_15, sets.engaged.HastePDT)
    sets.engaged.Acc2.PDT.Haste_15 = set_combine(sets.engaged.Acc2.Haste_15, sets.engaged.HastePDT)
    sets.engaged.Acc3.PDT.Haste_15 = set_combine(sets.engaged.Acc3.Haste_15, sets.engaged.AccPDT)
    
    sets.engaged.AM3.PDT.Haste_15 = set_combine(sets.engaged.AM3.Haste_15, sets.engaged.HastePDT)
    sets.engaged.AM3.Acc.PDT.Haste_15 = sets.engaged.Acc.PDT.Haste_15
    sets.engaged.AM3.Acc2.PDT.Haste_15 = sets.engaged.Acc2.PDT.Haste_15
    sets.engaged.AM3.Acc3.PDT.Haste_15 = sets.engaged.Acc3.PDT.Haste_15
   
		
		
		
		
		
		
		
		
		
		
    sets.engaged.Evasion = {
	ammo="Yamarang",
        head="Malignance Chapeau",
		neck="Assassin's Gorget +2",
	--	neck="Loricate Torque +1",
		ear1="Sherida Earring",ear2="Assuage Earring",
       body="Malignance Tabard",
	   hands="Turms Mittens +1",
		ring1="Ilabrat Ring",ring2="Moonlight Ring",
 --       back="Shadow Mantle",
		back={ name="Toutatis's Cape", augments={'INT+20','Eva.+20 /Mag. Eva.+20','"Fast Cast"+10','Mag. Evasion+15',}},
		waist="Reiki Yotai",legs="Malignance Tights",
		feet="Malignance Boots"
		}
    sets.engaged.Acc.Evasion = {
	ammo="Yamarang",
        head="Dampening Tam",		
		neck="Assassin's Gorget +2",
		ear1="Dudgeon Earring",ear2="Heartseeker Earring",
        body={ name="Herculean Vest", augments={'Pet: STR+7','STR+4','Weapon skill damage +9%','Mag. Acc.+17 "Mag.Atk.Bns."+17',}},
		hands={ name="Herculean Gloves", augments={'MND+2','Weapon skill damage +1%','"Treasure Hunter"+2','Accuracy+5 Attack+5',}},
		ring1="Hetairoi Ring",ring2="Regal Ring",
        back="Archon Cape",waist="Metalsinger Belt",legs="Taeon Tights",
		feet={ name="Herculean Boots", augments={'Accuracy+27','Phys. dmg. taken -4%','DEX+7',}}
		}

    sets.engaged.PDT = {
		ammo="Yamarang",
		--Adhemar Bonnet +1 if the cape is changed to pdt 10%
    head="Malignance Chapeau",
    body="Malignance Tabard",
    hands="Malignance gloves",
    legs="Meg. Chausses +2",
    feet="Malignance Boots",
	--feet={ name="Herculean Boots", augments={'Accuracy+27','Phys. dmg. taken -4%','DEX+7',}},
    neck="Asn. Gorget +2",
    waist="Reiki Yotai",
    left_ear="Sherida Earring",
    right_ear="Telos Earring",
    left_ring="Moonlight Ring",
    right_ring="Moonlight Ring",
	    back={ name="Toutatis's Cape", augments={'DEX+20','Accuracy+20 Attack+20','DEX+10','Crit.hit rate+10','Phys. dmg. taken-10%',}},

		}
    sets.engaged.Acc.PDT = {ammo="Seething Bomblet +1",
        head="Iuitl Headgear +1",neck="Loricate Torque +1",ear1="Dudgeon Earring",ear2="Heartseeker Earring",
        body={ name="Herculean Vest", augments={'Pet: STR+7','STR+4','Weapon skill damage +9%','Mag. Acc.+17 "Mag.Atk.Bns."+17',}},
		hands="Iuitl Wristbands +1",ring1="Defending Ring",ring2="Moonlight Ring",
        back="Archon Cape",waist="Metalsinger Belt",legs="Meghanada Chausses +2",feet={ name="Herculean Boots", augments={'Accuracy+27','Phys. dmg. taken -4%','DEX+7',}}
		}
    sets.engaged.MDT = {ammo="Yamarang",
        head="Dampening Tam",neck="Loricate Torque +1",ear1="Dudgeon Earring",ear2="Heartseeker Earring",
        body={ name="Herculean Vest", augments={'Pet: STR+7','STR+4','Weapon skill damage +9%','Mag. Acc.+17 "Mag.Atk.Bns."+17',}},
		hands="Floral Gauntlets",ring1="Defending Ring",ring2="Shadow Ring",
        back="Engulfer Cape +1",waist="Reiki Yotai",legs="Ta'lab Trousers",feet={ name="Herculean Boots", augments={'Accuracy+27','Phys. dmg. taken -4%','DEX+7',}}
		}
    sets.engaged.Acc.MDT = {ammo="Seething Bomblet +1",
        head="Dampening Tam",neck="Loricate Torque +1",ear1="Dudgeon Earring",ear2="Heartseeker Earring",
        body={ name="Herculean Vest", augments={'Pet: STR+7','STR+4','Weapon skill damage +9%','Mag. Acc.+17 "Mag.Atk.Bns."+17',}},
		hands="Floral Gauntlets",ring1="Defending Ring",ring2="Moonlight Ring",
        back="Archon Cape",waist="Metalsinger Belt",legs="Ta'lab Trousers",feet="Malignance boots",
		}

end


-------------------------------------------------------------------------------------------------------------------
-- Job-specific hooks for standard casting events.
-------------------------------------------------------------------------------------------------------------------

-- Run after the general precast() is done.
function job_post_precast(spell, action, spellMap, eventArgs)
    if spell.english == 'Aeolian Edge' and state.TreasureMode.value ~= 'None' then
        equip(sets.TreasureHunter)
    elseif spell.english=='Sneak Attack' or spell.english=='Trick Attack' or spell.type == 'WeaponSkill' then
        if state.TreasureMode.value == 'SATA' or state.TreasureMode.value == 'Fulltime' then
            equip(sets.TreasureHunter)
        end
    end
end

-- Run after the general midcast() set is constructed.
function job_post_midcast(spell, action, spellMap, eventArgs)
    if state.TreasureMode.value ~= 'None' and spell.action_type == 'Ranged Attack' then
        equip(sets.TreasureHunter)
    end
end

-- Set eventArgs.handled to true if we don't want any automatic gear equipping to be done.
function job_aftercast(spell, action, spellMap, eventArgs)
    -- Weaponskills wipe SATA/Feint.  Turn those state vars off before default gearing is attempted.
    if spell.type == 'WeaponSkill' and not spell.interrupted then
        state.Buff['Sneak Attack'] = false
        state.Buff['Trick Attack'] = false
        state.Buff['Feint'] = false
    end
end

-- Called after the default aftercast handling is complete.
function job_post_aftercast(spell, action, spellMap, eventArgs)
    -- If Feint is active, put that gear set on on top of regular gear.
    -- This includes overlaying SATA gear.
    check_buff('Feint', eventArgs)
end

-------------------------------------------------------------------------------------------------------------------
-- Job-specific hooks for non-casting events.
-------------------------------------------------------------------------------------------------------------------

-- Called when a player gains or loses a buff.
-- buff == buff gained or lost
-- gain == true if the buff was gained, false if it was lost.
function job_buff_change(buff, gain)
    if state.Buff[buff] ~= nil then
        if not midaction() then
            handle_equipping_gear(player.status)
        end
    end
			if S{'haste', 'march', 'mighty guard', 'embrava', 'haste samba', 'geo-haste', 'indi-haste'}:contains(buff:lower()) then
					determine_haste_group()
					if not midaction() then
            handle_equipping_gear(player.status)
					end
			end
	
	
end


-------------------------------------------------------------------------------------------------------------------
-- User code that supplements standard library decisions.
-------------------------------------------------------------------------------------------------------------------

function get_custom_wsmode(spell, spellMap, defaut_wsmode)
    local wsmode

    if state.Buff['Sneak Attack'] then
        wsmode = 'SA'
    end
    if state.Buff['Trick Attack'] then
        wsmode = (wsmode or '') .. 'TA'
    end

    return wsmode
end


-- Called any time we attempt to handle automatic gear equips (ie: engaged or idle gear).
function job_handle_equipping_gear(playerStatus, eventArgs)
    -- Check that ranged slot is locked, if necessary
    check_range_lock()

    -- Check for SATA when equipping gear.  If either is active, equip
    -- that gear specifically, and block equipping default gear.
    check_buff('Sneak Attack', eventArgs)
    check_buff('Trick Attack', eventArgs)
end


function customize_idle_set(idleSet)
    if player.hpp < 80 then
        idleSet = set_combine(idleSet, sets.ExtraRegen)
    end

    return idleSet
end


function customize_melee_set(meleeSet)
    if state.TreasureMode.value == 'Fulltime' then
        meleeSet = set_combine(meleeSet, sets.TreasureHunter)
    end

    return meleeSet
end
	

-- Called by the 'update' self-command.
function job_update(cmdParams, eventArgs)
    
--	    select_ammo()
	--select_movement_feet()
    determine_haste_group()
    update_combat_form()
    run_sj = player.sub_job == 'RUN' or false
	
	th_update(cmdParams, eventArgs)
end

-- Function to display the current relevant user state when doing an update.
-- Return true if display was handled, and you don't want the default info shown.
function display_current_job_state(eventArgs)
    local msg = 'Melee'
    
    if state.CombatForm.has_value then
        msg = msg .. ' (' .. state.CombatForm.value .. ')'
    end
    
    msg = msg .. ': '
    
    msg = msg .. state.OffenseMode.value
    if state.HybridMode.value ~= 'Normal' then
        msg = msg .. '/' .. state.HybridMode.value
    end
    msg = msg .. ', WS: ' .. state.WeaponskillMode.value
    
    if state.DefenseMode.value ~= 'None' then
        msg = msg .. ', ' .. 'Defense: ' .. state.DefenseMode.value .. ' (' .. state[state.DefenseMode.value .. 'DefenseMode'].value .. ')'
    end
    
    if state.Kiting.value == true then
        msg = msg .. ', Kiting'
    end

    if state.PCTargetMode.value ~= 'default' then
        msg = msg .. ', Target PC: '..state.PCTargetMode.value
    end

    if state.SelectNPCTargets.value == true then
        msg = msg .. ', Target NPCs'
    end
    
    msg = msg .. ', TH: ' .. state.TreasureMode.value

    add_to_chat(122, msg)

    eventArgs.handled = true
end

-------------------------------------------------------------------------------------------------------------------
-- Utility functions specific to this job.
-------------------------------------------------------------------------------------------------------------------

-- State buff checks that will equip buff gear and mark the event as handled.
function check_buff(buff_name, eventArgs)
    if state.Buff[buff_name] then
        equip(sets.buff[buff_name] or {})
        if state.TreasureMode.value == 'SATA' or state.TreasureMode.value == 'Fulltime' then
            equip(sets.TreasureHunter)
        end
        eventArgs.handled = true
    end
end


-- Check for various actions that we've specified in user code as being used with TH gear.
-- This will only ever be called if TreasureMode is not 'None'.
-- Category and Param are as specified in the action event packet.
function th_action_check(category, param)
    if category == 2 or -- any ranged attack
        --category == 4 or -- any magic action
        (category == 3 and param == 30) or -- Aeolian Edge
        (category == 6 and info.default_ja_ids:contains(param)) or -- Provoke, Animated Flourish
        (category == 14 and info.default_u_ja_ids:contains(param)) -- Quick/Box/Stutter Step, Desperate/Violent Flourish
        then return true
    end
end


-- Function to lock the ranged slot if we have a ranged weapon equipped.
function check_range_lock()
    if player.equipment.range ~= 'empty' then
        disable('range', 'ammo')
    else
        enable('range', 'ammo')
    end
end


-- Select default macro book on initial load or subjob change.
function select_default_macro_book()
    -- Default macro set/book
    if player.sub_job == 'DNC' then
        set_macro_page(1, 1)
    elseif player.sub_job == 'WAR' then
        set_macro_page(1, 1)
    elseif player.sub_job == 'NIN' then
        set_macro_page(1, 1)
    else
        set_macro_page(1, 1)
    end
end
------ Langly additions---
--Use this for mighty strikes sets?
function update_combat_form()
    if state.Buff.AM3 then
        state.CombatForm:set('AM3')
    else
        state.CombatForm:reset()
    end
end
function determine_haste_group()
   
	classes.CustomMeleeGroups:clear()
	h = 0
	-- Spell Haste 15/30
	if buffactive[33] then
		if state.HasteMode.value == 'Haste I' then
			h = h + 15
		elseif state.HasteMode.value == 'Haste II' then
			h = h + 30
		end
	end
	-- Geo Haste 30
	if buffactive[580] then
		h = h + 30
	end
	-- Mighty Guard 15
	if buffactive[604] then
		h = h + 15
	end
	-- Embrava 20
	if buffactive.embrava then
		h = h + 20
	end
	-- March(es) 
	if buffactive.march then
		if state.MarchMode.value == 'Honor' then
			if buffactive.march == 2 then
				h = h + 27 + 16
			elseif buffactive.march == 1 then
				h = h + 16
			elseif buffactive.march == 3 then
				h = h + 27 + 17 + 16
			end
		elseif state.MarchMode.value == 'Trusts' then
			if buffactive.march == 2 then
				h = h + 26
			elseif buffactive.march == 1 then
				h = h + 16
			elseif buffactive.march == 3 then
				h = h + 27 + 17 + 16
			end
		elseif state.MarchMode.value == '7' then
			if buffactive.march == 2 then
				h = h + 27 + 17
			elseif buffactive.march == 1 then
				h = h + 27
			elseif buffactive.march == 3 then
				h = h + 27 + 17 + 16
			end
		elseif state.MarchMode.value == '3' then
			if buffactive.march == 2 then
				h = h + 13.5 + 20.6
			elseif buffactive.march == 1 then
				h = h + 20.6
			elseif buffactive.march == 3 then
				h = h + 27 + 17 + 16
			end
		end
	end

	-- Determine CustomMeleeGroups
	if h >= 15 and h < 30 then 
		classes.CustomMeleeGroups:append('Haste_15')
		add_to_chat('Haste Group: 15% -- From Haste Total: '..h)
	elseif h >= 30 and h < 35 then 
		classes.CustomMeleeGroups:append('Haste_30')
		add_to_chat('Haste Group: 30% -- From Haste Total: '..h)
	elseif h >= 35 and h < 40 then 
		classes.CustomMeleeGroups:append('Haste_35')
		add_to_chat('Haste Group: 35% -- From Haste Total: '..h)
	elseif h >= 40 then
		classes.CustomMeleeGroups:append('MaxHaste')
		add_to_chat('Haste Group: Max -- From Haste Total: '..h)
	end
end
