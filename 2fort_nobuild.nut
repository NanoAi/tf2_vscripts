hook.Add("ge_teamplay_round_start", "2fort.nut", function(p) {
  local trigger = SpawnEntityFromTable("func_nobuild",
  {
    origin = Vector(-81.392, -36.576, 154.109)
  });
  trigger.SetSize(Vector(-599, -557, -500), Vector(599, 557, 500));
  trigger.SetSolid(2); // SOLID_BBOX
  DebugDrawTrigger(trigger, 255, 0, 0, 100, 120);
});


// 1198.148,1113.228,998.578
// 599, 557, 500

function DebugDrawTrigger(trigger, r, g, b, alpha, duration)
{
	local origin = trigger.GetOrigin()
	local mins = NetProps.GetPropVector(trigger, "m_Collision.m_vecMins")
	local maxs = NetProps.GetPropVector(trigger, "m_Collision.m_vecMaxs")
	if (trigger.GetSolid() == 2)
		DebugDrawBox(origin, mins, maxs, r, g, b, alpha, duration)
	else if (trigger.GetSolid() == 3)
		DebugDrawBoxAngles(origin, mins, maxs, trigger.GetAbsAngles(), Vector(r, g, b), alpha, duration)
}

SendToServerConsole("mp_restartgame_immediate 1");
