local w = init_weapon();

w.init = function ( ply, weapon ) {
  weapon.AddAttribute("single wep deploy time decreased", 0.7, -1);
  weapon.AddAttribute("health from healers reduced", 0.75, -1);
}

w.onTakeDamage = function (ply, target, dmgTotal, p) {
  if ( target && target != ply && target.IsPlayer() ) {
    local dir = ply.EyeAngles().Forward();
    p.damage = p.damage * 0.70;

    ply.SetAbsVelocity( Vector(0, 0, 300) );
    ply.ApplyAbsVelocityImpulse( dir * -200 );

    target.SetAbsVelocity( Vector(0, 0, 300) );
    target.ApplyAbsVelocityImpulse( dir * 200 );
  }
  return p;
}

w.onAttackClick = function (ply, weapon, lookDir, type) {
  if ( type == 1 ) {
    if ( TraceLine(ply.EyePosition(), ply.EyePosition() + (lookDir * 70), ply) < 1 ) {
      local force = (lookDir * -525);
      ply.SetAbsVelocity( ply.GetVelocity() + Vector(0, 0, 200) );
      ply.ApplyAbsVelocityImpulse( Vector(force.x, force.y, force.z * 0.15) );

      ply.DropFlag(true);
      ply.RemoveCond(Constants.ETFCond.TF_COND_HEALTH_BUFF);
      ply.TakeDamageEx(ply, ply, weapon, Vector(0,0,0), Vector(0,0,0), ply.GetMaxHealth() * 0.25, Constants.FDmgType.DMG_BLAST);
    }
  }
}

data <- w;
