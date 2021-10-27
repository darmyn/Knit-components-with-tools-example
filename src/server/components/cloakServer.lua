--[[

    You still need to impl better debounce protection.
    You forgot to add remote protection checking if the correct player is firing the signals.
    You must sync a timer between the server and the client and display it on screen.
    You must add support for sounds and animations.

]]

print("running CloakServer.lua")
local ReplicationdStorage = game:GetService("ReplicatedStorage")

local knit = require(ReplicationdStorage.modules.Knit)
local janitor = require(knit.Util.Janitor)

local config = {
    replicatedTransparency = 1;
    maxActions = 3;
    debounceLength = 2;
    maxInvisibilityDuration = 5;
}
local invisiblePlayers = {}
local cloakServer = {}
cloakServer.__index = cloakServer
cloakServer.Tag = "Cloak"

function cloakServer.new(instance)
    print("new cloak", instance)
    local onActivation = Instance.new("RemoteEvent")
    local onDeactivation = Instance.new("RemoteEvent")
    local onReplication = Instance.new("RemoteEvent")
    local activatedSound = Instance.new("Sound")
    local deactivatedSound = Instance.new("Sound")
    onActivation.Name = "onActivation"
    onDeactivation.Name = "onDeactivation"
    onReplication.Name = "onReplication"
    activatedSound.Name = "activatedSound"
    deactivatedSound.Name = "deactivatedSound"
    activatedSound.SoundId = "rbxassetid://7846485351"
    deactivatedSound.SoundId = "rbxassetid://7846485351"
    onActivation.Parent = instance
    onDeactivation.Parent = instance
    onReplication.Parent = instance
    activatedSound.Parent = instance
    deactivatedSound.Parent = instance
    return setmetatable({
        janitor = janitor.new();
        onActivation = onActivation;
        onDeactivation = onDeactivation;
        onReplication = onReplication
    }, cloakServer)
end

function cloakServer:Init()
    self.janitor:Add(self.onActivation.OnServerEvent:Connect(function(player)
        if not invisiblePlayers[player.UserId] then
            invisiblePlayers[player.UserId] = true
            self.onReplication:FireAllClients(player.Name, config.replicatedTransparency)
            local clock = os.clock()
            while invisiblePlayers[player.UserId] do
                if os.clock() - clock >= config.maxInvisibilityDuration then
                    self.onReplication:FireAllClients(player.Name, 0, true)
                    break
                end
                task.wait(.1)
            end
        end
    end))
    self.janitor:Add(self.onDeactivation.OnServerEvent:Connect(function(player)
        print("ATTEMPTING DEACTIVATION")
        if invisiblePlayers[player.UserId] then
            print("statement passed")
            invisiblePlayers[player.UserId] = nil
            self.onReplication:FireAllClients(player.Name, 0)
            print("replication complete on server end")
        end
    end))
end

function cloakServer:Destroy()
    self.janitor:Destroy()
end


return cloakServer