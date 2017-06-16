
fullscreenEnabled = document.fullscreenEnabled ? document.mozFullScreenEnabled ? document.documentElement.webkitRequestFullScreen

requestFullscreen = (element)->
	if element.requestFullscreen
		element.requestFullscreen()
	else if element.mozRequestFullScreen
		element.mozRequestFullScreen()
	else if element.webkitRequestFullScreen
		element.webkitRequestFullScreen(Element.ALLOW_KEYBOARD_INPUT)

addEventListener "keydown", (e)->
	console.log e.keyCode if e.altKey
	return if e.ctrlKey or e.altKey or e.metaKey
	return if e.target.tagName.match /input|button|select|textarea/i
	e.preventDefault() if e.keyCode in [32, 39, 38, 37, 40]
	switch e.keyCode
		when 82 # R
			restart_button.click()
		when 77 # M
			toggle_mute_button.click()
		when 70 # F
			fullscreen_button.click()

# toggle_mute_button = document.getElementById("toggle-mute")
fullscreen_button = document.getElementById("fullscreen")
restart_button = document.getElementById("open-restart-dialogue")
restart_dialogue = document.getElementById("restart-dialogue")
do_restart_button = document.getElementById("do-restart")
cancel_restart_button = document.getElementById("cancel-restart")
dialogPolyfill.registerDialog(restart_dialogue)

fullscreen_button.onclick = ->
	if fullscreenEnabled
		requestFullscreen(document.documentElement)

###
muted = no
toggle_mute_button.onclick = ->
	if muted
		Howler.unmute()
	else
		Howler.mute()
	muted = not muted
	toggle_mute_button.className = if muted then "unmute" else "mute"
###

restart_button.onclick = ->
	restart_dialogue.showModal()

do_restart_button.onclick = ->
	start_puzzle()
	restart_dialogue.close()

cancel_restart_button.onclick = ->
	restart_dialogue.close()

do_restart_button.addEventListener "keydown", (e)->
	if e.keyCode is 39
		cancel_restart_button.focus()

cancel_restart_button.addEventListener "keydown", (e)->
	if e.keyCode is 37
		do_restart_button.focus()
