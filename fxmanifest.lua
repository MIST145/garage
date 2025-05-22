fx_version 'cerulean'
game 'gta5'

author 'James'
description 'Garage System with ESX Legacy and OX_Lib Support'
version '2.0.0'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua'
}

client_scripts {
    'client/functions.lua',
    'client/main.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua',
    'server/functions.lua',
    'server/database.lua'
}

dependencies {
    'es_extended',
    'ox_lib',
    'oxmysql'
}

lua54 'yes'
