IncludeScript("boxfox.utils.nut", this);

// Setup Hooks
function OnScriptHook_OnTakeDamage(p) {
    hook.Call("sh_OnTakeDamage", p);
}

function OnGameEvent_post_inventory_application(p) {
    hook.Call("ge_post_inventory_application", p);
}

function OnGameEvent_player_spawn(p) {
    hook.Call("ge_player_spawn", p);
}

function OnGameEvent_player_death(p) {
    hook.Call("ge_player_death", p);
}

function OnGameEvent_teamplay_overtime_begin(p) {
    hook.Call("ge_teamplay_overtime_begin", p);
}

function OnPostSpawn() {
    hook.Call("onpostspawn", null);
}

function OnGameEvent_teamplay_round_active(p) {
    hook.Call("ge_teamplay_round_active", p);
}

function OnGameEvent_ctf_flag_captured(p) {
    hook.Call("ge_ctf_flag_captured", p);
}

// Collect Callbacks (Apply Hooks)
__CollectGameEventCallbacks(this);