
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

local GlobalUndoList = {}

hook.Add("EntityRemoved", "wire_spawner_EntityRemoved", function(ent)
	if not GlobalUndoList[ent] then return end
	GlobalUndoList[ent]:CheckEnts(ent)
	GlobalUndoList[ent] = nil
end)

function ENT:Initialize()

	self.Entity:SetMoveType( MOVETYPE_NONE )
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetCollisionGroup( COLLISION_GROUP_WEAPON )
	self.Entity:DrawShadow( false )

	local phys = self.Entity:GetPhysicsObject()
	if (phys:IsValid()) then phys:Wake() end
	
	self.UndoList = {}
	
	-- Spawner is "edge-triggered"
	self.SpawnLastValue = 0
	self.UndoLastValue = 0
	
	-- Made more efficient by updating the overlay text and
	-- Wire output only when number of active props changes (TheApathetic)
	self.CurrentPropCount = 0
	
	-- Add inputs/outputs (TheApathetic)
	self.Inputs = WireLib.CreateSpecialInputs(self.Entity, { "Spawn", "Undo", "UndoEnt" }, { "NORMAL", "NORMAL", "ENTITY" })
	self.Outputs = WireLib.CreateSpecialOutputs(self.Entity, { "Out", "LastSpawned", "Props" }, { "NORMAL", "ENTITY", "ARRAY" })
	
	Wire_TriggerOutput(self.Entity, "Props", self.UndoList)
end

function ENT:Setup( delay, undo_delay )
	self.delay = delay
	self.undo_delay = undo_delay
	self:ShowOutput()
end

function ENT:DoSpawn( pl, down )
	
	local ent	= self.Entity
	if (not ent:IsValid()) then return end
	
	local phys	= ent:GetPhysicsObject()
	if (not phys:IsValid()) then return end
	
	local Pos	= ent:GetPos()
	local Ang	= ent:GetAngles()
	local model	= ent:GetModel()
	
	local prop = MakeProp( pl, Pos, Ang, model, {}, {} )
	if (not prop or not prop:IsValid()) then return end
	
	-- apply material and color (TAD2020)
	prop:SetMaterial( ent:GetMaterial() )
	prop:SetColor( self.r, self.g, self.b, self.a )
	
	-- set the skin {Jeremydeath}
	prop:SetSkin( ent:GetSkin() or 0 )
	
	-- apply the physic's objects properties
	local phys2 = prop:GetPhysicsObject()
	phys2:SetMass( phys:GetMass() ) -- known issue: while being held with the physgun, the spawner spawns 45k mass props. Could be worked around with a Think hook, but nah...
	
	if not ent:IsPlayerHolding() then -- minge protection :)
		phys2:SetVelocity( phys:GetVelocity() )
		phys2:AddAngleVelocity( phys:GetAngleVelocity() - phys2:GetAngleVelocity() ) -- No SetAngleVelocity, so we must subtract the current angular velocity
	end
	
	local nocollide = constraint.NoCollide( prop, ent, 0, 0 )
	if (nocollide:IsValid()) then prop:DeleteOnRemove( nocollide ) end
	
	undo.Create("Prop")
		undo.AddEntity( prop )
		undo.AddEntity( nocollide )
		undo.SetPlayer( pl )
	undo.Finish()
	
	pl:AddCleanup( "props", prop )
	pl:AddCleanup( "props", nocollide )
	
	table.insert( self.UndoList, 1, prop )
	GlobalUndoList[prop] = self.Entity
	
	Wire_TriggerOutput(self.Entity, "LastSpawned", prop)
	self.CurrentPropCount = #self.UndoList
	Wire_TriggerOutput(self.Entity, "Out", self.CurrentPropCount)
	Wire_TriggerOutput(self.Entity, "Props", self.UndoList)
	self:ShowOutput()
	
	if (self.undo_delay == 0) then return end
	
	timer.Simple( self.undo_delay, function( ent ) if ent:IsValid() then ent:Remove() end end, prop )
	
end

function ENT:DoUndo( pl )
	
	if #self.UndoList == 0 then return end
	
	local ent = self.UndoList[	#self.UndoList ]
	self.UndoList[	#self.UndoList ] = nil
	
	if (not ent or not ent:IsValid()) then
		return self:DoUndo(pl)
	end
	
	ent:Remove()
	WireLib.AddNotify(pl, "Undone Prop", NOTIFY_UNDO, 2 )
	
end

function ENT:DoUndoEnt( pl, ent )
	if (not ent or not ent:IsValid()) then return end
	
	if GlobalUndoList[ent] ~= self.Entity then return end
	
	ent:Remove()
	WireLib.AddNotify(pl, "Undone Prop", NOTIFY_UNDO, 2 )
	
end

function ENT:CheckEnts(removed_entity)
	-- Purge list of no longer existing props
	for i = #self.UndoList,1,-1 do
		local ent = self.UndoList[i]
		if not ValidEntity(ent) or ent == removed_entity then
			table.remove(self.UndoList, i)
		end
	end
	
	-- Check to see if active prop count has changed
	if (#self.UndoList ~= self.CurrentPropCount) then
		self.CurrentPropCount = #self.UndoList
		Wire_TriggerOutput(self.Entity, "Out", self.CurrentPropCount)
		Wire_TriggerOutput(self.Entity, "Props", self.UndoList)
		self:ShowOutput()
	end
end

function ENT:TriggerInput(iname, value)
	local pl = self:GetPlayer()
	
	if (iname == "Spawn") then
		-- Spawner is "edge-triggered" (TheApathetic)
		local SpawnThisValue = value > 0
		if (SpawnThisValue == self.SpawnLastValue) then return end
		self.SpawnLastValue = SpawnThisValue
		
		if (SpawnThisValue) then
			-- Simple copy/paste of old numpad Spawn with a few modifications
			if (self.delay == 0) then self:DoSpawn( pl ) return end
			
			local TimedSpawn = 	function ( ent, pl )
				if not ValidEntity(ent) then return end
				ent:DoSpawn( pl )
			end
			
			timer.Simple( self.delay, TimedSpawn, self.Entity, pl )
		end
	elseif (iname == "Undo") then
		-- Same here
		local UndoThisValue = value > 0
		if (UndoThisValue == self.UndoLastValue) then return end
		self.UndoLastValue = UndoThisValue
		
		if (UndoThisValue) then self:DoUndo(pl) end
	elseif (iname == "UndoEnt") then
		self:DoUndoEnt(pl, value)
	end
end

function ENT:ShowOutput()
	self:SetOverlayText("Spawn Delay: "..self.delay.."\nUndo Delay: "..self.undo_delay.."\nActive Props: "..self.CurrentPropCount)
end

function ENT:OnRemove()
	-- unregister spawned props from GlobalUndoList
	for _,ent in ipairs(self.UndoList) do
		GlobalUndoList[ent] = nil
	end
end