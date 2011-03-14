TOOL.Category		= "Wire - Detection"
TOOL.Name			= "Damage Detector"
TOOL.Command		= nil
TOOL.ConfigName		= ""
TOOL.Tab			= "Wire"

if ( CLIENT ) then
    language.Add( "Tool_wire_damage_detector_name", "Damage Detector Tool (Wire)" )
    language.Add( "Tool_wire_damage_detector_desc", "Spawns a damage detector for use with the wire system" )
    language.Add( "Tool_wire_damage_detector_0", "Primary: Create/Update Detector, Secondary: Link Detector to an entity" )
	language.Add( "Tool_wire_damage_detector_1", "Now select the entity to link to." )
    language.Add( "WireDamageDetectorTool_includeconstrained", "Include Constrained Props" )
	language.Add( "sboxlimit_wire_damage_detectors", "You've hit damage detectors limit!" )
	language.Add( "undone_Wire Damage Detector", "Undone Wire Damage Detector" )
end

if ( SERVER ) then
	CreateConVar('sbox_maxwire_damage_detectors', 20)
	CreateConVar('sbox_wire_damage_detectors_includeconstrained',0)
end

TOOL.ClientConVar[ "includeconstrained" ] = "0"
TOOL.ClientConVar[ "Model" ] = "models/jaanus/wiretool/wiretool_siren.mdl"

cleanup.Register( "wire_damage_detectors" )

function TOOL:LeftClick( trace )
	if !trace.HitPos then return false end
	if trace.Entity:IsPlayer() then return false end
	if ( CLIENT ) then return true end
	
	self:SetStage(0)

	local model = self:GetClientInfo( "Model" )
	local ply = self:GetOwner()
	local includeconstrained = self:GetClientNumber( "includeconstrained" )
	
	if ( trace.Entity:IsValid() and trace.Entity:GetClass() == "gmod_wire_damage_detector" and trace.Entity.pl == ply ) then
		-- Update the detector's settings
		trace.Entity:Setup( includeconstrained )
		return true
	end

	if ( !self:GetSWEP():CheckLimit( "wire_damage_detectors" ) ) then return false end

	local Ang = trace.HitNormal:Angle()
	Ang.pitch = Ang.pitch + 90
	
	local wire_damage_detector = MakeWireDamageDetector( ply, trace.HitPos, Ang, model, includeconstrained )

	local min = wire_damage_detector:OBBMins()
	wire_damage_detector:SetPos( trace.HitPos - trace.HitNormal * min.z )

	local const = WireLib.Weld(wire_damage_detector, trace.Entity, trace.PhysicsBone, true)

	undo.Create("Wire Damage Detector")
		undo.AddEntity( wire_damage_detector )
		undo.AddEntity( const )
		undo.SetPlayer( ply )
	undo.Finish()

	ply:AddCleanup( "wire_damage_detectors", wire_damage_detector )
	
	return true
end

function TOOL:RightClick( trace )
	if ( !trace.HitPos ) then return false end
	if ( trace.Entity:IsPlayer() ) then return false end
	if ( CLIENT ) then return true end

	if ( ValidEntity(trace.Entity) ) then
		if ( self:GetStage() == 0 and trace.Entity:GetClass() == "gmod_wire_damage_detector" ) then
			self.detector = trace.Entity
			self:SetStage(1)
			return true
		elseif ( self:GetStage() == 1 ) then
			self.detector:LinkEntity( trace.Entity )
			self:SetStage(0)
			self:GetOwner():PrintMessage( HUD_PRINTTALK,"Damage Detector linked" )
			return true
		else
			self:SetStage(0)
			self:GetOwner():PrintMessage( HUD_PRINTTALK,"Invalid Target" )
			return false
		end
	end	
end

if ( SERVER ) then

	function MakeWireDamageDetector( pl, Pos, Ang, model, includeconstrained )
		if ( !pl:CheckLimit( "wire_damage_detectors" ) ) then return false end
	
		local wire_damage_detector = ents.Create( "gmod_wire_damage_detector" )
		if (!wire_damage_detector:IsValid()) then return false end

		wire_damage_detector:SetAngles( Ang )
		wire_damage_detector:SetPos( Pos )
		wire_damage_detector:SetModel( model )
		wire_damage_detector:Spawn()
		
		wire_damage_detector:Setup( includeconstrained )
		wire_damage_detector:LinkEntity( wire_damage_detector )	-- Link the detector to itself by default
		
		wire_damage_detector:SetPlayer( pl )

		local ttable = {
		    includeconstrained = includeconstrained,
			pl = pl
		}
		table.Merge(wire_damage_detector:GetTable(), ttable )
		
		pl:AddCount( "wire_damage_detectors", wire_damage_detector )

		return wire_damage_detector
	end
	
	duplicator.RegisterEntityClass("gmod_wire_damage_detector", MakeWireDamageDetector, "Pos", "Ang", "Model", "includeconstrained")

end

function TOOL:UpdateGhostWireDamageDetector( ent, player )
	if ( !ent or !ent:IsValid() ) then return end

	local tr 	= utilx.GetPlayerTrace( player, player:GetCursorAimVector() )
	local trace 	= util.TraceLine( tr )

	if (!trace.Hit or trace.Entity:IsPlayer() or trace.Entity:GetClass() == "gmod_wire_damage_detector" ) then
		ent:SetNoDraw( true )
		return
	end

	local Ang = trace.HitNormal:Angle()
	Ang.pitch = Ang.pitch + 90

	local min = ent:OBBMins()
	ent:SetPos( trace.HitPos - trace.HitNormal * min.z )
	ent:SetAngles( Ang )

	ent:SetNoDraw( false )
end

function TOOL:Think()
	if (!self.GhostEntity or !self.GhostEntity:IsValid() or self.GhostEntity:GetModel() != self:GetClientInfo("Model") ) then
		self:MakeGhostEntity( self:GetClientInfo("Model"), Vector(0,0,0), Angle(0,0,0) )
	end

	self:UpdateGhostWireDamageDetector( self.GhostEntity, self:GetOwner() )
end

function TOOL.BuildCPanel(panel)
	panel:AddControl("Header", { Text = "#Tool_wire_damage_detector_name", Description = "#Tool_wire_damage_detector_desc" })

	panel:AddControl("CheckBox", {
		Label = "#WireDamageDetectorTool_includeconstrained",
		Command = "wire_damage_detector_includeconstrained"
	})
end
