//ref: https://wiki.alliedmods.net/Team_fortress_2_item_definition_indexes
//ref: https://wiki.teamfortress.com/wiki/List_of_item_attributes

local glob = this;
local dict = {
  [40] = "backburner",
  [215] = "degreaser",
  [173] = "vitasaw",
  [810] = "red-tape-recorder",
  [307] = "ullapool-caber",
  [348] = "sharpened-volcano-fragment",
  [457] = "postal-pumbler",
  [1178] = "dragons-fury",
  [741] = "rainblower",
  [1098] = "classic",
  [638] = "sharp-dresser",
  [230] = "sydney-sleeper",
  [415] = "reserve-shooter",
  [528] = "short-circuit",
  [1153] = "panic-attack"
}

local mem = {}

function init_weapon() {
  return {
    function init( ply, weapon ){}
    onTakeDamage = false
    onAttackClick = false
    ffOverride = -1
  }
}

function rhPush(ply, target, weapon) {
  local recentHits = getInScope(ply, "recentHits");
  local data = {
    target = target,
    weapon = weapon,
    time = Time()
  }
  recentHits.push(data);
  if ( recentHits.len() > 4 ) {
    recentHits.pop(); // Remove a single value.
  }
  setInScope(ply, "recentHits", recentHits);
}

function rhGet(ply) {
  return getInScope(ply, "recentHits");
}

function loadFromId(ply, weapon){
  local id = getItemIndex(weapon);
  if ( ( id in mem ) && mem[id].init ) {
    mem[id].init(ply, weapon);
    return;
  }
  if ( id in dict ) {
    mem[id] <- {};
    local name = dict[id];
    IncludeScript("weapons/" + name + ".nut", mem[id]);
    mem[id] <- mem[id].data;
    mem[id].init(ply, weapon);
  }
}

function processDamage(ply, target, dmgTotal, p) {
  if ( !p.weapon ) return;
  local id = getItemIndex(p.weapon);
  if ( id in mem ) {
    if ( checkEnt(target) && (ply.IsPlayer() && target.IsPlayer()) ) {
      if ( ply.GetTeam() == target.GetTeam() ) {
        p.is_friendly_fire <- true;
      } else {
        p.is_friendly_fire <- false;
      }
    }
    if ( mem[id].onTakeDamage ) {
      mem[id].onTakeDamage(ply, target, dmgTotal, p);
    }
    if ( mem[id].ffOverride > -1 && p.is_friendly_fire ) {
      p.damage = mem[id].ffOverride;
      p.damage_bonus = 0;
      p.crit_type = 0;
    }
  }
}

function processAttack(ply, weapon, lookDir, type) {
  if ( !weapon ) return;
  local id = getItemIndex(weapon);
  if ( id in mem ) {
    if ( mem[id].onAttackClick ) {
      mem[id].onAttackClick(ply, weapon, lookDir, type);
    }
  }
}
