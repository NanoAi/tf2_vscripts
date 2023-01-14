local w = init_weapon();

w.init = function ( ply, weapon ) {
    weapon.AddAttribute("single wep deploy time decreased", 0.8, -1);
    weapon.AddAttribute("max health additive penalty", 0.2, -1);
}

w.onTakeDamage = function (ply, target, dmgTotal, p) {
    ply.AddCondEx(Constants.ETFCond.TF_COND_PREVENT_DEATH, 3, ply);
    ply.AddCondEx(Constants.ETFCond.TF_COND_MEDIGUN_UBER_BULLET_RESIST, 3, ply);
}

data <- w;
