fx_version 'cerulean'
use_experimental_fxv2_oal 'yes'
lua54        'yes'
games { 'gta5' }

ox_libs {
  'locale',
}

shared_scripts {
    'config.lua'
}

server_scripts {
    '@mysql-async/lib/MySQL.lua', -- For ESX
    '@oxmysql/lib/MySQL.lua',    -- For QBCore (if you're using oxmysql for QBCore)
    'server/main.lua',
    'server/esx.lua',
    'server/qbcore.lua'
}

client_scripts {
    'client/main.lua',
    'client/esx.lua',
    'client/qbcore.lua'
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/script.js',
    'web/build/index.html',
    'web/build/**/*',
    'locales/*.json',
    'client/*.lua',
    'client/framework/*.lua',
    'config.lua'
}
