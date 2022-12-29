IncludeScript("boxfox.utils.nut", this);

chatPrint(null, "Preparing General Setup...");

IncludeScript("setuphooks.nut", this);
// IncludeScript("roundLogic.nut", this);
IncludeScript("friendlyfirelimit.nut", this);
IncludeScript("weaponsfix.nut", this);

chatPrint(null, "Collecting Script Hooks...");
__CollectGameEventCallbacks(this);
