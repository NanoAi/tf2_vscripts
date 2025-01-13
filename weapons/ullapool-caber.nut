local w = init_weapon();

w.init = function ( ply, weapon ) {
  weapon.RemoveAttribute("damage bonus");
  weapon.AddAttribute("mark for death", 1, -1);
}

w.onTakeDamage = function (ply, target, dmgTotal, p) {
  p.weapon.Kill();
  p.damage = p.damage * 2;
  ply.SetHealth(2);
  ply.TakeDamage(999, Constants.FDmgType.DMG_DISSOLVE, ply);
  return p;
}

data <- w;
