local w = init_weapon();

w.init = function ( ply, weapon ) {
    weapon.RemoveAttribute("extinguish restores health");
    weapon.AddAttribute("heal on kill", 20, -1);
    weapon.AddAttribute("no crit boost", 1, -1);
    weapon.AddAttribute("fire rate bonus", -1, -1); // ex
    weapon.AddAttribute("max health additive bonus", 47, -1);
    weapon.AddAttribute("mod flamethrower push", 1, -1);
    weapon.AddAttribute("airblast cost increased", 300, -1);
}

w.onTakeDamage = function (ply, target, dmgTotal, p) {
    if ( target && target.IsPlayer() ) {
        local dfBuff = getInScope(ply, "dragonsFuryBuff");
        if ( dfBuff && dfBuff.ammo > 0 && p.weapon == dfBuff.weapon ) {
            target.AddCond(Constants.ETFCond.TF_COND_GAS);

            p.damage = p.damage + (p.damage * ( 0.55 * dfBuff.mult ));
            p.damage_bonus = p.damage_bonus + dfBuff.mult;
            p.crit_type = 2;
            dfBuff.ammo--;

            setInScope(ply, "dragonsFuryBuff", dfBuff);
        }
        if ( target.InCond(Constants.ETFCond.TF_COND_GAS) ) {
            target.AddCustomAttribute("move speed bonus", 0.40, 2);
            target.AddCondEx( Constants.ETFCond.TF_COND_STUNNED, 2.05, ply );
            ply.AddCustomAttribute("dragons fury positive properties", 2, 3);
        }
    }
    return p;
}

w.onAttackClick = function (ply, weapon, lookDir, type) {
    if ( type == 2 ) {
        local count = 0;
        local useTime = getInScope(ply, "dragonsFuryCD");
        local dTypeBurn = Constants.ETFDmgCustom.TF_DMG_CUSTOM_BURNING
        local dTypeSonic = Constants.FDmgType.DMG_SONIC

        if ( useTime && useTime > Time() ) {
            ply.BleedPlayer(3);
            ply.ViewPunch(QAngle(0,10,0));
            setInScope(ply, "dragonsFuryCD", Time());
            ClientPrint(ply, 3, "\x0007FF3F3F[[ NOT READY ]]");
            ply.AddCustomAttribute("move speed bonus", 0.85, 3);
            return;
        }

        if ( ply.GetHealth() < 10 ) {
            ply.ViewPunch(QAngle(0,10,0));
            return;
        }

        local target = null
        while ( target = Entities.FindInSphere(target, ply.GetOrigin(), 1000) ) {
            if ( !(target && target.GetClassname() == "player" && target.IsPlayer()) ) continue;
            if ( target.InCond(Constants.ETFCond.TF_COND_BURNING) ) {
                target.RemoveCond(Constants.ETFCond.TF_COND_BURNING);
                target.TakeDamageCustom(weapon, ply, weapon, Vector(0,0,0), Vector(0,0,0), 25, dTypeSonic, dTypeBurn);
                count++;
            }
        }

        if ( count > 0 ) {
            // Play a cool effect.
            ply.ViewPunch(QAngle(10,0,0));
            DispatchParticleEffect("rd_robot_explosion", ply.GetOrigin(), Vector(0,0,0));

            ply.TakeDamage( 10, Constants.FDmgType.DMG_BURN, ply );
            ply.AddCondEx( Constants.ETFCond.TF_COND_MEGAHEAL, 2, ply );
            ply.AddCondEx( Constants.ETFCond.TF_COND_BLAST_IMMUNE, 2, ply );
            ply.AddCondEx( Constants.ETFCond.TF_COND_PREVENT_DEATH, 2, ply );
            ply.AddCustomAttribute("move speed bonus", 1.75, 2.5);

            ClientPrint(ply, 3, "\x000700FFA1[[ FEEL THE DRAGONS RAGE ] x" + count + "]");
            setInScope(ply, "dragonsFuryBuff", { mult = count, ammo = count, weapon = weapon, time = Time() });
        } else {
            ply.ViewPunch(QAngle(5,0,5));
            ply.AddCondEx( Constants.ETFCond.TF_COND_MEGAHEAL, 3, ply );
            ply.AddCustomAttribute("health from healers reduced", 2, 5);
            ply.AddCustomAttribute("dragons fury positive properties", 2, 5);
            ply.AddCondEx( Constants.ETFCond.TF_COND_SODAPOPPER_HYPE, 3, ply );
        }
        setInScope(ply, "dragonsFuryCD", Time() + 5);
    }
}

data <- w;
