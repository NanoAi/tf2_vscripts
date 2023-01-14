local w = init_weapon();

w.init = function( ply, weapon ) {
}

w.onTakeDamage = function(ply, target, dmgTotal, p) {
    if ( target.IsPlayer() ) {
        if ( target.InCond(Constants.ETFCond.TF_COND_BURNING) ) {
            p.damage_bonus = p.damage_bonus + (p.damage * 0.15);
        }
    }
    return p;
}

data <- w;
