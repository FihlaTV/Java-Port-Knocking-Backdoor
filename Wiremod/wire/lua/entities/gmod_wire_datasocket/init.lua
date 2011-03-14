
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

ENT.WireDebugName = "Socket"

local MODEL = Model( "models/hammy/pci_slot.mdl" )

//Time after loosing one plug to search for another
local NEW_PLUG_WAIT_TIME = 2
local PLUG_IN_SOCKET_CONSTRAINT_POWER = 5000
local PLUG_IN_ATTACH_RANGE = 3

function ENT:Initialize()
	self.Entity:SetModel( MODEL )
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
	self.Entity:SetSolid( SOLID_VPHYSICS )
	
	self.MyPlug = nil
	self.Memory = nil
	self.Const = nil
	
	self.Outputs = Wire_CreateOutputs(self.Entity, { "Memory" })
	self:SetOverlayText( "Data socket" )
	Wire_TriggerOutput(self.Entity, "Memory", 0)
end

function ENT:SetMemory(mement)
	self.Memory = mement
	Wire_TriggerOutput(self.Entity, "Memory", 1)
end

function ENT:Setup(a,ar,ag,ab,aa)
	self.A = a or 0
	self.AR = ar or 255
	self.AG = ag or 0
	self.AB = ab or 0
	self.AA = aa or 255

	self.Entity:SetColor(ar, ag, ab, aa)
end

function ENT:ReadCell( Address )
	if (self.Memory) then
		if (self.Memory.ReadCell) then
			return self.Memory:ReadCell( Address )
		else
			return nil
		end
	else
		return nil
	end
end

function ENT:WriteCell( Address, value )
	if (self.Memory) then
		if (self.Memory.WriteCell) then
			return self.Memory:WriteCell( Address, value )
		else
			return false
		end
	else
		return false
	end
end

function ENT:Think()
	self.BaseClass.Think(self)

	// If we were unplugged, reset the plug and socket to accept new ones.
	if (self.Const) and (not self.Const:IsValid()) then
		self.Const = nil
		self.NoCollideConst = nil
		if (self.MyPlug) and (self.MyPlug:IsValid()) then
			self.MyPlug:SetSocket(nil)
			self.MyPlug = nil
		end

		self.Memory = nil //We're now getting no signal
		Wire_TriggerOutput(self.Entity, "Memory", 0)

		self.Entity:NextThink( CurTime() + NEW_PLUG_WAIT_TIME ) //Give time before next grabbing a plug.
		return true
	end
	
	// If we have no plug in us
	if (not self.MyPlug) or (not self.MyPlug:IsValid()) then
		
		// Find entities near us
		local sockCenter = self:GetOffset( Vector(-1.75, 0, 0) )
		local local_ents = ents.FindInSphere( sockCenter, PLUG_IN_ATTACH_RANGE )
		for key, plug in pairs(local_ents) do

			// If we find a plug, try to attach it to us
			if ( plug:IsValid() && plug:GetClass() == "gmod_wire_dataplug" ) then
				
				// If no other sockets are using it
				if plug.MySocket == nil then
				    local plugpos = plug:GetPos()
					local dist = (sockCenter-plugpos):Length()

					self:AttachPlug(plug)
				end
			end
		end
	end
end

function ENT:AttachPlug( plug )
	// Set references between them
	plug:SetSocket(self.Entity)
	self.MyPlug = plug
	
	// Position plug
	local newpos = self:GetOffset( Vector(-1.75, 0, 0) )
	local socketAng = self.Entity:GetAngles()
	plug:SetPos( newpos )
	plug:SetAngles( socketAng )
	
	self.NoCollideConst = constraint.NoCollide(self.Entity, plug, 0, 0)
	if (not self.NoCollideConst) then
	    self.MyPlug = nil
		plug:SetSocket(nil)
	    self.Memory = nil
    	    Wire_TriggerOutput(self.Entity, "Memory", 0)
	    return
	end

	// Constrain together
	self.Const = constraint.Weld( self.Entity, plug, 0, 0, PLUG_IN_SOCKET_CONSTRAINT_POWER, true )
	if (not self.Const) then
	    self.NoCollideConst:Remove()
	    self.NoCollideConst = nil
	    self.MyPlug = nil
	    plug:SetSocket(nil)
	    self.Memory = nil
            Wire_TriggerOutput(self.Entity, "Memory", 0)
	    return
	end

	// Prepare clearup incase one is removed
	plug:DeleteOnRemove( self.Const )
	self.Entity:DeleteOnRemove( self.Const )
	self.Const:DeleteOnRemove( self.NoCollideConst )

	plug:AttachedToSocket(self.Entity)
end

function ENT:OnRestore()
	self.A = self.A or 0
	self.AR = self.AR or 255
	self.AG = self.AG or 0
	self.AB = self.AB or 0
	self.AA = self.AA or 255

    	self.BaseClass.OnRestore(self)
end