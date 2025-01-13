local zombieSpawner = false;
local ents = [
  "tf_zombie",
  "tf_zombie_spawner"
];

local toggleMe = function() {
  EntFireByHandle(self, "Toggle", "", 0, self, null);
  EntFireByHandle(self, "Toggle", "", 0, self, null);
}

function clearCustomEnts() {
  foreach (k, v in ents){
    local x = null;
    while( x = Entities.FindByClassname(x, v)  ) {
      ClientPrint(null, 1, "Removing: " + x);
      x.Destroy();
    }
  }
}

function setOnEntity(classname, callback = function(x){}) {
  local x = null;
  while ( x = Entities.FindByClassname(x, classname) ) {
    callback(x);
  }
}

SetSkyboxTexture("sky_halloween");

setOnEntity("env_fog_controller", function (x) {
  EntFireByHandle(x, "SetColor", "0 0 0 0", 0, x, null);
  EntFireByHandle(x, "SetColorSecondary", "0 0 0 2500", 0, x, null);
  EntFireByHandle(x, "SetMaxDensity", "0.85", 0, x, null);
  NetProps.SetPropFloat(x, "m_fog.start", 0)
  NetProps.SetPropFloat(x, "m_fog.end", 0)
});

setOnEntity("sky_camera", function(x) {
  NetProps.SetPropInt(x, "m_skybox3d.fog.enable", 1);
  NetProps.SetPropString(x, "m_skybox3d.fog.colorPrimary", "0 0 0 5000");
  NetProps.SetPropFloat(x, "m_fog.start", 0);
  NetProps.SetPropFloat(x, "m_fog.end", 0);
  EntFireByHandle(x, "ActivateSkybox", "", 0, null, null);
});

setOnEntity("env_sun", function(x) {
  x.SetAbsOrigin(Vector(0,0,-500));
  EntFireByHandle(x, "SetColor", "0 0 0 2500", 1, e, null);
  EntFireByHandle(x, "TurnOff", "", 2, e, null);
});

function SetupSkeletonSpawner(e) {
  NetProps.SetPropInt(e, "m_nSkeletonType", 1); // King Type
  NetProps.SetPropInt(e, "m_nMaxActiveZombies", 1); // Max Active
  NetProps.SetPropBool(e, "m_bInfiniteZombies", true); // Respawns (?)
  EntFireByHandle(e, "Enable", "", 0.03, e, null);
}

function skKillMe() {
  self.Destroy();
}

function sendMessage(ply) {
  local plyNetName = NetProps.GetPropString(ply, "m_szNetname");
  local infoIcon = "\x0007FFC800[!]\x01 ";
  local teamColour = "\x01";

  if ( plyNetName == "" ) {
    return false;
  }

  if ( ply.GetTeam() == 2 ) {
    teamColour = "\x0007FF3F3F";
  } else {
    teamColour = "\x000799CDFF";
  }
  ClientPrint(null, 4, "The Skeleton King has been slain!");
  ClientPrint(null, 3, infoIcon+teamColour+plyNetName+"\x01 has slain \x0007FFC800The Skeleton King\x01!");

  return true;
}

hook.Add("sh_OnTakeDamage", "2fort.nut", function(p) {
  local ply = p.attacker;
  local target = p.const_entity;
  local dmgTotal = p.damage + (p.damage_bonus || 0);
  if ( (verifyEntity(ply) && verifyEntity(target)) && ply.IsPlayer() ) {
    local condA = ((target.GetHealth() - dmgTotal) <= 0);
    local condB = (target.GetClassname() == "tf_zombie");
    local condC = (target.GetOwner() == null);
    if ( condB && condC ) {
      local smollChance = RandomInt(1, 20);
      local spellChance = RandomInt(2, 52);
      if ( p.damage_type & Constants.FDmgType.DMG_BULLET ) {
        p.damage = p.damage * 0.40;
        p.damage_bonus = p.damage_bonus * 0.40;
      }
      if ( smollChance == 3 ) {
        DispatchParticleEffect("fireSmokeExplosion", ply.GetOrigin(), Vector(0,0,0));
        ply.AddCondEx(Constants.ETFCond.TF_COND_MELEE_ONLY, 3, target);
        ply.AddCondEx(Constants.ETFCond.TF_COND_SWIMMING_CURSE, 3.5, target);
        ply.AddCondEx(Constants.ETFCond.TF_COND_CANNOT_SWITCH_FROM_MELEE, 3.3, target);
        ply.ViewPunch(QAngle(100,0,100));
      }
      if ( spellChance == 5 ) {
        local e = SpawnEntityFromTable("tf_spell_pickup", {
          AutoMaterialize = false
        });
        e.SetAbsOrigin(target.GetOrigin());
        if ( e.ValidateScriptScope() ) {
          e.GetScriptScope()["KillMe"] <- skKillMe;
          e.ConnectOutput("OnPlayerTouch", "KillMe");
        }
      }
      if ( condA ) {
        sendMessage(ply);
        EntFireByHandle(target, "SetHealth", "0", 0, ply, ply);
        if ( job.Check() ) {
          ply.Regenerate(true);
          job.Add(function(){
            ply.AddCondEx(Constants.ETFCond.TF_COND_SPEED_BOOST, 12, ply);
            ply.AddCondEx(Constants.ETFCond.TF_COND_CRITBOOSTED_ON_KILL, 12, ply);
          }, 0);
        } else {
          ply.AddCondEx(Constants.ETFCond.TF_COND_SPEED_BOOST, 12, ply);
          ply.AddCondEx(Constants.ETFCond.TF_COND_CRITBOOSTED_ON_KILL, 12, ply);
        }
        setOnEntity("tf_zombie_spawner", function(e) {
          EntFireByHandle(e, "Disable", "", 0, e, null);
          EntFireByHandle(e, "Enable", "", 30, e, null);
        });
      }
    }
  }
});

hook.Add("ge_teamplay_round_start", "2fort.nut", function(p) {
  clearCustomEnts();
  local e = SpawnEntityFromTable("tf_zombie_spawner", {
    automaterialize = true,
    origin = Vector(4.5, 1, 80.1)
  });
  e.SetAbsOrigin( Vector(4.5, 1, 80.1) );
  e.ValidateScriptScope();
  SetupSkeletonSpawner(e);
});

SendToServerConsole("mp_restartgame_immediate 1");
