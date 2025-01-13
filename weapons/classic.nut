local w = init_weapon();

w.init = function ( ply, weapon ) {
  weapon.AddAttribute("damage penalty on bodyshot", 0.4, -1);
  weapon.AddAttribute("mult sniper charge after bodyshot", 1.12, -1);
  weapon.AddAttribute("crit vs disguised players", 1, -1);
  weapon.AddAttribute("explosive sniper shot", 1, -1);
}

w.onTakeDamage = function ( ply, target, dmgTotal, p ) {
  if ( target.IsPlayer() ) {
    ply.AddCondEx(Constants.ETFCond.TF_COND_SPEED_BOOST, 1.5, ply);
  }
}

data <- w;
