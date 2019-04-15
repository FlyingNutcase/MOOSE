--- **Functional** - (R2.5) - Yet another missile trainer.
-- 
-- 
-- Train to evade missiles without being destroyed.
-- 
--
-- **Main Features:**
--
--     * Adaptive update of missile-to-player distance.
--     * F10 radio menu.
--     * Easy to use.
--     * Handles air-to-air and surface-to-air missiles.
--     * Alert on missile launch (optional).
--     * Marker of missile launch position (optional).
--     
-- ===
--
-- ### Author: **funkyfranky**
-- @module Functional.FOX2
-- @image Functional_FOX2.png


--- FOX2 class.
-- @type FOX2
-- @field #string ClassName Name of the class.
-- @field #boolean Debug Debug mode. Messages to all about status.
-- @field #string lid Class id string for output to DCS log file.
-- @extends Core.Fsm#FSM

--- Fox 2!
--
-- ===
--
-- ![Banner Image](..\Presentations\FOX2\FOX2_Main.png)
--
-- # The FOX2 Concept
-- 
-- 
-- 
-- @field #FOX2
FOX2 = {
  ClassName      = "FOX2",
  Debug          = false,
  lid            =   nil,
  menuadded      =    {},
  missiles       =    {},
  players        =    {},
  destroy        =   nil,
  safezones      =    {},
  launchzones    =    {},
  exlosionpower  =     5,
}


--- Player data table holding all important parameters of each player.
-- @type FOX2.PlayerData
-- @field Wrapper.Unit#UNIT unit Aircraft of the player.
-- @field #string unitname Name of the unit.
-- @field Wrapper.Client#CLIENT client Client object of player.
-- @field #string callsign Callsign of player.
-- @field Wrapper.Group#GROUP group Aircraft group of player.
-- @field #string groupname Name of the the player aircraft group.
-- @field #string name Player name.
-- @field #number coalition Coalition number of player.
-- @field #boolean destroy Destroy missile.
-- @field #boolean launchalert Alert player on detected missile launch.
-- @field #boolean marklaunch Mark position of launched missile on F10 map.
-- @field #number defeated Number of missiles defeated.
-- @field #number dead Number of missiles not defeated.

--- Missile data
-- @type FOX2.MissileData
-- @field #string missiletype Type of missile.
-- @field Wrapper.Unit#UNIT shooterunit Unit that shot the missile.
-- @field Wrapper.Group#GROUP shootergroup Group that shot the missile.
-- @field #number shottime Abs mission time in seconds the missile was fired.
-- @field Wrapper.Unit#UNIT targetunit Unit that was targeted.


--- Main radio menu on group level.
-- @field #table MenuF10 Root menu table on group level.
FOX2.MenuF10={}

--- Main radio menu on mission level.
-- @field #table MenuF10Root Root menu on mission level.
FOX2.MenuF10Root=nil

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- ToDo list
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- TODO list:
-- TODO: safe zones
-- TODO: mark shooter on F10

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Constructor
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--- Create a new FOX2 class object.
-- @param #FOX2 self
-- @return #FOX2 self.
function FOX2:New()

  self.lid="FOX2 | "

  -- Inherit everthing from FSM class.
  local self=BASE:Inherit(self, FSM:New()) -- #FOX2
  
  -- Start State.
  self:SetStartState("Stopped")

  -- Add FSM transitions.
  --                 From State  -->   Event      -->     To State
  self:AddTransition("Stopped",       "Start",           "Running")     -- Start FOX2 script.
  self:AddTransition("*",             "Status",          "*")           -- Start FOX2 script.

  ------------------------
  --- Pseudo Functions ---
  ------------------------

  --- Triggers the FSM event "Start". Starts the FOX2. Initializes parameters and starts event handlers.
  -- @function [parent=#FOX2] Start
  -- @param #FOX2 self

  --- Triggers the FSM event "Start" after a delay. Starts the FOX2. Initializes parameters and starts event handlers.
  -- @function [parent=#FOX2] __Start
  -- @param #FOX2 self
  -- @param #number delay Delay in seconds.

  --- Triggers the FSM event "Stop". Stops the FOX2 and all its event handlers.
  -- @param #FOX2 self

  --- Triggers the FSM event "Stop" after a delay. Stops the FOX2 and all its event handlers.
  -- @function [parent=#FOX2] __Stop
  -- @param #FOX2 self
  -- @param #number delay Delay in seconds.

  --- Triggers the FSM event "Status".
  -- @function [parent=#FOX2] Status
  -- @param #FOX2 self

  --- Triggers the FSM event "Status" after a delay.
  -- @function [parent=#FOX2] __Status
  -- @param #FOX2 self
  -- @param #number delay Delay in seconds.
  
  return self
end

--- On after Start event. Starts the missile trainer and adds event handlers.
-- @param #FOX2 self
-- @param #string From From state.
-- @param #string Event Event.
-- @param #string To To state.
function FOX2:onafterStart(From, Event, To)

  -- Short info.
  local text=string.format("Starting FOX2 Missile Trainer v0.0.1")
  env.info(text)

  -- Handle events:
  self:HandleEvent(EVENTS.Birth)
  self:HandleEvent(EVENTS.Shot)
  
  self:TraceClass(self.ClassName)
  self:TraceLevel(2)

  self:__Status(-1)
end

--- On after Stop event. Stops the missile trainer and unhandles events.
-- @param #FOX2 self
-- @param #string From From state.
-- @param #string Event Event.
-- @param #string To To state.
function FOX2:onafterStop(From, Event, To)

  -- Short info.
  local text=string.format("Stopping FOX2 Missile Trainer v0.0.1")
  env.info(text)

  -- Handle events:
  self:UnhandleEvent(EVENTS.Birth)
  self:UnhandleEvent(EVENTS.Shot)

end

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Status Functions
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--- Check spawn queue and spawn aircraft if necessary.
-- @param #FOX2 self
-- @param #string From From state.
-- @param #string Event Event.
-- @param #string To To state.
function FOX2:onafterStatus(From, Event, To)

  self:I(self.lid..string.format("Missile trainer status."))

  self:__Status(-30)
end

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Event Functions
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--- FOX2 event handler for event birth.
-- @param #FOX2 self
-- @param Core.Event#EVENTDATA EventData
function FOX2:OnEventBirth(EventData)
  self:F3({eventbirth = EventData})
  
  -- Nil checks.
  if EventData==nil then
    self:E(self.lid.."ERROR: EventData=nil in event BIRTH!")
    self:E(EventData)
    return
  end
  if EventData.IniUnit==nil then
    self:E(self.lid.."ERROR: EventData.IniUnit=nil in event BIRTH!")
    self:E(EventData)
    return
  end  
  
  -- Player unit and name.
  local _unitName=EventData.IniUnitName
  local playerunit, playername=self:_GetPlayerUnitAndName(_unitName)
  
  -- Debug info.
  self:T(self.lid.."BIRTH: unit   = "..tostring(EventData.IniUnitName))
  self:T(self.lid.."BIRTH: group  = "..tostring(EventData.IniGroupName))
  self:T(self.lid.."BIRTH: player = "..tostring(playername))
      
  -- Check if player entered.
  if playerunit and playername then
  
    local _uid=playerunit:GetID()
    local _group=playerunit:GetGroup()
    local _callsign=playerunit:GetCallsign()
    
    -- Debug output.
    local text=string.format("Pilot %s, callsign %s entered unit %s of group %s.", playername, _callsign, _unitName, _group:GetName())
    self:T(self.lid..text)
    MESSAGE:New(text, 5):ToAllIf(self.Debug)
            
    -- Add Menu commands.
    self:_AddF10Commands(_unitName)
    
    -- Player data.
    local playerData={} --#FOX2.PlayerData
    
    -- Player unit, client and callsign.
    playerData.unit      = playerunit
    playerData.unitname  = _unitName
    playerData.group     = _group
    playerData.groupname = _group:GetName()
    playerData.name      = playername
    playerData.callsign  = playerData.unit:GetCallsign()
    playerData.client    = CLIENT:FindByName(_unitName, nil, true)
    playerData.coalition = _group:GetCoalition()
    
    playerData.destroy=playerData.destroy or true
    playerData.launchalert=playerData.launchalert or true
    playerData.marklaunch=playerData.marklaunch or true
    
    playerData.defeated=playerData.defeated or 0
    playerData.dead=playerData.dead or 0
    
    -- Init player data.
    self.players[playername]=playerData
      
    -- Init player grades table if necessary.
    --self.playerscores[playername]=self.playerscores[playername] or {}    
    
  end 
end

--- FOX2 event handler for event shot (when a unit releases a rocket or bomb (but not a fast firing gun). 
-- @param #FOX2 self
-- @param Core.Event#EVENTDATA EventData
function FOX2:OnEventShot(EventData)
  self:I({eventshot = EventData})
  
  if EventData.Weapon==nil then
    return
  end
  if EventData.IniDCSUnit==nil then
    return
  end
  
  -- Weapon data.
  local _weapon     = EventData.WeaponName
  local _target     = EventData.Weapon:getTarget()
  local _targetName = "unknown"
  local _targetUnit = nil --Wrapper.Unit#UNIT
  
  -- Weapon descriptor.
  local desc=EventData.Weapon:getDesc()
  --self:E({desc=desc})
  
  -- Weapon category: 0=Shell, 1=Missile, 2=Rocket, 3=BOMB
  local weaponcategory=desc.category
  
  -- Missile category=
  local missilecategory=desc.missileCategory
  
  -- Debug info.
  self:E(FOX2.lid.."EVENT SHOT: FOX2")
  self:E(FOX2.lid..string.format("EVENT SHOT: Ini unit    = %s", tostring(EventData.IniUnitName)))
  self:E(FOX2.lid..string.format("EVENT SHOT: Ini group   = %s", tostring(EventData.IniGroupName)))
  self:E(FOX2.lid..string.format("EVENT SHOT: Weapon type = %s", tostring(_weapon)))
  self:E(FOX2.lid..string.format("EVENT SHOT: Weapon cate = %s", tostring(weaponcategory)))
  self:E(FOX2.lid..string.format("EVENT SHOT: Missil cate = %s", tostring(missilecategory)))
  if _target then
    self:E({target=_target})
    --_targetName=Unit.getName(_target)
    --_targetUnit=UNIT:FindByName(_targetName)
    _targetUnit=UNIT:Find(_target)
  end
  self:E(FOX2.lid..string.format("EVENT SHOT: Target name = %s", tostring(_targetName)))
    
  -- Track missiles of type AAM=1, SAM=2 or OTHER=6
  local _track = weaponcategory==1 and missilecategory and (missilecategory==1 or missilecategory==2 or missilecategory==6) 
    
  -- Get shooter.
  local shooterUnit = EventData.IniUnit
  local shooterName = EventData.IniUnitName
  local shooterCoalition=shooterUnit:GetCoalition()
  local shooterCoord=shooterUnit:GetCoordinate()

  -- Only track missiles
  if _track then
  
    local missile={} --#FOX2.MissileData
    
    --missile.missiletype=_weapontype
    
    -- Tracking info and init of last bomb position.
    self:I(FOX2.lid..string.format("FOX2: Tracking %s - %s.", _weapon, EventData.weapon:getName()))
    
    -- Loop over players.
    for _,_player in pairs(self.players) do
      local player=_player  --#FOX2.PlayerData
      
      -- Player position.
      local playerUnit=player.unit
      
      if playerUnit and playerUnit:IsAlive() then
      
        local distance=playerUnit:GetCoordinate():Get3DDistance(shooterCoord)
        local bearing=playerUnit:GetCoordinate():HeadingTo(shooterCoord)
        
        if _targetUnit and player.launchalert and player.coalition~=shooterCoalition then
        
          -- Inform players.
          local text=string.format("Missile launch detected! Distance %.1f NM, bearing %03d�.", UTILS.MetersToNM(distance), bearing)
          MESSAGE:New(text, 5, "ALERT"):ToClient(player.client)
          
          if player.marklaunch then
            local text=string.format("Missile launch coordinates:\n%s\n%s", shooterCoord:ToStringLLDMS(), shooterCoord:ToStringBULLS(player.coalition))          
            shooterCoord:MarkToGroup(text, player.group)
          end
        end
      end
    end              
    
    -- Init missile position.
    local _lastBombPos = {x=0,y=0,z=0}
    
    -- Target unit of the missile.
    local target=nil --Wrapper.Unit#UNIT    
        
    --- Function monitoring the position of a bomb until impact.
    local function trackMissile(_ordnance)

      -- When the pcall returns a failure the weapon has hit.
      local _status,_bombPos =  pcall(
      function()
        return _ordnance:getPoint()
      end)

      --self:T3(FOX2.lid..string.format("FOX2: Missile still in air: %s", tostring(_status)))
      if _status then
      
        ----------------------------------------------
        -- Still in the air. Remember this position --
        ----------------------------------------------
        
        -- Missile position.
        _lastBombPos = {x=_bombPos.x, y=_bombPos.y, z=_bombPos.z}
        
        -- Missile coordinate.
        local missileCoord=COORDINATE:NewFromVec3(_lastBombPos)
        
        -- Missile velocity in m/s.
        local missileVelocity=UTILS.VecNorm(_ordnance:getVelocity())
        
        if _targetUnit then
          -----------------------------------
          -- Missile has a specific target --
          -----------------------------------
        
          target=_targetUnit
          
        else
          
          -- Distance to closest player.
          local mindist=nil
          
          -- Loop over players.
          for _,_player in pairs(self.players) do
            local player=_player  --#FOX2.PlayerData
            
            -- Player position.
            local playerCoord=player.unit:GetCoordinate()
            
            -- Distance.            
            local dist=missileCoord:Get3DDistance(playerCoord)
            
            -- Update mindist if necessary.
            if mindist==nil or dist<mindist then
              mindist=dist
              target=player.unit
            end            
          end
          
        end

        -- Check if missile has a valid target.
        if target then
        
          local targetCoord=target:GetCoordinate()
        
          local distance=missileCoord:Get3DDistance(targetCoord)
          local bearing=targetCoord:HeadingTo(missileCoord)
          local eta=distance/missileVelocity
          
          self:T2(self.lid..string.format("Distance = %.1f m, v=%.1f m/s, bearing=%03d�, eta=%.1f sec", distance, missileVelocity, bearing, eta))
        
          if distance<100 then
          
            -- Destroy missile.
            self:T(self.lid..string.format("Destroying missile at distance %.1f m", distance))
            _ordnance:destroy()
            
            -- Little explosion for the visual effect.
            missileCoord:Explosion(10)
            
            local text="Destroying missile. You're dead!"
            MESSAGE:New(text, 10):ToGroup(target:GetGroup())
            
            -- Terminate timer.
            return nil
          else
          
            -- Time step.
            local dt=1.0          
            if distance>50000 then
              -- > 50 km
              dt=5.0
            elseif distance>10000 then
              -- 10-50 km
              dt=1.0
            elseif distance>5000 then
              -- 5-10 km
              dt=0.5
            elseif distance>1000 then
              -- 1-5 km
              dt=0.1
            else
              -- < 1 km
              dt=0.01
            end
          
            -- Check again in dt seconds.
            return timer.getTime()+dt
          end
        else
        
          -- No target ==> terminate timer.
          return nil
        end
        
      else
      
        -------------------------------------
        -- Missile does not exist any more --
        -------------------------------------
              
        if target then  
          local player=self:_GetPlayerFromUnitname(target:GetName())
          if player then
            local text=string.format("Missile defeated. Well done, %s!", player.name)
            MESSAGE:New(text, 10):ToClient(player.client)
          end
        end        
                
        --Terminate the timer.
        self:T(FOX2.lid..string.format("Terminating missile track timer."))
        return nil

      end -- _status check
      
    end -- end function trackBomb

    -- Weapon is not yet "alife" just yet. Start timer with a little delay.
    self:T(FOX2.lid..string.format("Tracking of missile starts in 0.1 seconds."))
    timer.scheduleFunction(trackMissile, EventData.weapon, timer.getTime()+0.1)
    
  end --if _track
  
end


-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- RADIO MENU Functions
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------

--- Add menu commands for player.
-- @param #FOX2 self
-- @param #string _unitName Name of player unit.
function FOX2:_AddF10Commands(_unitName)
  self:F(_unitName)
  
  -- Get player unit and name.
  local _unit, playername = self:_GetPlayerUnitAndName(_unitName)
  
  -- Check for player unit.
  if _unit and playername then

    -- Get group and ID.
    local group=_unit:GetGroup()
    local gid=group:GetID()
      
    if group and gid then
  
      if not self.menuadded[gid] then
      
        -- Enable switch so we don't do this twice.
        self.menuadded[gid]=true
        
        -- Set menu root path.
        local _rootPath=nil
        if FOX2.MenuF10Root then
          ------------------------
          -- MISSON LEVEL MENUE --
          ------------------------          
           
          -- F10/FOX2/...
          _rootPath=FOX2.MenuF10Root
         
        else
          ------------------------
          -- GROUP LEVEL MENUES --
          ------------------------
          
          -- Main F10 menu: F10/FOX2/
          if FOX2.MenuF10[gid]==nil then
            FOX2.MenuF10[gid]=missionCommands.addSubMenuForGroup(gid, "FOX2")
          end
          
          -- F10/FOX2/...
          _rootPath=FOX2.MenuF10[gid]
          
        end
        
        
        --------------------------------        
        -- F10/F<X> FOX2/F1 Help
        --------------------------------
        local _helpPath=missionCommands.addSubMenuForGroup(gid, "Help", _rootPath)
        -- F10/FOX2/F1 Help/
        --missionCommands.addCommandForGroup(gid, "Subtitles On/Off",    _helpPath, self._SubtitlesOnOff,      self, _unitName)   -- F7
        --missionCommands.addCommandForGroup(gid, "Trapsheet On/Off",    _helpPath, self._TrapsheetOnOff,      self, _unitName)   -- F8

        -------------------------
        -- F10/F<X> FOX2/
        -------------------------
        
        missionCommands.addCommandForGroup(gid, "Launch Alerts On/Off",    _rootPath, self._ToggleLaunchAlert,     self, _unitName) -- F2
        missionCommands.addCommandForGroup(gid, "Destroy Missiles On/Off", _rootPath, self._ToggleDestroyMissiles, self, _unitName) -- F3
        
      end
    else
      self:E(self.lid..string.format("ERROR: Could not find group or group ID in AddF10Menu() function. Unit name: %s.", _unitName))
    end
  else
    self:E(self.lid..string.format("ERROR: Player unit does not exist in AddF10Menu() function. Unit name: %s.", _unitName))
  end

end


--- Turn player's launch alert on/off.
-- @param #FOX2 self
-- @param #string _unitname Name of the player unit.
function FOX2:_ToggleLaunchAlert(_unitname)
  self:F2(_unitname)
  
  -- Get player unit and player name.
  local unit, playername = self:_GetPlayerUnitAndName(_unitname)
  
  -- Check if we have a player.
  if unit and playername then
  
    -- Player data.  
    local playerData=self.players[playername]  --#FOX2.PlayerData
    
    if playerData then
    
      -- Invert state.
      playerData.launchalert=not playerData.launchalert
      
      -- Inform player.
      local text=""
      if playerData.launchalert==true then
        text=string.format("%s, missile launch alerts are now ENABLED.", playerData.name)
      else
        text=string.format("%s, missile launch alerts are now DISABLED.", playerData.name)
      end
      MESSAGE:New(text, 5):ToClient(playerData.client)
            
    end
  end
end

--- Turn player's 
-- @param #FOX2 self
-- @param #string _unitname Name of the player unit.
function FOX2:_ToggleDestroyMissiles(_unitname)
  self:F2(_unitname)
  
  -- Get player unit and player name.
  local unit, playername = self:_GetPlayerUnitAndName(_unitname)
  
  -- Check if we have a player.
  if unit and playername then
  
    -- Player data.  
    local playerData=self.players[playername]  --#FOX2.PlayerData
    
    if playerData then
    
      -- Invert state.
      playerData.destroy=not playerData.destroy
      
      -- Inform player.
      local text=""
      if playerData.destroy==true then
        text=string.format("%s, incoming missiles will be DESTROYED.", playerData.name)
      else
        text=string.format("%s, incoming missiles will NOT be DESTROYED.", playerData.name)
      end
      MESSAGE:New(text, 5):ToClient(playerData.client)
            
    end
  end
end


---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Misc Functions
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--- Returns the unit of a player and the player name. If the unit does not belong to a player, nil is returned. 
-- @param #FOX2 self
-- @param #string unitName Name of the unit.
-- @return #FOX2.PlayerData Player data.
function FOX2:_GetPlayerFromUnitname(unitName)

  for _,_player in pairs(self.players) do  
    local player=_player --#FOX2.PlayerData
    
    if player.unitname==unitName then
      return player
    end
  end
  
  return nil
end

--- Returns the unit of a player and the player name. If the unit does not belong to a player, nil is returned. 
-- @param #FOX2 self
-- @param #string _unitName Name of the player unit.
-- @return Wrapper.Unit#UNIT Unit of player or nil.
-- @return #string Name of the player or nil.
function FOX2:_GetPlayerUnitAndName(_unitName)
  self:F2(_unitName)

  if _unitName ~= nil then
    
    -- Get DCS unit from its name.
    local DCSunit=Unit.getByName(_unitName)
    
    if DCSunit then
    
      -- Get player name if any.
      local playername=DCSunit:getPlayerName()
      
      -- Unit object.
      local unit=UNIT:Find(DCSunit)
    
      -- Debug.
      self:T2({DCSunit=DCSunit, unit=unit, playername=playername})
      
      -- Check if enverything is there.
      if DCSunit and unit and playername then
        self:T(self.lid..string.format("Found DCS unit %s with player %s.", tostring(_unitName), tostring(playername)))
        return unit, playername
      end
      
    end
    
  end
  
  -- Return nil if we could not find a player.
  return nil,nil
end

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------