local useThinkHook = false;

IncludeScript("boxfox.utils.nut", this);
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
            weapon.AddAttribute("damage bonus", 2, -1);
            weapon.AddAttribute("mark for death", 1, -1);
            break;
        case 348: // Sharpened Volcano Fragment
            weapon.RemoveAttribute("Set DamageType Ignite");
            weapon.AddAttribute("Set DamageType Ignite", 0, -1);
            weapon.AddAttribute("bleeding duration", 7, -1);
            break;
    }
}

function OnGameEvent_player_hurt(p) {
    local itemIndex = null;
    local weapon = null;
    local ply = GetPlayerFromUserID(p.attacker);
    local user = GetPlayerFromUserID(p.userid);
    
    if ( !ply ) { return; }
    weapon = ply.GetActiveWeapon()

    if ( weapon ) {
        itemIndex = NetProps.GetPropInt(ply.GetActiveWeapon(), "m_AttributeManager.m_Item.m_iItemDefinitionIndex");
        switch(itemIndex) {
            case 173:
                ply.AddCondEx(Constants.ETFCond.TF_COND_PREVENT_DEATH, 3, ply);
                ply.AddCondEx(Constants.ETFCond.TF_COND_MEDIGUN_UBER_BULLET_RESIST, 3, ply);
                break;
            case 307:
                ply.TakeDamage(9999, Constants.FDmgType.DMG_DISSOLVE, ply);
                break;
        }
    }
}

function OnGameEvent_post_inventory_application(p) {
    local ply = GetPlayerFromUserID(p.userid)
    if ( !ply ) { return; }

    for ( local i = 0; i < 7; i++ ) {
        local wep = NetProps.GetPropEntityArray(ply, "m_hMyWeapons", i)
        if ( wep != null ) {
            processWeapon(wep)
        }
    }
}

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