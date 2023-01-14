IncludeScript("boxfox.utils.nut", this);

// Setup Hooks
function OnScriptHook_OnTakeDamage(p) {
    hook.Call("sh_OnTakeDamage", p);
}

function OnGameEvent_post_inventory_application(p) {
    hook.Call("ge_post_inventory_application", p);
}

function OnGameEvent_player_say(p)
{
	hook.Call("ge_player_say", p);
}

function OnGameEvent_player_spawn(p) {
    hook.Call("ge_player_spawn", p);
}

function OnGameEvent_player_death(p) {
    hook.Call("ge_player_death", p);
}

function OnGameEvent_teamplay_round_start(p) {
    hook.Call("ge_teamplay_round_start", p);
}

function OnGameEvent_teamplay_game_over(p) {
    hook.Call("ge_teamplay_game_over", p);
}

function OnGameEvent_tf_game_over(p) {
    hook.Call("ge_tf_game_over", p);
}

function OnGameEvent_teamplay_overtime_begin(p) {
    hook.Call("ge_teamplay_overtime_begin", p);
}

function OnScriptHook_OnPostSpawn(p) {
    hook.Call("sh_onpostspawn", null);
}

function OnGameEvent_teamplay_round_active(p) {
    hook.Call("ge_teamplay_round_active", p);
}

function OnGameEvent_ctf_flag_captured(p) {
    hook.Call("ge_ctf_flag_captured", p);
}

chatPrint(null, "Hooks have been setup!");
