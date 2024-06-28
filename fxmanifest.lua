fx_version 'cerulean'
lua54 'yes'
game 'gta5'

version	'1.0'

client_scripts {
    'client/client.lua',
	'client/functions.lua'
}

server_scripts {
    'server/server.lua',
	'server/functions.lua'
}

shared_scripts {
    'config.lua',
}

ui_page 'web/ui.html'

files {
	'web/css/*',
	'web/js/script.js',
	'web/img/*',
	'web/ui.html',
}