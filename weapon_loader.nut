clearThink();
IncludeScript("weapons_dir.nut", this);

function onClassDamage(ply) {
  local plyClass = ply.GetPlayerClass();
  switch(plyClass) {
    case Constants.ETFClass.TF_CLASS_PYRO:
      ply.AddCustomAttribute("move speed bonus", 1.15, 1);
      break;
  }
}

hook.Add("sh_OnTakeDamage", "weaponsfix.nut", function(p) {
  local itemIndex = null;
  local ply = p.attacker;
  local target = p.const_entity;
  local dmgTotal = p.damage + (p.damage_bonus || 0);

  if ( !ply ) { return; }
  if ( p.weapon ) {
    onClassDamage(ply);
    processDamage(ply, target, dmgTotal, p);
  }

  local invEffects = getInScope(ply, "inventoryEffects");
  if (typeof invEffects == "array") {
    foreach( effect in invEffects ){
      switch(effect) {
        case 1:
          if (verifyEntity(target) && target.InCond(Constants.ETFCond.TF_COND_BURNING)) {
            xCond.set(ply, 0, (function (ply) {
              plyHeal(ply, 5)
            }), 1);
          }
          break;
      }
    }
  }
});

function applyRebalance(p){
  local ply = GetPlayerFromUserID(p.userid)
  if ( !verifyEntity(ply) ) { return; }

  ply.RemoveCond(Constants.ETFCond.TF_COND_HALLOWEEN_TINY);
  setInScope(ply, "recentHits", []);
  setInScope(ply, "inventoryEffects", []);
  setInScope(ply, "customConditions", {});
  setInScope(ply, "dragonsFuryBuff", null); // Specific to Dragons Fury example.

  for ( local i = 0; i < 7; i++ ) {
    local wep = NetProps.GetPropEntityArray(ply, "m_hMyWeapons", i)
    if ( verifyEntity(wep) ) {
      local id = getItemIndex(wep);
      loadFromId(ply, wep);
    }
  }
}

hook.Add("ge_post_inventory_application", "weaponsfix.nut", applyRebalance);
hook.Add("ge_player_spawn", "weaponsfix.nut", applyRebalance);

function onInAttack(ply, type) {
  local weapon = ply.GetActiveWeapon();
  local lookDir = ply.EyeAngles().Forward();
  processAttack(ply, weapon, lookDir, type);
}

function hookThink(){
  local ply = null
  while ( ply = Entities.FindByClassname(ply, "player") ) {
    local iButtons = NetProps.GetPropInt(ply, "m_nButtons");
    local attack1 = (iButtons & Constants.FButtons.IN_ATTACK);
    local attack2 = (iButtons & Constants.FButtons.IN_ATTACK2);

    if ( !getInScope(ply, "isAttacking") ) {
      if ( attack1 ) {
        onInAttack(ply, 1);
        setInScope(ply, "isAttacking", true);
      }

      if ( attack2 ) {
        onInAttack(ply, 2);
        setInScope(ply, "isAttacking", true);
      }
    }

    if ( !attack1 && !attack2 && getInScope(ply, "isAttacking") ) {
      setInScope(ply, "isAttacking", null);
    }

    xCond.tick(ply);
  }
}

createThink(hookThink);
job.Create();

__CollectGameEventCallbacks(this);
SendToServerConsole("mp_restartgame_immediate 1");
