fx_version 'cerulean'
game 'gta5'
lua54 'yes'

-- 🧢 CAPO
-- Outfitbag
-- 💬 Discord: capo_2001

description 'Outfitbag'

shared_script '@ox_lib/init.lua'
shared_script 'config.lua'

client_scripts {
    'client.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server.lua'
}
