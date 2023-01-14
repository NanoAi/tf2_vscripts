local w = init_weapon();

w.init = function ( ply, weapon ) {
    weapon.AddAttribute("health from healers reduced", 0.75, -1);
    weapon.AddAttribute("patient overheal penalty", 0, -1);
    
    weapon.AddAttribute("airblast cost increased", 5, -1);
    weapon.AddAttribute("bombinomicon effect on death", 1, -1);
    weapon.AddAttribute("charged airblast", 1, -1);

    weapon.AddAttribute("flame life bonus", 1.25, -1);
    weapon.AddAttribute("slow enemy on hit", 0.50, -1);

    job.Add(function(){
        if ( !ply.InCond(Constants.ETFCond.TF_COND_HALLOWEEN_TINY) ) {
            ply.AddCond(Constants.ETFCond.TF_COND_HALLOWEEN_TINY);
        }
    });
}

data <- w;
