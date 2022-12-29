function heartbeat(p) {
    SendToServerConsole("heartbeat");
    printl("!!!!SENDING HEARTBEAT!!!!");
}

hook.Add("ge_teamplay_round_start", "heartbeat.nut", heartbeat)
hook.Add("ge_teamplay_game_over", "heartbeat.nut", heartbeat)
hook.Add("ge_tf_game_over", "heartbeat.nut", heartbeat)
