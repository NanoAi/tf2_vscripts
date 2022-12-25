local useThinkHook = true;

clearThink();

function processWeapon( ply, weapon ) {
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
            weapon.AddAttribute("SET BONUS: calling card on kill", 4, -1);
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
        case 1178: // Dragon's Fury
            weapon.AddAttribute("no crit boost", 1, -1);
            weapon.AddAttribute("max health additive bonus", 25, -1);
            weapon.AddAttribute("airblast cost increased", 300, -1);
            break;
        case 741: // Rainblower
            weapon.AddAttribute("health from healers reduced", 0.75, -1);
            weapon.AddAttribute("patient overheal penalty", 0, -1);
            
            weapon.AddAttribute("airblast cost increased", 5, -1);
            weapon.AddAttribute("bombinomicon effect on death", 1, -1);
            weapon.AddAttribute("charged airblast", 1, -1);

            weapon.AddAttribute("flame life bonus", 1.25, -1);
            weapon.AddAttribute("slow enemy on hit", 0.50, -1);

            job.Add(function(){
                if ( !ply.InCond(Constants.ETFCond.TF_COND_HALLOWEEN_TINY) ) {
                    ply.AddCond(Constants.ETFCond.TF_COND_HALLOWEEN_TINY);
                }
            });
            break;
        case 1098: // The Classic (Sniper)
            weapon.AddAttribute("mult sniper charge after bodyshot", 0.1, -1);
            weapon.AddAttribute("crit vs disguised players", 1, -1);
            weapon.AddAttribute("explosive sniper shot", 1, -1);
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

function rhPush(ply, target, weapon) {
    local recentHits = getInScope(ply, "recentHits");
    local data = {
        target = target,
        weapon = weapon,
        time = Time()
    }
    recentHits.push(data);
    if ( recentHits.len() > 4 ) {
        recentHits.pop(); // Remove a single value.
    }
    setInScope(ply, "recentHits", recentHits);
}

function rhGet(ply) {
    return getInScope(ply, "recentHits");
}

hook.Add("sh_OnTakeDamage", "weaponsfix.nut", function(p) {
    local itemIndex = null;
    local ply = p.attacker;
    local target = p.const_entity;
    local dmgTotal = p.damage + (p.damage_bonus || 0);
    
    if ( !ply ) { return; }
    if ( p.weapon ) {
        onClassDamage(ply);
        itemIndex = NetProps.GetPropInt(p.weapon, "m_AttributeManager.m_Item.m_iItemDefinitionIndex");
        switch(itemIndex) {
            case 1098: // The Classic (Sniper)
                if ( (target && target.IsPlayer()) && (target.GetHealth() - dmgTotal) > 0 ) {
                    ply.AddCondEx(Constants.ETFCond.TF_COND_STEALTHED_USER_BUFF, 3, ply);
                }
                break;
            case 1178:
                if ( target && target.IsPlayer() ) {
                    rhPush(ply, target, p.weapon);
                }
                break;
            case 215:
                if ( target && target.IsPlayer() ) {
                    local condA = target.InCond(Constants.ETFCond.TF_COND_GAS);
                    local condB = target.InCond(Constants.ETFCond.TF_COND_KNOCKED_INTO_AIR);
                    local condC = target.InAirDueToExplosion() || target.InAirDueToKnockback();
                    if ( condA || condB || condC ) {
                        if ( !p.damage_bonus ) p.damage_bonus = 0;
                        p.damage_bonus = p.damage_bonus + (p.damage * 0.45);
                        p.damage_bonus_provider = ply;
                        p.crit_type = 1;
                    }
                }
                break;
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
                }
                break;
        }
    }
});

function applyRebalance(p){ 
    local ply = GetPlayerFromUserID(p.userid)
    if ( !ply ) { return; }

    ply.RemoveCond(Constants.ETFCond.TF_COND_HALLOWEEN_TINY);
    setInScope(ply, "recentHits", []);

    for ( local i = 0; i < 7; i++ ) {
        local wep = NetProps.GetPropEntityArray(ply, "m_hMyWeapons", i)
        if ( wep != null ) {
            processWeapon(ply, wep)
        }
    }
}

hook.Add("ge_post_inventory_application", "weaponsfix.nut", applyRebalance);
hook.Add("ge_player_spawn", "weaponsfix.nut", applyRebalance);

function processAttack(ply, type) {
    local weapon = ply.GetActiveWeapon();
    local itemIndex = NetProps.GetPropInt(weapon, "m_AttributeManager.m_Item.m_iItemDefinitionIndex");
    local lookDir = ply.EyeAngles().Forward();
    local baseAmmo = NetProps.GetPropIntArray(ply, "m_iAmmo", 1);
    
    if ( itemIndex == 457 && type == 1 ) {
        if ( TraceLine(ply.EyePosition(), ply.EyePosition() + (lookDir * 70), ply) < 1 ) {
            local force = (lookDir * -525);
            ply.SetAbsVelocity( ply.GetVelocity() + Vector(0, 0, 200) );
            ply.ApplyAbsVelocityImpulse( Vector(force.x, force.y, force.z * 0.15) );

            ply.DropFlag(true);
            ply.RemoveCond(Constants.ETFCond.TF_COND_HEALTH_BUFF);
            ply.TakeDamageEx(ply, ply, weapon, Vector(0,0,0), Vector(0,0,0), ply.GetMaxHealth() * 0.25, Constants.FDmgType.DMG_BLAST);
        }
    }

    if ( itemIndex == 1178 && type == 2 && baseAmmo > 20 ) {
        local count = 0;
        local rh = rhGet(ply);
        local curHealth = ply.GetHealth();

        while ( rh.len() > 0 ) {
            local p = rh.pop();
            local target = p.target;
            if ( weapon != p.weapon ) continue; // Must be the same weapon.
            if ( target && target.InCond(Constants.ETFCond.TF_COND_BURNING) && target.GetHealth() > 0 ) {
                target.RemoveCond(Constants.ETFCond.TF_COND_BURNING);
                ply.AddCond(Constants.ETFCond.TF_COND_BURNING);
                count++;
            }
        }

        if ( count > 0 ) {
            // Play a cool effect.
            DispatchParticleEffect("rd_robot_explosion", ply.GetOrigin(), Vector(0,0,0));

            ply.ViewPunch(QAngle(10,0,0));
            weapon.AddAttribute("hidden primary max ammo bonus", 0.075, -1);
            ply.Regenerate(true);

            // Undo the regen... (kinda)
            ply.SetHealth(curHealth);
            ply.TakeDamage(1, Constants.FDmgType.DMG_BURN, ply);
            weapon.RemoveAttribute("hidden primary max ammo bonus");

            setInScope(ply, "recentHits", []);
            ply.AddCondEx(Constants.ETFCond.TF_COND_CRITBOOSTED, count, weapon);
        }
    }
}

function hookThink(){
    local ply = null
    while ( ply = Entities.FindByClassname(ply, "player") ) {
        local iButtons = NetProps.GetPropInt(ply, "m_nButtons");
        local attack1 = (iButtons & Constants.FButtons.IN_ATTACK);
        local attack2 = (iButtons & Constants.FButtons.IN_ATTACK2);

        if ( !getInScope(ply, "isAttacking") ) {
            if ( attack1 ) {
                processAttack(ply, 1);
                setInScope(ply, "isAttacking", true);
            }

            if ( attack2 ) {
                processAttack(ply, 2);
                setInScope(ply, "isAttacking", true);
            }
        }

        if ( !attack1 && !attack2 && getInScope(ply, "isAttacking") ) {
            setInScope(ply, "isAttacking", null);
        }
    }
}

if ( useThinkHook ) {
    createThink(hookThink);
    job.Create();
}

__CollectGameEventCallbacks(this);