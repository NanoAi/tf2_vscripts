local w = init_weapon();

w.init = function( ply, weapon ) {
  weapon.AddAttribute("axtinguisher properties", 1, -1);
}

w.onTakeDamage = function(ply, target, dmgTotal, p) {
}

data <- w;
