function chatPrint(player, string) {
    ClientPrint(player, 3, "" + string);
}

function exposeEnv(env, scope) {
    foreach ( key, obj in env ) {
        if ( !(key in scope) ) {
            scope[key] <- obj
        }
    }
}

function getInScope(ent, index) {
    if ( ent.ValidateScriptScope() ) {
        local scope = ent.GetScriptScope();
        if ( index in scope ) {
            return scope[index];
        } else {
            return null;
        }
    }
}

function setInScope(ent, index, value) {
    if ( ent.ValidateScriptScope() ) {
        ent.GetScriptScope()[index] <- value;
    }
}

function plyIsJumping(ply) {
    // `ply.IsJumping()` doesn't seem to be reliable when encountering water, etc.
    if ( ply.IsJumping() ) {
        return true
    }

    local iButtons = NetProps.GetPropInt(ply, "m_nButtons");
    local mtMoveType = NetProps.GetPropInt(ply, "m_MoveType");
    local iWaterLevel = NetProps.GetPropInt(ply, "m_nWaterLevel");

    local keyInJump = (iButtons & Constants.FButtons.IN_JUMP);

    local iGroundEntity = NetProps.GetPropInt(ply, "m_hGroundEntity");
    local bInWater = (iWaterLevel > 2 /* WL_Waist */);
    local bOnGround = (!bInWater && mtMoveType == Constants.EMoveType.MOVETYPE_WALK && iGroundEntity != -1);

    if ( keyInJump && bOnGround ) {
        return true;
    } else {
        return false;
    }
}

function plyIsFriendly(attacker, victim) {
    if ( attacker != victim && attacker.GetTeam() == victim.GetTeam() ) {
        return true;
    }
    return false;
}

function getItemIndex(item) {
    return NetProps.GetPropInt(item, "m_AttributeManager.m_Item.m_iItemDefinitionIndex");
}

// if ( !("bxfx_Hooks" in this) ) bxfx_Hooks <- {};
local hooks = {};
hook <-
{
    function Call(hookName, params) {
        if ( !(hookName in hooks) ) {
            hooks[hookName] <- {};
        }
        local hook = hooks[hookName];
        foreach ( call in hook ) {
            call(params);
        }
    }

    function Add(hook, key, callback) {
        if ( !(hook in hooks) ) {
            hooks[hook] <- {};
        }
        hooks[hook][key] <- callback;
    }

    function Remove(hook, key) {
        if ( !(hook in hooks) ) {
            hooks[hook] <- {};
        }

        delete hooks[hook][key];

        if ( hooks[hook].len() <= 0 ) {
            hooks[hook] <- null;
        }
    }

    function Dump() {
        printl("hooks = {")
        foreach ( k, v in hooks ) {
            printl("  [" + k + "] = " + v);
            foreach ( kk, vv in hooks[k] ) {
                printl("    [" + kk + "] = " + vv);
            }
        }
        printl("}");
    }
}

local bfx_jobs = [];
job <-
{
    isCreated = false

    function Destroy() {
        local e = null;
        while( e = Entities.FindByName(e, "bfx_job_processor")  ) {
            e.Kill();
        }
    }

    function Create() {
        job.Destroy();
        local e = SpawnEntityFromTable("info_target", {
            classname = "move_rope",
            targetname = "bfx_job_processor"
        });
        // Activate the think hook.
        if ( e.ValidateScriptScope() ) {
            // There doesn't seem to be a way to use a proper GameTick think hook.
            e.GetScriptScope()["Think"] <- function() {
                while( bfx_jobs.len() > 0 ) {
                    local callback = bfx_jobs.pop();
                    if ( Time() > callback.time ) {
                        callback.run();
                    } else {
                        // Not time to run yet, add it back into the list.
                        bfx_jobs.push(callback);
                    }
                }
            }
            AddThinkToEnt(e, "Think");
        }
        job.isCreated = true;
    }

    function Add(callback, runAfter = 0) {
        local time = Time()
        if ( runAfter > 0 ) {
            time = time + (runAfter/1000)
        }
        bfx_jobs.push(
            {
                run = callback,
                time = time
            }
        );
    }
}

function onEntityTick(callback) {
    local e = SpawnEntityFromTable("info_target", {
        classname = "move_rope",
        targetname = "bfx_info_tick"
    });
    printl( e.ValidateScriptScope() );
    // Activate the think hook.
    if ( e.ValidateScriptScope() ) {
        // There doesn't seem to be a way to use a proper GameTick think hook.
        e.GetScriptScope()["Think"] <- function() {
            Think = null;
            callback();
            e.Kill();
        }
        AddThinkToEnt(e, "Think");
    }
}

function clearThink(id = "base") {
    local ent = null;
    while( ent = Entities.FindByName(ent, "bfx_think_" + id)  )
    {
        printl("Removed " + ent);
        ent.Kill();
    }
}

function createThink(callback, id = "base") {
    // Setup a logic entity for the think hook.
    local e = SpawnEntityFromTable("info_target", {
        classname = "move_rope",
        targetname = "bfx_think_" + id
    })

    // Activate the think hook.
    if ( e.ValidateScriptScope() ) {
        // There doesn't seem to be a way to use a proper GameTick think hook.
        e.GetScriptScope()["Think"] <- callback;
        AddThinkToEnt(e, "Think");
    }
}

function verifyEntity(ent) {
    return (ent && ent.IsValid());
}

function IncludeScriptPrint(file, scope = null) {
    chatPrint(null, "  Loading: " + file);
    IncludeScript(file, scope);
}
