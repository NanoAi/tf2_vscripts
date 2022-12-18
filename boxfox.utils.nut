function chatPrint(player, string) {
    ClientPrint(player, 3, "" + string);
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

function clearThink() {
    local ent = null;
    while( ent = Entities.FindByName(ent, "bfx_info_think")  )
    {
        printl("Removed " + ent);
        ent.Kill();
    }
}

function createThink(callback) {
    // Setup a logic entity for the think hook.
    local e = SpawnEntityFromTable("info_target", {
        classname = "move_rope",
        targetname = "bfx_info_think"
    })

    // Activate the think hook.
    if ( e.ValidateScriptScope() ) {
        // There doesn't seem to be a way to use a proper GameTick think hook.
        e.GetScriptScope()["Think"] <- callback;
        AddThinkToEnt(e, "Think");
    }
}
