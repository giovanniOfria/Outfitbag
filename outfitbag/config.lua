Config = {}

Config.ItemName = 'kq_outfitbag'
Config.PropModel = 'prop_big_bag_01'
Config.MaxOutfits = 10

Config.NotifyExport = function(msg, type)
    lib.notify({ title = 'Outfitbag', description = msg, type = type or 'info' })
end

Config.HelpNotifyExport = function(msg)
    lib.showTextUI(msg)
end

Config.HelpNotifyHide = function()
    lib.hideTextUI()
end

Config.Texts = {
    OpenPrompt = '[E] Outfit-Tasche öffnen',
    SaveOutfit = 'Outfit speichern',
    DeleteOutfit = 'Outfit löschen',
    EnterName = 'Gib einen Namen ein',
    OutfitSaved = 'Outfit gespeichert.',
    OutfitDeleted = 'Outfit gelöscht.',
    MaxReached = 'Du hast die maximale Anzahl an Outfits erreicht.',
    NoOutfits = 'Keine Outfits vorhanden.'
}
