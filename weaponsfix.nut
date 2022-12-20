local useThinkHook = false;

clearThink();

function processWeapon( weapon ) {
    //ref: https://wiki.alliedmods.net/Team_fortress_2_item_definition_indexes
    //ref: https://wiki.teamfortress.com/wiki/List_of_item_attributes
    local itemIndex = getItemIndex(weapon);
    switch(itemIndex) {
        case 40: // Backburgner
            weapon.RemoveAttribute("airblast cost increased");
            weapon.AddAttribute("airblast cost increased", 1, -1);
            break;
        case 215: // Degreaser
            weapon.RemoveAttribute("airblast cost increased");
            weapon.AddAttribute("airblast cost increased", 1, -1);
            break;
        case 173: // VitaSaw
            weapon.AddAttribute("single wep deploy time decreased", 0.8, -1);
            weapon.AddAttribute("max health additive penalty", 0.2, -1);
            break;
        case 810: // Red Tape Recorder
            weapon.RemoveAttribute("move speed bonus");
            weapon.AddAttribute("move speed bonus", 1.2, -1);
            break;
        case 307: // Ullapool Caber
            weapon.RemoveAttribute("damage bonus");
            weapon.AddAttribute("mark for death", 1, -1);
            break;
        case 348: // Sharpened Volcano Fragment
            weapon.RemoveAttribute("Set DamageType Ignite");
            weapon.AddAttribute("Set DamageType Ignite", 0, -1);
            weapon.AddAttribute("bleeding duration", 7, -1);
            break;
    }
}

function onClassDamage(ply) {
    local plyClass = ply.GetPlayerClass(); 
    switch(plyClass) {
        case Constants.ETFClass.TF_CLASS_PYRO:
            ply.AddCustomAttribute("move speed bonus", 1.15, 1);
            break;
    }
}

hook.Add("sh_OnTakeDamage", "weaponsfix.nut", function(p) {
    local itemIndex = null;
    local ply = p.attacker;
    local target = p.const_entity;
    
    if ( !ply ) { return; }
    if ( p.weapon ) {
        onClassDamage(ply);
        itemIndex = NetProps.GetPropInt(p.weapon, "m_AttributeManager.m_Item.m_iItemDefinitionIndex");
        switch(itemIndex) {
            case 173:
                ply.AddCondEx(Constants.ETFCond.TF_COND_PREVENT_DEATH, 3, ply);
                ply.AddCondEx(Constants.ETFCond.TF_COND_MEDIGUN_UBER_BULLET_RESIST, 3, ply);
                break;
            case 307:
                p.weapon.Kill();
                p.damage = p.damage * 2;
                ply.SetHealth(2);
                ply.TakeDamage(999, Constants.FDmgType.DMG_DISSOLVE, ply);
                break;
        }
    }
});

hook.Add("ge_post_inventory_application", "weaponsfix.nut", function(p) {
    local ply = GetPlayerFromUserID(p.userid)
    if ( !ply ) { return; }

    for ( local i = 0; i < 7; i++ ) {
        local wep = NetProps.GetPropEntityArray(ply, "m_hMyWeapons", i)
        if ( wep != null ) {
            processWeapon(wep)
        }
    }
});

function hookThink(){
    local ply = null
    while ( ply = Entities.FindByClassname(ply, "player") ) {
        // Create NetProps for Degreaser.
    }
}

if ( useThinkHook ) {
    createThink(hookThink);
}

__CollectGameEventCallbacks(this);