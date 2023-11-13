--[[
    Author: maalos/regex
    Date: 13.11.2023
]]

---------------------------------------- global definitions

local comp = {"wheel_rf_dummy", "wheel_lf_dummy", "wheel_rb_dummy", "wheel_lb_dummy"}

---------------------------------------- functions

function doesTheVehicleHaveACustomWheelSet(vehicle)
    if not vehicle or not isElement(vehicle) then return false end
    if isElement(getElementData(vehicle, "wheel_rf_dummy")) then
        return true
    end
    return false
end

function createCustomWheelSet(vehicle, modelId)
    if not vehicle or not isElement(vehicle) then return false end
    if not modelId then modelId = 1096 end
    local rx, ry, rz = getElementRotation(vehicle)
    for _, component in ipairs(comp) do
        local x, y, z = getVehicleComponentPosition(vehicle, component, "world")
        local wheel = createObject(modelId, x, y, z, rx, ry, rz)
        setObjectScale(wheel, 1, 0.75, 0.75)
        setVehicleComponentVisible(vehicle, component, false)
        setElementData(vehicle, component, wheel)
    end
    return true
end

function removeCustomWheelSet(vehicle)
    if not vehicle or not isElement(vehicle) then return end
    for _, component in ipairs(comp) do
        destroyElement(getElementData(vehicle, component))
        setElementData(vehicle, component, nil)
        setVehicleComponentVisible(vehicle, component, true)
    end
    return true
end

function setCustomWheelSetCamber(vehicle, camberValue)
    if not vehicle or not isElement(vehicle) then return end
    return setElementData(vehicle, "camberValue", tonumber(camberValue))
end

---------------------------------------- events

addEvent("requestDoesTheVehicleHaveACustomWheelSet", true) -- THIS ONE IS UNTESTED
addEventHandler("requestDoesTheVehicleHaveACustomWheelSet", root, function(vehicle)
    triggerServerEvent("responseDoesTheVehicleHaveACustomWheelSet", localPlayer, doesTheVehicleHaveACustomWheelSet(vehicle))
end)

addEvent("requestCreateCustomWheelSet", true)
addEventHandler("requestCreateCustomWheelSet", root, createCustomWheelSet)

addEvent("requestRemoveCustomWheelSet", true)
addEventHandler("requestRemoveCustomWheelSet", root, removeCustomWheelSet)

addEvent("requestSetCustomWheelSetCamber", true)
addEventHandler("requestSetCustomWheelSetCamber", root, setCustomWheelSetCamber)

---------------------------------------- commands

addCommandHandler("setcamber", function(_, camberValue)
    if not camberValue or not tonumber(camberValue) then camberValue = 0 end
    local vehicle = getPedOccupiedVehicle(localPlayer)
    if not vehicle then return outputChatBox("You're not in a vehicle!") end
    if not doesTheVehicleHaveACustomWheelSet(vehicle) then
        createCustomWheelSet(vehicle)
    end
    setCustomWheelSetCamber(vehicle, camberValue)
    outputChatBox("Set the wheel set camber to " .. tostring(camberValue))
end)

addCommandHandler("defaultwheels", function()
    local vehicle = getPedOccupiedVehicle(localPlayer)
    if not vehicle then return outputChatBox("You're not in a vehicle!") end
    if doesTheVehicleHaveACustomWheelSet(vehicle) then
        removeCustomWheelSet(vehicle)
    end
    setCustomWheelSetCamber(vehicle, 0)
    outputChatBox("Set the wheel set to default")
end)

---------------------------------------- rendering

addEventHandler("onClientPreRender", root, function()
    for _, vehicle in ipairs(getElementsByType("vehicle")) do
        if isElement(getElementData(vehicle, "wheel_rf_dummy")) then
            local camberValue = getElementData(vehicle, "camberValue")
            if not camberValue then camberValue = 0 end
            for _, component in ipairs(comp) do
                local x, y, z = getVehicleComponentPosition(vehicle, component, "world")
                local rx, ry, rz = getVehicleComponentRotation(vehicle, component)
                local vrx, vry, vrz = getElementRotation(vehicle)
                if component:sub(7, 7) == "l" then
                    vry = -vry
                end
                setElementRotation(getElementData(vehicle, component), rx + vrx, ry + vry + camberValue, rz + vrz, "ZYX")
                setElementPosition(getElementData(vehicle, component), x, y, z)
            end
        end
    end
end)
