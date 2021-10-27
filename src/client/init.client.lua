local replicatedStorage = game:GetService("ReplicatedStorage")
local knit = require(replicatedStorage.modules.Knit)
local component = require(knit.Util.Component)

local components: Folder = script.components



component.Auto(components)
knit.Start():catch(warn)