local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Engine = ReplicatedStorage.Engine

local Modules = Engine.Modules
local SecureCast = require(Modules.SecureCast)

local Events = Engine.Events
local FireEvent = Events.Fire

local Modifier = {
	Power = 1_000
}

SecureCast.Initialize()

FireEvent.OnServerEvent:Connect(function(Player, Origin, Direction, Timestamp, Gun : Tool)
	local Latency = workspace:GetServerTimeNow() - Timestamp
	--print()
	
	SecureCast.Cast(Player, Gun.Name, Origin, Direction, workspace:GetServerTimeNow() - Latency, Modules.SecureCast.Projectiles.Bullet, Modifier)
	FireEvent:FireAllClients(Player, Origin, Direction, Modifier)
end)
