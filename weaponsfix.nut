local useThinkHook = true;

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
        case 457: // The Postal Pummeler
            weapon.AddAttribute("single wep deploy time decreased", 0.7, -1);
            weapon.AddAttribute("health from healers reduced", 0.75, -1);
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
            case 457:
                if ( target && target != ply ) {
                    local dir = ply.EyeAngles().Forward();
                    p.damage = p.damage * 0.70;

                    ply.SetAbsVelocity( Vector(0, 0, 300) );
                    ply.ApplyAbsVelocityImpulse( dir * -200 );

                    target.SetAbsVelocity( Vector(0, 0, 300) );
                    target.ApplyAbsVelocityImpulse( dir * 200 );

                    ply.TakeDamageEx(ply, ply, weapon, Vector(0,0,0), Vector(0,0,0), target.GetMaxHealth() * 0.10, Constants.FDmgType.DMG_BLAST);
                }
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

function processAttack(ply) {
    local weapon = ply.GetActiveWeapon();
    local itemIndex = NetProps.GetPropInt(weapon, "m_AttributeManager.m_Item.m_iItemDefinitionIndex");
    local lookDir = ply.EyeAngles().Forward();
    
    if ( itemIndex == 457 ) {
        if ( TraceLine(ply.EyePosition(), ply.EyePosition() + (lookDir * 70), ply) < 1 ) {
            local force = (lookDir * -525);
            ply.SetAbsVelocity( Vector(0, 0, 200) );
            ply.ApplyAbsVelocityImpulse( Vector(force.x, force.y, force.z * 0.15) );

            ply.DropFlag(true);
            ply.RemoveCond(Constants.ETFCond.TF_COND_HEALTH_BUFF);
            ply.TakeDamageEx(ply, ply, weapon, Vector(0,0,0), Vector(0,0,0), ply.GetMaxHealth() * 0.25, Constants.FDmgType.DMG_BLAST);
        }
    }
}

function hookThink(){
    local ply = null
    while ( ply = Entities.FindByClassname(ply, "player") ) {
        local iButtons = NetProps.GetPropInt(ply, "m_nButtons");
        if ( (iButtons & Constants.FButtons.IN_ATTACK) && !getInScope(ply, "isAttacking") ) {
            processAttack(ply)
            setInScope(ply, "isAttacking", true);
        }
        if ( !(iButtons & Constants.FButtons.IN_ATTACK) && getInScope(ply, "isAttacking") ) {
            setInScope(ply, "isAttacking", null);
        }
    }
}

if ( useThinkHook ) {
    createThink(hookThink);
}

__CollectGameEventCallbacks(this);
