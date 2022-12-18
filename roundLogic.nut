local settings = {
    // Set Round time in seconds.
    roundTime = 425,
    // Time to be added when a flag is captured.
    bonusTimeOnCap = 120,
    // Toggle SuddenDeath mode.
    suddenDeathOvertime = true,
    // Toggle last minute crits.
    lastMinuteBuff = true
}

// !!!! DO NOT EDIT ANYTHING BELOW THIS LINE !!!!

local ent = null;
local scoreData = null;

local round = {
    timer = null,
    win = null
}

// Cleanup existing timers/win states.
{
    while( ent = Entities.FindByClassname(ent, "team_round_timer")  )
    {
        ent.Kill();
    }
    while( ent = Entities.FindByClassname(ent, "game_round_win")  )
    {
        ent.Kill();
    }
}

// Actually do the things.
printl("Loading Timer Script...");

function exposeEnv(env, scope) {
    foreach ( key, obj in env ) {
        if ( !(key in scope) ) {
            scope[key] <- obj
        }
    }
}

_roundLogic <-
{
    settings = settings,

    function ctfScoreReset() {
        scoreData = {
            [2] = 0,
            [3] = 0
        };
    }

    function printSettings() {
        printl("RoundLogic Settings <-")
        foreach (key, value in settings) {
            printl("- " + key + " = " + value)
        }
        printl("-> RoundLogic Settings")
    }

    function createRoundTimer() {
        round.timer = SpawnEntityFromTable("team_round_timer", {
            timer_length = settings.roundTime,
            StartDisabled = false,
            show_in_hud = true,
            auto_countdown = true,
            reset_time = true,
            targetname = "roundTimer",
            parent = "worldspawn"
        })

        round.win = SpawnEntityFromTable("game_round_win", {
            targetname = "roundWin"
            parent = "worldspawn"
        })

        local timer = round.timer
        // local win = round.win

        if ( timer.ValidateScriptScope() ) {
            exposeEnv(this, timer.GetScriptScope())
            timer.ConnectOutput("OnFinished", "ctfGameEnd")
            timer.ConnectOutput("On30SecRemain", "ctfBuffAdd")
            timer.ConnectOutput("On5SecRemain", "ctfBuffRemove")
        }
    }

    function ctfTeamWin( winning_team ) {
        printl("Running ctfTeamWin(" + winning_team + ")")
        EntFire("roundWin", "setteam", "" + winning_team)
        EntFire("roundWin", "roundwin")
    }

    function ctfGameEnd() {
        if ( scoreData[2] == scoreData[3] ) {
            EntFire("roundWin", "setteam", "0") // STALEMATE 
            EntFire("roundWin", "roundwin")
            return;
        }

        if ( scoreData[2] > scoreData[3] ) {
            EntFire("roundWin", "setteam", "2") // RED TEAM WIN
        } else {
            EntFire("roundWin", "setteam", "3") // BLU TEAM WIN
        }

        EntFire("roundWin", "roundwin")
    }

    function ctfBuffAdd() {
        if ( !settings.lastMinuteBuff ) { return }
        ClientPrint(null, 3, "\x03\x04!!! PREPARE FOR SUDDEN CRITS !!!")
        ClientPrint(null, 4, "\x03\x04!!! PREPARE FOR SUDDEN CRITS !!!")

        local ply = null
        while ( ply = Entities.FindByClassname(ply, "player") ) {
            ply.AddCond(Constants.ETFCond.TF_COND_SPEED_BOOST)
            ply.AddCond(Constants.ETFCond.TF_COND_NOHEALINGDAMAGEBUFF)
        }
    }

    function ctfBuffRemove() {
        local ply = null
        while ( ply = Entities.FindByClassname(ply, "player") ) {
            ply.RemoveCond(Constants.ETFCond.TF_COND_SPEED_BOOST)
            ply.RemoveCond(Constants.ETFCond.TF_COND_NOHEALINGDAMAGEBUFF)
        }
    }
}

function OnGameEvent_teamplay_overtime_begin() {
    EntFire("roundTimer", "pause")
}

function OnPostSpawn() {
    printl("Loading Timer Script...");
    _roundLogic.createRoundTimer()
    __CollectGameEventCallbacks(this)
}

function OnGameEvent_teamplay_round_active(p) {
    _roundLogic.ctfScoreReset()
    
    if ( Entities.FindByName(null, "roundTimer") == null ) {
        _roundLogic.createRoundTimer()
    }

    EntFire("roundTimer", "restart")
    EntFire("roundTimer", "resume")
}

function OnGameEvent_ctf_flag_captured(p) {
    if ( InOvertime() && settings.suddenDeathOvertime ) {
        _roundLogic.ctfTeamWin(p.capping_team)
    } else {
        EntFire("roundTimer", "addtime", settings.bonusTimeOnCap.tostring())
        scoreData[ p.capping_team ] = p.capping_team_score;
    }
}

SendToServerConsole("mp_restartgame_immediate 1")
__CollectGameEventCallbacks(this)