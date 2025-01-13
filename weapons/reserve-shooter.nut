local w = init_weapon();

w.init = function( ply, weapon ) {
  weapon.AddAttribute("attack_minicrits_and_consumes_burning", 1, -1);
}

w.onTakeDamage = function(ply, target, dmgTotal, p) {
}

data <- w;
