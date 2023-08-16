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

--delay 0.1
tell application "System Events"
	keystroke "f" using {command down, control down}
end tell
delay 0.2
tell application "System Events" 
	tell application process "Synthesizer V Studio Pro"
		set target_button to a reference to (UI element "Bounce to Files") of window 1
		if not (target_button exists) then
			click menu item "Render Panel" of menu 1 of menu bar item "View" of menu bar 1
		end if
		delay 0.1
		click UI element "Bounce to Files" of window 1
	end tell
	# tell application "Alacritty.app"
	tell application "WezTerm.app"
		activate
	end tell
end tell
'
