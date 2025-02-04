-- Handling visual particles

local Visuals = {}

function Visuals.MuzzleFlash(Muzzle, LifeTime : number)
	for _, v in ipairs(Muzzle:GetChildren()) do
		v.Enabled = true
	end

	task.wait(LifeTime)

	for _, v in ipairs(Muzzle:GetChildren()) do
		v.Enabled = false
	end
end

return Visuals
