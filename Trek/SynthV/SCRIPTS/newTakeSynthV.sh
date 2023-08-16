#! /bin/bash
open -a "Synthesizer V Studio Pro" $1
osascript -e '

tell application "Synthesizer V Studio Pro"
	activate
end tell

tell application "System Events" to tell application process "Synthesizer V Studio Pro"
	set frontmost to true
end tell

tell application "System Events"
	set _P to a reference to application process "Synthesizer V Studio Pro"
	set _W to a reference to window 1 of _P
	repeat 20 times -- 10 seconds max. wait
		if _W exists then exit repeat
		delay 0.5
	end repeat
end tell

tell application "System Events"
	keystroke "f" using {command down, control down}
end tell

delay 0.2

tell application "System Events" to tell application process "Synthesizer V Studio Pro"
	
	click menu item "Select All" of menu 1 of menu item "Claires Scripts - Hotkey Scripts" of menu 1 of menu bar item "Scripts" of menu bar 1
	delay 0.1

	click menu item "Generate a New Take" of menu 1 of menu bar item "Auto-Process" of menu bar 1
	
	delay 1.5

		set target_button to a reference to (UI element "Bounce to Files") of window 1
		if not (target_button exists) then
			click menu item "Render Panel" of menu 1 of menu bar item "View" of menu bar 1
		end if
		repeat 40 times 
			if target_button exists then exit repeat
			delay 0.1
		end repeat
		click UI element "Bounce to Files" of window 1

	delay 0.5

	keystroke "s" using {command down}
	delay 0.1
	keystroke "q" using {command down}
	delay 0.1

	tell application "Alacritty.app"
		activate
	end tell
end tell

'
