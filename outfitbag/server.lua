local ESX = exports["es_extended"]:getSharedObject()

-- Outfit speichern
RegisterServerEvent('outfitbag:saveOutfit')
AddEventHandler('outfitbag:saveOutfit', function(name, skin)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer or not skin or type(skin) ~= "table" then
        TriggerClientEvent('ox_lib:notify', src, {description = "Ungültiger Skin.", type = 'error'})
        return
    end

    MySQL.query('SELECT COUNT(*) as count FROM user_outfits WHERE identifier = ?', {xPlayer.identifier}, function(result)
        if result[1].count >= Config.MaxOutfits then
            TriggerClientEvent('ox_lib:notify', src, {description = Config.Texts.MaxReached, type = 'error'})
            return
        end

        MySQL.insert('INSERT INTO user_outfits (identifier, name, skin) VALUES (?, ?, ?)', {
            xPlayer.identifier, name, json.encode(skin)
        }, function(id)
            if id then
                TriggerClientEvent('ox_lib:notify', src, {description = Config.Texts.OutfitSaved, type = 'success'})
            end
        end)
    end)
end)

-- Outfit-Liste für Löschen
RegisterServerEvent('outfitbag:requestOutfits')
AddEventHandler('outfitbag:requestOutfits', function()
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return end

    MySQL.query('SELECT name FROM user_outfits WHERE identifier = ?', {xPlayer.identifier}, function(result)
        local outfits = {}
        for _, row in ipairs(result) do
            table.insert(outfits, { name = row.name })
        end
        TriggerClientEvent('outfitbag:sendOutfits', src, outfits)
    end)
end)

-- Outfit löschen
RegisterServerEvent('outfitbag:deleteOutfit')
AddEventHandler('outfitbag:deleteOutfit', function(name)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return end

    MySQL.execute('DELETE FROM user_outfits WHERE identifier = ? AND name = ?', {
        xPlayer.identifier, name
    }, function(rowsChanged)
        TriggerClientEvent('ox_lib:notify', src, {description = Config.Texts.OutfitDeleted, type = 'success'})
    end)
end)

-- Outfitliste zum Anziehen öffnen
RegisterServerEvent('outfitbag:loadOutfitsForWear')
AddEventHandler('outfitbag:loadOutfitsForWear', function()
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return end

    MySQL.query('SELECT name FROM user_outfits WHERE identifier = ?', {xPlayer.identifier}, function(result)
        local outfits = {}
        for _, row in ipairs(result) do
            table.insert(outfits, { name = row.name })
        end
        TriggerClientEvent('outfitbag:selectOutfitToWear', src, outfits)
    end)
end)

-- Outfit anwenden (inkl. Animation + Speicherung)
RegisterServerEvent('outfitbag:wearOutfit')
AddEventHandler('outfitbag:wearOutfit', function(name)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return end

    MySQL.query('SELECT skin FROM user_outfits WHERE identifier = ? AND name = ?', {
        xPlayer.identifier, name
    }, function(result)
        if not result[1] then
            TriggerClientEvent('ox_lib:notify', src, {description = "Outfit nicht gefunden.", type = 'error'})
            return
        end

        local skinData = json.decode(result[1].skin)

        -- Skin in Datenbank speichern (z. B. für char reload)
        MySQL.update('UPDATE users SET skin = ? WHERE identifier = ?', {
            json.encode(skinData), xPlayer.identifier
        })

        -- Erst Animation auf Client ausführen, dann Skin laden
        TriggerClientEvent('outfitbag:playChangeAnim', src, skinData)

        -- Feedback
        TriggerClientEvent('ox_lib:notify', src, {
            description = "Outfit angezogen: " .. name,
            type = 'success'
        })
    end)
end)

-- Item verwendbar machen
ESX.RegisterUsableItem(Config.ItemName, function(source)
    TriggerClientEvent('outfitbag:useItem', source)
end)

RegisterNetEvent('outfitbag:removeItem')
AddEventHandler('outfitbag:removeItem', function()
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer then
        xPlayer.removeInventoryItem(Config.ItemName, 1)
    end
end)

RegisterNetEvent('outfitbag:giveItem')
AddEventHandler('outfitbag:giveItem', function()
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer then
        xPlayer.addInventoryItem(Config.ItemName, 1)
    end
end)

RegisterServerEvent('outfitbag:requestOutfitsForRename')
AddEventHandler('outfitbag:requestOutfitsForRename', function()
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return end

    MySQL.query('SELECT name FROM user_outfits WHERE identifier = ?', {xPlayer.identifier}, function(result)
        local outfits = {}
        for _, row in ipairs(result) do
            table.insert(outfits, { name = row.name })
        end
        TriggerClientEvent('outfitbag:renameOutfitList', src, outfits)
    end)
end)

-- Outfit umbenennen
RegisterServerEvent('outfitbag:renameOutfit')
AddEventHandler('outfitbag:renameOutfit', function(oldName, newName)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return end

    -- Check ob neuer Name bereits vergeben ist
    MySQL.query('SELECT 1 FROM user_outfits WHERE identifier = ? AND name = ?', {
        xPlayer.identifier, newName
    }, function(result)
        if result and result[1] then
            TriggerClientEvent('ox_lib:notify', src, {
                description = "Ein Outfit mit diesem Namen existiert bereits.",
                type = 'error'
            })
            return
        end

        -- Umbenennen
        MySQL.update('UPDATE user_outfits SET name = ? WHERE identifier = ? AND name = ?', {
            newName, xPlayer.identifier, oldName
        }, function(affectedRows)
            if affectedRows and affectedRows > 0 then
                TriggerClientEvent('ox_lib:notify', src, {
                    description = "Outfit umbenannt in '" .. newName .. "'",
                    type = 'success'
                })
            else
                TriggerClientEvent('ox_lib:notify', src, {
                    description = "Fehler beim Umbenennen.",
                    type = 'error'
                })
            end
        end)
    end)
end)


-- Server-side
local sharedOutfits = {}

RegisterNetEvent('outfitbag:setSharingState', function(coords, state)
    local src = source
    if state then
        sharedOutfits[src] = coords
    else
        sharedOutfits[src] = nil
    end
    TriggerClientEvent('outfitbag:updateSharedOutfits', -1, sharedOutfits)
end)

ESX.RegisterServerCallback('outfitbag:getSharedOutfits', function(source, cb)
    cb(sharedOutfits)
end)
