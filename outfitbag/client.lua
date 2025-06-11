local ESX = exports["es_extended"]:getSharedObject()
local bagEntity = nil
local bagCoords = nil
local isNearBag = false
local isSharingOutfits = false
local sharedOutfits = {}
local ownBagId = nil

RegisterNetEvent('outfitbag:useItem', function()
    local playerPed = PlayerPedId()
    local animDict = "anim@mp_fireworks"
    local animName = "place_firework_3_box"

    RequestAnimDict(animDict)
    while not HasAnimDictLoaded(animDict) do Wait(0) end
    TaskPlayAnim(playerPed, animDict, animName, 8.0, -8.0, 1500, 49, 0, false, false, false)
    Wait(1500)
    ClearPedTasks(playerPed)

    TriggerServerEvent('outfitbag:removeItem')

    local forwardPos = GetOffsetFromEntityInWorldCoords(playerPed, 0.0, 0.7, -1.0)
    local heading = GetEntityHeading(playerPed)
    local model = Config.PropModel

    RequestModel(model)
    while not HasModelLoaded(model) do Wait(0) end

    bagCoords = forwardPos
    bagEntity = CreateObject(model, bagCoords.x, bagCoords.y, bagCoords.z, true, true, true)
    SetEntityHeading(bagEntity, heading - 180.0)
    PlaceObjectOnGroundProperly(bagEntity)
    FreezeEntityPosition(bagEntity, true)

    isNearBag = true
    isSharingOutfits = false
    ownBagId = GetPlayerServerId(PlayerId())

    TriggerServerEvent('outfitbag:setSharingState', bagCoords, false)

    CreateThread(function()
        while isNearBag do
            local pedCoords = GetEntityCoords(PlayerPedId())
            if #(pedCoords - bagCoords) < 2.0 then
                Config.HelpNotifyExport(Config.Texts.OpenPrompt .. ' | [G] Aufheben')

                if IsControlJustPressed(0, 38) then
                    openOutfitMenu()
                elseif IsControlJustPressed(0, 47) then
                    TaskPlayAnim(playerPed, animDict, animName, 8.0, -8.0, 1500, 49, 0, false, false, false)
                    Wait(1500)
                    ClearPedTasks(playerPed)

                    if DoesEntityExist(bagEntity) then
                        DeleteEntity(bagEntity)
                    end
                    isNearBag = false
                    isSharingOutfits = false
                    ownBagId = nil
                    Config.HelpNotifyHide()
                    TriggerServerEvent('outfitbag:setSharingState', bagCoords, false)
                    TriggerServerEvent('outfitbag:giveItem')
                end
            else
                Config.HelpNotifyHide()
            end
            Wait(0)
        end
    end)
end)

RegisterNetEvent('outfitbag:updateSharedOutfits', function(data)
    sharedOutfits = data
end)



function openOutfitMenu()
    Config.HelpNotifyHide()
    local options = {
        {
            title = Config.Texts.SaveOutfit,
            icon = 'save',
            onSelect = function()
                local input = lib.inputDialog(Config.Texts.SaveOutfit, {
                    {type = 'input', label = Config.Texts.EnterName, required = true}
                })
                if input and input[1] then
                    local called = false
                    TriggerEvent('esx_skin:getPlayerSkin', function(skin)
                        if not called then
                            called = true
                            TriggerServerEvent('outfitbag:saveOutfit', input[1], skin)
                        end
                    end)
                    TriggerEvent('skinchanger:getSkin', function(skin)
                        if not called then
                            called = true
                            TriggerServerEvent('outfitbag:saveOutfit', input[1], skin)
                        end
                    end)
                    SetTimeout(3000, function()
                        if not called then
                            Config.NotifyExport("Konnte Skin nicht laden", "error")
                        end
                    end)
                end
            end
        },
        {
            title = Config.Texts.DeleteOutfit,
            icon = 'trash',
            onSelect = function()
                TriggerServerEvent('outfitbag:requestOutfits')
            end
        },
        {
            title = 'Outfit anziehen',
            icon = 'tshirt',
            onSelect = function()
                TriggerServerEvent('outfitbag:loadOutfitsForWear')
            end
        },
        {
            title = 'Outfit umbenennen',
            icon = 'pen',
            onSelect = function()
                TriggerServerEvent('outfitbag:requestOutfitsForRename')
            end
        }
    }

    lib.registerContext({
        id = 'outfit_menu',
        title = 'Outfit Tasche',
        options = options
    })

    lib.showContext('outfit_menu')
end




RegisterNetEvent('outfitbag:sendOutfits', function(outfits)
    if #outfits == 0 then
        Config.NotifyExport(Config.Texts.NoOutfits, 'error')
        return
    end

    local options = {}
    for _, data in ipairs(outfits) do
        table.insert(options, {
            title = data.name,
            icon = 'tshirt',
            onSelect = function()
                TriggerServerEvent('outfitbag:deleteOutfit', data.name)
            end
        })
    end

    lib.registerContext({
        id = 'outfit_delete_menu',
        title = Config.Texts.DeleteOutfit,
        menu = 'outfit_menu',
        options = options
    })

    lib.showContext('outfit_delete_menu')
end)

RegisterNetEvent('outfitbag:selectOutfitToWear', function(outfits)
    if #outfits == 0 then
        Config.NotifyExport("Keine gespeicherten Outfits vorhanden.", "error")
        return
    end

    local options = {}
    for _, outfit in pairs(outfits) do
        table.insert(options, {
            title = outfit.name,
            icon = 'shirt',
            onSelect = function()
                TriggerServerEvent('outfitbag:wearOutfit', outfit.name)
            end
        })
    end

    lib.registerContext({
        id = 'wear_outfit_menu',
        title = 'Outfit anziehen',
        menu = 'outfit_menu',
        options = options
    })

    lib.showContext('wear_outfit_menu')
end)

-- 🔁 Animation & Outfit-Wechsel
RegisterNetEvent('outfitbag:playChangeAnim', function(skinData)
    local ped = PlayerPedId()

    -- Hilfsfunktion für Animation
    local function playAnim(dict, anim, dur)
        RequestAnimDict(dict)
        while not HasAnimDictLoaded(dict) do Wait(0) end
        TaskPlayAnim(ped, dict, anim, 8.0, -8.0, dur, 49, 0, false, false, false)
        Wait(dur)
        ClearPedTasksImmediately(ped)
    end

    -- === AUSZIEHEN ===

    -- 1. Oberteil ausziehen
    playAnim("missmic4", "michael_tux_fidget", 1500)
    TriggerEvent('skinchanger:loadClothes', skinData, {
        ['tshirt_1'] = 15, ['tshirt_2'] = 0,
        ['torso_1'] = 15, ['torso_2'] = 0,
        ['arms'] = 15
    })

    -- 2. Hose ausziehen
    playAnim("re@construction", "out_of_breath", 1300)
    TriggerEvent('skinchanger:loadClothes', skinData, {
        ['pants_1'] = 0, ['pants_2'] = 0
    })

    -- 3. Schuhe ausziehen
    playAnim("random@domestic", "pickup_low", 1200)
    TriggerEvent('skinchanger:loadClothes', skinData, {
        ['shoes_1'] = 0, ['shoes_2'] = 0
    })

    -- === ANZIEHEN ===

    -- 4. Oberteil anziehen
    playAnim("missmic4", "michael_tux_fidget", 1500)

    -- 5. Hose anziehen
    playAnim("re@construction", "out_of_breath", 1300)

    -- 6. Schuhe anziehen
    playAnim("random@domestic", "pickup_low", 1200)

    -- Skin vollständig laden
    Wait(250)
    TriggerEvent('skinchanger:loadSkin', skinData)
end)

RegisterNetEvent('outfitbag:renameOutfitList', function(outfits)
    if #outfits == 0 then
        Config.NotifyExport("Keine gespeicherten Outfits vorhanden.", "error")
        return
    end

    local options = {}
    for _, outfit in pairs(outfits) do
        table.insert(options, {
            title = outfit.name,
            icon = 'pen',
            onSelect = function()
                local input = lib.inputDialog("Neuer Name für '" .. outfit.name .. "'", {
                    {type = 'input', label = "Neuer Name", required = true}
                })
                if input and input[1] then
                    TriggerServerEvent('outfitbag:renameOutfit', outfit.name, input[1])
                end
            end
        })
    end

    lib.registerContext({
        id = 'rename_outfit_menu',
        title = 'Outfit umbenennen',
        menu = 'outfit_menu',
        options = options
    })

    lib.showContext('rename_outfit_menu')
end)
