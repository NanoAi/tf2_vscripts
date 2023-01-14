local w = init_weapon();

w.init = function( ply, weapon ) {
    weapon.RemoveAttribute("airblast cost increased");
    weapon.AddAttribute("airblast cost increased", 1, -1);
    weapon.AddAttribute("afterburn duration bonus", 0.66, -1);
    weapon.AddAttribute("weapon burn time increased", 0.66, -1);
    weapon.AddAttribute("SET BONUS: calling card on kill", 4, -1);
}

w.onTakeDamage = function(ply, target, dmgTotal, p) {
    if ( target.IsPlayer() ) {
        local condA = target.InCond(Constants.ETFCond.TF_COND_GAS);
        local condB = target.InCond(Constants.ETFCond.TF_COND_KNOCKED_INTO_AIR);
        local condC = target.InAirDueToExplosion() || target.InAirDueToKnockback();
        if ( condA || condB || condC ) {
            p.damage_bonus = ( p.damage_bonus || 0 );
            p.damage_bonus = p.damage_bonus + (p.damage * 0.55);
            p.damage_bonus_provider = ply;
            p.crit_type = 1;
        }
    }
    return p;
}

data <- w;
