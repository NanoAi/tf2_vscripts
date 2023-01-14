local weapon = init_weapon();

w.init = function ( ply, weapon ) {
    weapon.AddAttribute("single wep deploy time decreased", 0.55, -1);
}

w.onTakeDamage = function( ply, target, dmgTotal, p ) {
    target.AddCondEx(Constants.ETFCond.TF_COND_MAD_MILK, 3, ply);
    target.AddCustomAttribute("healing received penalty", 1, 2.5);
    target.AddCustomAttribute("hit self on miss", 1, 2);
    return p;
}

data <- w;
