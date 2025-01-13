hook.Add("ge_player_say", "thirdperson.nut", function(p) {
  local ply = GetPlayerFromUserID(p.userid);
  switch (p.text){
    case ";tp on":
      ply.SetForcedTauntCam(1)
      break;
    case ";tp off":
      ply.SetForcedTauntCam(0)
      break;
    case ";w fire":
      ply.GetActiveWeapon().AddAttribute("Set DamageType Ignite", 1, -1);
      break;
  }
});
