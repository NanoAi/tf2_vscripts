local w = init_weapon();

w.init = function( ply, weapon ) {
  weapon.AddAttribute("dmg bonus vs buildings", 2, -1);
  weapon.AddAttribute("damage applies to sappers", 1, -1);
  weapon.AddAttribute("maxammo metal increased", 1.50, -1);
  weapon.AddAttribute("single wep deploy time decreased", 0.5, -1);
}

w.onTakeDamage = function(ply, target, dmgTotal, p) {
  if ( target.IsPlayer() ) {
    local etfCond = Constants.ETFCond;
    local b = target.InCond(etfCond.TF_COND_SAPPED);
    local a = (target.InCond(etfCond.TF_COND_HEALING_DEBUFF) || target.InCond(etfCond.TF_COND_BURNING));
    a = (a || (target.InCond(etfCond.TF_COND_URINE) || target.InCond(etfCond.TF_COND_MAD_MILK)));
    a = (a || ply.GetWaterLevel() > 1);
    if ( b ) {
      local maxHealth = ply.GetMaxHealth();
      local health = ply.GetHealth()
      if ( health < maxHealth ) {
        p.crit_type = 1;
        p.damage = dmgTotal * 3;
        ply.SetHealth(health + 2);
      }
    } else {
      if ( a ) {
        target.AddCond(etfCond.TF_COND_LOST_FOOTING);
        target.AddCondEx(etfCond.TF_COND_SAPPED, 5, ply);
      }
    }
  }
  return p;
}

data <- w;
