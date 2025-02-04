local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()

local Character = Player.Character or Player.CharacterAdded:Wait()

local Classes = script:WaitForChild("Classes")
local Weapon = require(Classes.Weapon)

local CurrentWeapon = nil -- Using this to assign and re-assign a new class

-- Functions

function Equip(Child : Instance)
	if Child.ClassName == "Tool" then -- Tool is used
		CurrentWeapon = Weapon.new(Child)
	end
end

function Unequip(Child : Instance)
	if Child.ClassName == "Tool" then
		CurrentWeapon:Destroy()
		CurrentWeapon = nil
	end
end

----------------------------------------

UserInputService.InputBegan:Connect(function(Input, gameProcessedEvent)
	if gameProcessedEvent == true then return end
	if CurrentWeapon == nil then return end

	if Input.UserInputType == Enum.UserInputType.MouseButton1 then
		CurrentWeapon:Fire(Mouse.Hit.Position) -- :Fire() method used
	elseif Input.KeyCode == Enum.KeyCode.R then
		CurrentWeapon:Reload() -- :Reload() method used
	end
end)

Character.ChildAdded:Connect(Equip)
Character.ChildRemoved:Connect(Unequip)

Player.CharacterAdded:Connect(function(CharacterAdded)
	Character = CharacterAdded
	
	Character.ChildAdded:Connect(Equip)
	Character.ChildRemoved:Connect(Unequip)
end)

