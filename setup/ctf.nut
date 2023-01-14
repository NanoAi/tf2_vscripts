chatPrint(null, "Preparing CTF Setup...");

IncludeScript("setuphooks.nut", this);
IncludeScript("roundLogic.nut", this);
IncludeScript("friendlyfirelimit.nut", this);
IncludeScript("weapon_loader.nut", this);

chatPrint(null, "Collecting Script Hooks...");

__CollectGameEventCallbacks(this);
