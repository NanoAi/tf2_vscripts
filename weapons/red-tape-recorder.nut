local w = init_weapon();

w.init = function ( ply, weapon ) {
  weapon.RemoveAttribute("move speed bonus");
  weapon.AddAttribute("move speed bonus", 1.2, -1);
}

data <- w;
