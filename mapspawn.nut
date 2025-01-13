getroottable()["ScriptHookCallbacks"] <- {}
ClearGameEventCallbacks();

IncludeScript("boxfox.utils.nut", this);

printl("==> RUNNING MAPSPAWN.NUT");

local mode = GetMapName().slice(0, 4);
if ( mode == "ctf_" ) {
  IncludeScript("setup/ctf.nut", this);
} else {
  IncludeScript("setup/other.nut", this);
}

hook.Add("ge_teamplay_round_start", "mapspawn.nut", function(p){
  ClientPrint(null, 3, "\x03[\x01!\x03] Sick of this map? Say \x0007FC00FFrtv\x03 to change it to another!");
});

__CollectGameEventCallbacks(this);
