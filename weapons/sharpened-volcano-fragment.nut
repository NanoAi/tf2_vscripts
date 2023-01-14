local w = init_weapon();

w.init = function ( ply, weapon ) {
    weapon.RemoveAttribute("Set DamageType Ignite");
    weapon.AddAttribute("Set DamageType Ignite", 0, -1);
    weapon.AddAttribute("bleeding duration", 7, -1);
}

data <- w;
