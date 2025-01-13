local w = init_weapon();

w.init = function ( ply, weapon ) {
  setInScope(ply, "dragonsFuryCD", 0);
  weapon.RemoveAttribute("extinguish restores health");
  weapon.AddAttribute("heal on kill", 20, -1);
  weapon.AddAttribute("max health additive bonus", 47, -1);
  weapon.AddAttribute("mod flamethrower push", 1, -1);
  weapon.AddAttribute("airblast cost increased", 300, -1);
}

w.onTakeDamage = function (ply, target, dmgTotal, p) {
  if ( target && target.IsPlayer() ) {
    local weaponCharge = getInScope(ply, "dragonsFuryCD");
    local setTo = weaponCharge + 5;
    if ( weaponCharge != 40 ) {
      if ( setTo >= 40 ) {
        setInScope(ply, "dragonsFuryCD", 40);
        ClientPrint(ply, 3, "\x000700FFA1  [[ CHARGE READY ]]  ");
        target.RemoveCond(Constants.ETFCond.TF_COND_AFTERBURN_IMMUNE);
        target.AddCondEx(Constants.ETFCond.TF_COND_AIR_CURRENT, 5, ply);
        target.AddCondEx(Constants.ETFCond.TF_COND_GAS, 20, ply);
      } else {
        setInScope(ply, "dragonsFuryCD", setTo);
      }
    }
    if ( target.InCond(Constants.ETFCond.TF_COND_GAS) ) {
      p.damage = p.damage + (dmgTotal * 0.45);
    }
  }
  return p;
}

w.onAttackClick = function (ply, weapon, lookDir, type) {
  if ( type == 2 ) {
    local weaponCharge = getInScope(ply, "dragonsFuryCD");
    local dTypeBurn = Constants.ETFDmgCustom.TF_DMG_CUSTOM_CANNONBALL_PUSH
    local dTypeSonic = Constants.FDmgType.DMG_SONIC
    local pp = ply.GetOrigin();

    if ( weaponCharge != 40 ) {
      ply.ViewPunch(QAngle(0,20,0));
      ply.AddCondEx(Constants.ETFCond.TF_COND_STEALTHED, 1, ply);
      ply.TakeDamage(1, dTypeSonic, weapon);
      return;
    }

    ply.ViewPunch(QAngle(10,0,0));
    DispatchParticleEffect("rd_robot_explosion", ply.GetOrigin(), Vector(0,0,0));

    local target = null
    while ( target = Entities.FindInSphere(target, ply.GetOrigin(), 500) ) {
      if ( target && target != ply && target.IsValid() ) {
        local tp = target.GetOrigin();
        local dir = (tp - pp);
        if ( target.IsPlayer() && ply.GetTeam() != target.GetTeam() ) {
          DispatchParticleEffect("projectile_fireball", target.GetOrigin(), Vector(0,0,0));

          target.AddCondEx(Constants.ETFCond.TF_COND_GAS, 10, ply);
          target.AddCondEx(Constants.ETFCond.TF_COND_AIR_CURRENT, 5, ply);
          target.TakeDamageCustom(weapon, ply, weapon, Vector(0,0,0), Vector(0,0,0), 10, dTypeSonic, dTypeBurn);
          target.ApplyAbsVelocityImpulse(Vector(0.01, 0.01, 400));
          target.ViewPunch(QAngle(-10,0,0));

          target.AddCustomAttribute("move speed bonus", 0.40, 3);
          target.AddCondEx(Constants.ETFCond.TF_COND_STUNNED, 3.1, ply);
          continue;
        }
      }
    }

    ply.AddCondEx( Constants.ETFCond.TF_COND_BLAST_IMMUNE, 10, ply );
    ply.AddCondEx( Constants.ETFCond.TF_COND_MEGAHEAL, 10, ply );
    setInScope(ply, "dragonsFuryCD", 0);
  }
}

data <- w;
