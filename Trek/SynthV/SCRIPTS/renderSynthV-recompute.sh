#! /bin/bash
# open -a "Synthesizer V Studio Pro" $1
# delay 2
# yabai -m window --toggle zoom-fullscreen
APP_NAME="Synthesizer V Studio Pro"

# Open the application
open -a "$APP_NAME" $1

# Wait for the application to launch
sleep 2

# Get the window ID of the newly opened application
WINDOW_ID=$(yabai -m query --windows | jq -r ".[] | select(.app == \"$APP_NAME\") | .id")

if [ -z "$WINDOW_ID" ]; then
  echo "Failed to find window for $APP_NAME."
  exit 1
fi

# Use Yabai to make the window fullscreen
yabai -m window "$WINDOW_ID" --toggle zoom-fullscreen

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
# do shell script "yabai -m window --toggle zoom-fullscreen"
	# delay 0.1
tell application "System Events"
	# keystroke "f" using {command down, control down}
	# delay 1
	 # keystroke "f" using {shift down, option down}
end tell

delay 0.05

tell application "System Events" to tell application process "Synthesizer V Studio Pro"
# delay 3.5
	
		set target_button to a reference to (UI element "Bounce to Files") of window 1

delay 0.5
		 if not (target_button exists) then
		 	click menu item "Render Panel" of menu 1 of menu bar item "View" of menu bar 1
		 end if

		# repeat 40 times 
		# 	delay 0.5
		# 	if target_button exists then exit repeat
		# 	click menu item "Render Panel" of menu 1 of menu bar item "View" of menu bar 1
		# end repeat

	click menu item "Select All" of menu 1 of menu item "Claires Scripts - Hotkey Scripts" of menu 1 of menu bar item "Scripts" of menu bar 1
	 delay 0.5 
	 # click menu item "Recompute Pitch For Selected Notes" of menu 1 of menu bar item "Auto-Process" of menu bar 1
	 click menu item "Select the Previous Take" of menu 1 of menu bar item "Auto-Process" of menu bar 1
	 delay 0.5 
	 click menu item "Select the Next Take" of menu 1 of menu bar item "Auto-Process" of menu bar 1

	# delay 0.1
	# keystroke "r" using {option down}

	# click UI element "Bounce to Files" of window 1
	click target_button
	# click button "Bounce to Files" of window 1

	delay 1.5

	keystroke "s" using {command down}
	delay 0.1
	keystroke "q" using {command down}
	delay 0.1

	# tell application "Alacritty.app"
	tell application "WezTerm.app"
		activate
	end tell
end tell

'
