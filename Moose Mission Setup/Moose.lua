env.info( '*** MOOSE DYNAMIC INCLUDE START *** ' )
env.info( 'Moose Generation Timestamp: 20170628_1556' )

local base = _G

__Moose = {}

__Moose.Include = function( LuaPath, IncludeFile )
	if not __Moose.Includes[ IncludeFile ] then
		__Moose.Includes[IncludeFile] = IncludeFile
		local f = assert( base.loadfile( LuaPath .. IncludeFile ) )
		if f == nil then
			error ("Moose: Could not load Moose file " .. IncludeFile )
		else
			env.info( "Moose: " .. IncludeFile .. " dynamically loaded from " .. __Moose.ProgramPath )
			return f()
		end
	end
end

__Moose.ProgramPath = "Scripts/Moose/"

__Moose.Includes = {}
__Moose.Include( __Moose.ProgramPath, 'Utilities/Routines.lua' )
__Moose.Include( __Moose.ProgramPath, 'Utilities/Utils.lua' )
__Moose.Include( __Moose.ProgramPath, 'Core/Base.lua' )
__Moose.Include( __Moose.ProgramPath, 'Core/Scheduler.lua' )
__Moose.Include( __Moose.ProgramPath, 'Core/ScheduleDispatcher.lua' )
__Moose.Include( __Moose.ProgramPath, 'Core/Event.lua' )
__Moose.Include( __Moose.ProgramPath, 'Core/Settings.lua' )
__Moose.Include( __Moose.ProgramPath, 'Core/Menu.lua' )
__Moose.Include( __Moose.ProgramPath, 'Core/Zone.lua' )
__Moose.Include( __Moose.ProgramPath, 'Core/Database.lua' )
__Moose.Include( __Moose.ProgramPath, 'Core/Set.lua' )
__Moose.Include( __Moose.ProgramPath, 'Core/Point.lua' )
__Moose.Include( __Moose.ProgramPath, 'Core/Message.lua' )
__Moose.Include( __Moose.ProgramPath, 'Core/Fsm.lua' )
__Moose.Include( __Moose.ProgramPath, 'Core/Radio.lua' )
__Moose.Include( __Moose.ProgramPath, 'Core/SpawnStatic.lua' )
__Moose.Include( __Moose.ProgramPath, 'Core/Cargo.lua' )
__Moose.Include( __Moose.ProgramPath, 'Core/Spot.lua' )
__Moose.Include( __Moose.ProgramPath, 'Wrapper/Object.lua' )
__Moose.Include( __Moose.ProgramPath, 'Wrapper/Identifiable.lua' )
__Moose.Include( __Moose.ProgramPath, 'Wrapper/Positionable.lua' )
__Moose.Include( __Moose.ProgramPath, 'Wrapper/Controllable.lua' )
__Moose.Include( __Moose.ProgramPath, 'Wrapper/Group.lua' )
__Moose.Include( __Moose.ProgramPath, 'Wrapper/Unit.lua' )
__Moose.Include( __Moose.ProgramPath, 'Wrapper/Client.lua' )
__Moose.Include( __Moose.ProgramPath, 'Wrapper/Static.lua' )
__Moose.Include( __Moose.ProgramPath, 'Wrapper/Airbase.lua' )
__Moose.Include( __Moose.ProgramPath, 'Wrapper/Scenery.lua' )
__Moose.Include( __Moose.ProgramPath, 'Functional/Scoring.lua' )
__Moose.Include( __Moose.ProgramPath, 'Functional/CleanUp.lua' )
__Moose.Include( __Moose.ProgramPath, 'Functional/Spawn.lua' )
__Moose.Include( __Moose.ProgramPath, 'Functional/Movement.lua' )
__Moose.Include( __Moose.ProgramPath, 'Functional/Sead.lua' )
__Moose.Include( __Moose.ProgramPath, 'Functional/Escort.lua' )
__Moose.Include( __Moose.ProgramPath, 'Functional/MissileTrainer.lua' )
__Moose.Include( __Moose.ProgramPath, 'Functional/AirbasePolice.lua' )
__Moose.Include( __Moose.ProgramPath, 'Functional/Detection.lua' )
__Moose.Include( __Moose.ProgramPath, 'Functional/Designate.lua' )
__Moose.Include( __Moose.ProgramPath, 'AI/AI_Balancer.lua' )
__Moose.Include( __Moose.ProgramPath, 'AI/AI_A2A.lua' )
__Moose.Include( __Moose.ProgramPath, 'AI/AI_A2A_Patrol.lua' )
__Moose.Include( __Moose.ProgramPath, 'AI/AI_A2A_Cap.lua' )
__Moose.Include( __Moose.ProgramPath, 'AI/AI_A2A_Gci.lua' )
__Moose.Include( __Moose.ProgramPath, 'AI/AI_A2A_Dispatcher.lua' )
__Moose.Include( __Moose.ProgramPath, 'AI/AI_Patrol.lua' )
__Moose.Include( __Moose.ProgramPath, 'AI/AI_Cap.lua' )
__Moose.Include( __Moose.ProgramPath, 'AI/AI_Cas.lua' )
__Moose.Include( __Moose.ProgramPath, 'AI/AI_Bai.lua' )
__Moose.Include( __Moose.ProgramPath, 'AI/AI_Formation.lua' )
__Moose.Include( __Moose.ProgramPath, 'Actions/Act_Assign.lua' )
__Moose.Include( __Moose.ProgramPath, 'Actions/Act_Route.lua' )
__Moose.Include( __Moose.ProgramPath, 'Actions/Act_Account.lua' )
__Moose.Include( __Moose.ProgramPath, 'Actions/Act_Assist.lua' )
__Moose.Include( __Moose.ProgramPath, 'Tasking/CommandCenter.lua' )
__Moose.Include( __Moose.ProgramPath, 'Tasking/Mission.lua' )
__Moose.Include( __Moose.ProgramPath, 'Tasking/Task.lua' )
__Moose.Include( __Moose.ProgramPath, 'Tasking/DetectionManager.lua' )
__Moose.Include( __Moose.ProgramPath, 'Tasking/Task_A2G_Dispatcher.lua' )
__Moose.Include( __Moose.ProgramPath, 'Tasking/Task_A2G.lua' )
__Moose.Include( __Moose.ProgramPath, 'Tasking/Task_A2A_Dispatcher.lua' )
__Moose.Include( __Moose.ProgramPath, 'Tasking/Task_A2A.lua' )
__Moose.Include( __Moose.ProgramPath, 'Tasking/Task_Cargo.lua' )
__Moose.Include( __Moose.ProgramPath, 'Moose.lua' )
BASE:TraceOnOff( true )

local info = debug.getinfo( 1, "S" )
local source = info.source -- #string
local dir = source:match("^(.*)/")
BASE:E( {"source", source})
BASE:E( { "dir", dir } )

__Moose.MissionPath = dir .. "Mission\\l10n\\DEFAULT\\"


env.info( '*** MOOSE INCLUDE END *** ' )
