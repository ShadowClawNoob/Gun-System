local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local player = Players.LocalPlayer

local Engine = ReplicatedStorage:WaitForChild("Engine")

local Modules = Engine.Modules
local SecureCast = require(Modules.SecureCast)  -- Module responsible for projectile casting (external module)

local Objects = script.Parent.Parent:WaitForChild("Objects")
local Visuals = require(Objects.Visuals)

local Events = Engine.Events
local FireEvent = Events.Fire

SecureCast.Initialize()  -- Initialize the SecureCast module

local gunClass = {}
gunClass.__index = gunClass

function gunClass.new(toolChosen)
	local self = setmetatable({}, gunClass)

	self.Tool = toolChosen
	self.Settings = require(self.Tool.Settings)

	self.Character = player.Character or player.CharacterAdded:Wait()
	self.Humanoid = self.Character:WaitForChild("Humanoid")
	self.Animator = self.Humanoid:WaitForChild("Animator")

	self.Shooting = false
	self.Reloading = false

	-- Default projectile type and modifiers
	self.ChosenProjectile = Modules.SecureCast.Projectiles.Bullet
	self.Modifier = { Power = 1_000 }

	-- Ammo setup 
	if self.Tool:GetAttribute("Ammo") ~= nil then -- if the gun was unequipped and has bullets remaining
		self.Ammo = self.Tool:GetAttribute("Ammo")
	else
		self.Ammo = self.Settings.Ammo
	end

	-- Load animations
	self.AnimationTracks = {
		["Idle"] = self.Animator:LoadAnimation(self.Tool.Animations.Idle),
		["Fire"] = self.Animator:LoadAnimation(self.Tool.Animations.Fire),
		["Reload"] = self.Animator:LoadAnimation(self.Tool.Animations.Reload)
	}
	self.AnimationTracks["Idle"]:Play()

	-- Flag to track if the gun has been destroyed
	self.Destroyed = false

	return self
end

-- Function to handle firing logic
function gunClass:Fire(MousePosition)
	if self.Destroyed == true
		or self.Tool == nil 
		or self.Settings == nil 
		or self.Shooting == true
		or self.Reloading == true
		or self.Ammo <= 0
	then return end

	self.Shooting = true

	local Muzzle : Attachment = self.Tool.Handle.Muzzle
	local Origin = Muzzle.WorldPosition
	local Direction = (MousePosition - Origin).Unit

	-- Cast the projectile using SecureCast
	SecureCast.Cast(player, "Pistol", Origin, Direction, workspace:GetServerTimeNow(), self.ChosenProjectile, self.Modifier)
	FireEvent:FireServer(Origin, Direction, workspace:GetServerTimeNow(), self.Tool)

	self.Ammo = self.Ammo - 1
	self.AnimationTracks["Fire"]:Play()
	self.Tool.Handle.Fire:Play()

	-- Trigger visual muzzle flash
	Visuals.MuzzleFlash(Muzzle, 0.03)

	-- Apply fire rate delay
	task.wait(self.Settings.FireRate)
	self.Shooting = false 
end

-- Function to handle weapon reloading
function gunClass:Reload()
	-- Prevent reloading if conditions are not met
	if self.Destroyed == true
		or self.Tool == nil
		or self.Settings == nil
		or self.Ammo == self.Settings.Ammo
		or self.Reloading == true 
	then return end

	self.Reloading = true

	-- Play reload animation and wait until it finishes
	self.AnimationTracks["Reload"]:Play()
	self.AnimationTracks["Reload"].Stopped:Wait()

	self.Ammo = self.Settings.Ammo
	self.Reloading = false 
end

function gunClass:Destroy()
	if self.Destroyed == true then return end

	self.Destroyed = true
	self.Tool:SetAttribute("Ammo", self.Ammo)  -- Save current ammo state

	self.AnimationTracks["Idle"]:Stop()
	
	table.clear(self.AnimationTracks) -- clear animation table to prevent memory leaks
end

return gunClass
