local initDelay = 1;
local initTime = Time();
local scriptHookActive = false;

IncludeScript("boxfox.utils.nut", this);

function init() {
    IncludeScript("friendlyfirelimit.nut", this);
    IncludeScript("weaponsfix.nut", this);
    IncludeScript("roundLogic.nut", this);
    __CollectGameEventCallbacks(this);
};

function hookThink(){
    local canRun = (initTime + initDelay) < Time();
    if ( canRun ) {
        init();
        printl("[INIT] Initializing Scripts...");
        clearThink("init");
    }
}

createThink(hookThink, "init");
__CollectGameEventCallbacks(this);
