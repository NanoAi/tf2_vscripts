IncludeScript("boxfox.utils.nut", this);

function OnGameEvent_player_spawn(p) {
    local ply = GetPlayerFromUserID(p.userid);
    if ( ply ) {
        setInScope(ply, "SpawnProtection", Time())
    }
}

function OnScriptHook_OnTakeDamage(p)
{
    local attacker = p.attacker;
    local victim = p.const_entity;
    if (attacker.IsPlayer() && victim.IsPlayer()) {
        if ( plyIsFriendly(attacker, victim) ) {
            local spawnTime = getInScope(victim, "SpawnProtection")
            if ( spawnTime && ( (spawnTime + 5) > Time() ) ) {
                attacker.TakeDamageEx(p.inflictor, p.attacker, p.weapon, p.damage_force, p.damage_position, p.damage * 10, p.damage_type);
                p.damage_force = Vector(0,0,0);
                p.damage = 0;
            } else {
                setInScope(victim, "SpawnProtection", null)
            }
        }
    }
}

function OnGameEvent_player_death(p) {
    local attacker = GetPlayerFromUserID(p.attacker);
    local victim = GetPlayerFromUserID(p.userid);
    if ( !attacker || !victim ) { return; }
    if ( plyIsFriendly(attacker, victim) ) {
        attacker.BleedPlayer(7);
        attacker.AddCondEx(Constants.ETFCond.TF_COND_MARKEDFORDEATH, 5, attacker);
        chatPrint(attacker, "[FRIEND KILLER] How could you...");
    }
}

__CollectGameEventCallbacks(this);