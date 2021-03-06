local weldl, weldr = {}, {}
local reachmult = {}

local function grabinput(ply, cmd)
	if not IsValid(ply:GetRagdollEntity()) or not ply:Alive() then return end
	if not IsValid(ply:GetRagdollEntity():GetPhysicsObject()) then return end

	local body = ply:GetRagdollEntity()
	local hips = body:GetPhysicsObjectNum(0)
	local gut = body:GetPhysicsObjectNum(1)
	local right_shoulder = body:GetPhysicsObjectNum(2)
	local left_shoulder = body:GetPhysicsObjectNum(3)
	local left_elbow = body:GetPhysicsObjectNum(4)
	local left_wrist = body:GetPhysicsObjectNum(5)
	local right_elbow = body:GetPhysicsObjectNum(6)
	local right_wrist = body:GetPhysicsObjectNum(7)
	local right_hip_joint = body:GetPhysicsObjectNum(8)
	local right_knee = body:GetPhysicsObjectNum(9)
	local head = body:GetPhysicsObjectNum(10)
	local left_hip_joint = body:GetPhysicsObjectNum(11)
	local left_knee = body:GetPhysicsObjectNum(12)
	local left_ankle = body:GetPhysicsObjectNum(13)
	local right_ankle = body:GetPhysicsObjectNum(14)
	--Tuck
	if cmd:KeyDown(IN_DUCK) then
		left_hip_joint:AddAngleVelocity(Vector(0, 0, -100))
		right_hip_joint:AddAngleVelocity(Vector(0, 0, -100))

		left_knee:AddAngleVelocity(Vector(0, 0, 100))
		right_knee:AddAngleVelocity(Vector(0, 0, 100))

		gut:AddAngleVelocity(Vector(0, 0, 100))

		local handpos = (((left_knee:GetPos() + left_ankle:GetPos()) / 2 + left_knee:GetAngles():Right() * 5) - left_wrist:GetPos())
		handpos:Normalize()
		left_wrist:ApplyForceCenter(handpos * 100)
		local handpos = (((right_knee:GetPos() + right_ankle:GetPos()) / 2 + right_knee:GetAngles():Right() * 5) - right_wrist:GetPos())
		handpos:Normalize()
		right_wrist:ApplyForceCenter(handpos * 100)

		head:AddAngleVelocity(Vector(0, 0, 100))
	end
	--Plank
	if cmd:KeyDown(IN_SPEED) then
		for i = 1, body:GetPhysicsObjectCount()-1 do
			local bone = body:GetPhysicsObjectNum(i)
			local pos = -body:WorldToLocal(head:GetPos())
			
			pos = body:LocalToWorld(pos) - body:GetPos()
			pos:Normalize()
			bone:ApplyForceCenter(pos * 100)
		end
		local pos = body:WorldToLocal(head:GetPos()) * 2
		pos = body:LocalToWorld(pos) - body:GetPos()
		pos:Normalize()
		head:ApplyForceCenter(pos * 1500)
	end
	--Air Control
	if  body:GetVelocity().z < -500 then
		if not cmd:KeyDown(IN_DUCK) and not cmd:KeyDown(IN_SPEED) then
			for i = 1, body:GetPhysicsObjectCount()-1 do
				local bone = body:GetPhysicsObjectNum(i)
				local pos = bone:GetPos() - body:GetPos()
				pos:Normalize()
				bone:ApplyForceCenter(pos * 200)
			end
			local pos = body:WorldToLocal(head:GetPos()) * 2
			pos = body:LocalToWorld(pos) - body:GetPos()
			pos:Normalize()
			head:ApplyForceCenter(pos * 20)
		end
		if not body.SaidJumpLine then
			body:EmitSound(table.Random(SOUNDS.male.jumping), 100, 100 + math.random(-10, 10))
			body.SaidJumpLine = true
		end
	end
	--Rotation
	if cmd:KeyDown(IN_FORWARD) then
		gut:AddAngleVelocity(Vector(0, 0, 50))
	end
	if cmd:KeyDown(IN_BACK) then
		gut:AddAngleVelocity(Vector(0, 0, -50))
	end
	if cmd:KeyDown(IN_MOVELEFT) then
		gut:AddAngleVelocity(Vector(-50, 0, 0))
	end
	if cmd:KeyDown(IN_MOVERIGHT) then
		gut:AddAngleVelocity(Vector(50, 0, 0))
	end
	--Left Arm
	if cmd:KeyDown(IN_ATTACK) then
		left_wrist:ApplyForceCenter(ply:GetAimVector() * 200 * reachmult[ply:EntIndex()] or 1)
	end
	--Right Arm
	if cmd:KeyDown(IN_ATTACK2) then
		right_wrist:ApplyForceCenter(ply:GetAimVector() * 200 * reachmult[ply:EntIndex()] or 1)
	end
	--Grab
	if cmd:KeyDown(IN_ATTACK) then
		if cmd:KeyDown(IN_USE) and not weldl[ply:EntIndex()] then
			local td = {}
			td.start = left_wrist:GetPos()
			td.endpos = left_wrist:GetPos()
			td.mins = Vector(-5, -5, -5)
			td.maxs = Vector(5, 5, 5)
			td.filter = {ply:GetRagdollEntity(), ply}
			td.mask = MASK_SOLID
			local tr = util.TraceHull(td)
			if tr.Hit and not tr.Entity:IsPlayer() then
				left_wrist:SetPos(tr.HitPos)
				weldl[ply:EntIndex()] = constraint.Weld(ply:GetRagdollEntity(), tr.Entity, 5, tr.PhysicsBone, 10000, false, false)
			end
		end
	else
		if IsValid(weldl[ply:EntIndex()]) then
			weldl[ply:EntIndex()]:Remove()
		end
		weldl[ply:EntIndex()] = nil
	end
	if cmd:KeyDown(IN_ATTACK2) then
		if cmd:KeyDown(IN_USE) and not weldr[ply:EntIndex()] then
			local td = {}
			td.start = right_wrist:GetPos()
			td.endpos = right_wrist:GetPos()
			td.mins = Vector(-10, -5, -5)
			td.maxs = Vector(5, 5, 5)
			td.mask = MASK_SOLID
			td.filter = {ply:GetRagdollEntity(), ply}
			local tr = util.TraceHull(td)
			if tr.Hit and not tr.Entity:IsPlayer() then
				right_wrist:SetPos(tr.HitPos)
				weldr[ply:EntIndex()] = constraint.Weld(ply:GetRagdollEntity(), tr.Entity, 7, tr.PhysicsBone, 10000, false, false)
			end
		end
	else
		if IsValid(weldr[ply:EntIndex()]) then
			weldr[ply:EntIndex()]:Remove()
		end
		weldr[ply:EntIndex()] = nil
	end
	if not (IsValid(weldl[ply:EntIndex()]) == IsValid(weldr[ply:EntIndex()])) then
		reachmult[ply:EntIndex()] = 3
	elseif IsValid(weldl[ply:EntIndex()]) then
		reachmult[ply:EntIndex()] = 0
	else
		reachmult[ply:EntIndex()] = 1
	end
end
hook.Add("Move", "puppetinput", grabinput)