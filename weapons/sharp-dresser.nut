local w = init_weapon();

w.onTakeDamage = function (ply, target, dmgTotal, p) {
  if ( target.IsPlayer() ) {
    local healTarget = target.GetHealTarget();
    if ( verifyEntity(healTarget) && healTarget.IsPlayer() ) {
      healTarget.TakeDamageCustom(ply, ply, p.weapon, p.damage_force, p.damage_position, dmgTotal, p.damage_type, p.damage_custom);
      ply.AddCustomAttribute("max health additive penalty", -25, -1);
      job.Add(function(){
        if ( verifyEntity(ply) && ply.IsPlayer() ) {
          ply.SetSpyCloakMeter( 40 );
        }
      });
    }
  }
  return p;
}

data <- w;
