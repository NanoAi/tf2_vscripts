clearThink();
IncludeScript("weapons_dir.nut", this);

function onClassDamage(ply) {
    if ( ply.IsPlayer() ) {
        local plyClass = ply.GetPlayerClass(); 
        switch(plyClass) {
            case Constants.ETFClass.TF_CLASS_PYRO:
                ply.AddCustomAttribute("move speed bonus", 1.15, 1);
                break;
        }
    }
}

hook.Add("sh_OnTakeDamage", "weaponsfix.nut", function(p) {
    local itemIndex = null;
    local ply = p.attacker;
    local target = p.const_entity;
    local dmgTotal = p.damage + (p.damage_bonus || 0);
    
    if ( !verifyEntity(ply) ) { return; }
    if ( p.weapon ) {
        onClassDamage(ply);
        processDamage(ply, target, dmgTotal, p);
    }
});

function applyRebalance(p){ 
    local ply = GetPlayerFromUserID(p.userid)
    if ( !verifyEntity(ply) ) { return; }

    ply.RemoveCond(Constants.ETFCond.TF_COND_HALLOWEEN_TINY);
    setInScope(ply, "recentHits", []);
    setInScope(ply, "dragonsFuryBuff", null);

    for ( local i = 0; i < 7; i++ ) {
        local wep = NetProps.GetPropEntityArray(ply, "m_hMyWeapons", i)
        if ( verifyEntity(wep) ) {
            local id = getItemIndex(wep);
            loadFromId(ply, wep);
        }
    }
}

hook.Add("ge_post_inventory_application", "weaponsfix.nut", applyRebalance);
hook.Add("ge_player_spawn", "weaponsfix.nut", applyRebalance);

function onInAttack(ply, type) {
    local weapon = ply.GetActiveWeapon();
    local lookDir = ply.EyeAngles().Forward();
    processAttack(ply, weapon, lookDir, type);
}

function hookThink(){
    local ply = null
    while ( ply = Entities.FindByClassname(ply, "player") ) {
        local iButtons = NetProps.GetPropInt(ply, "m_nButtons");
        local attack1 = (iButtons & Constants.FButtons.IN_ATTACK);
        local attack2 = (iButtons & Constants.FButtons.IN_ATTACK2);

        if ( !getInScope(ply, "isAttacking") ) {
            if ( attack1 ) {
                onInAttack(ply, 1);
                setInScope(ply, "isAttacking", true);
            }

            if ( attack2 ) {
                onInAttack(ply, 2);
                setInScope(ply, "isAttacking", true);
            }
        }

        if ( !attack1 && !attack2 && getInScope(ply, "isAttacking") ) {
            setInScope(ply, "isAttacking", null);
        }
    }
}

createThink(hookThink);
job.Create();

__CollectGameEventCallbacks(this);
SendToServerConsole("mp_restartgame_immediate 1");
