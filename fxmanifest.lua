fx_version 'cerulean'
game 'gta5'

author 'NeverMind'
description 'Job Craft System'
version '1.0.0'

shared_scripts {
    'functions.lua',
    'config.lua',
    '@es_extended/locale.lua',
	'locales/*.lua'
}

server_scripts {
    '@mysql-async/lib/MySQL.lua',
    'main/server.lua'
}

client_scripts {
    'main/client.lua'
}