local w = init_weapon();

w.init = function( ply, weapon ) {
  weapon.RemoveAttribute("airblast cost increased");
  weapon.AddAttribute("airblast cost increased", 1, -1);
  weapon.AddAttribute("SPELL: Halloween green flames", 1, -1);
}

w.onTakeDamage = function(ply, target, dmgTotal, p) {
  if ( target.IsPlayer() ) {
    local x = RandomInt(1, 20)
    if ( x == 5 ) {
      target.AddCustomAttribute("move speed bonus", 0.10, 3);
      target.AddCondEx( Constants.ETFCond.TF_COND_STUNNED, 3.03, ply );
    }
    if ( target.InCond(Constants.ETFCond.TF_COND_GAS) ) {
      p.damage_bonus = ( p.damage_bonus || 0 );
      p.damage_bonus = p.damage_bonus + (p.damage * 0.45);
      p.damage_bonus_provider = ply;
      p.crit_type = 1;
    }
  }
  return p;
}

data <- w;
