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

        hooks[hook][key] <- null;

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

function onEntityTick(callback, context) {
    local e = SpawnEntity("info_target", {
        classname = "move_rope",
        targetname = "bfx_info_tick"
    });
    if ( e.ValidateScriptScope() ) {
        e.GetScriptScope()["Think"] <- function() {
            callback();
            e.Kill();
        };
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
