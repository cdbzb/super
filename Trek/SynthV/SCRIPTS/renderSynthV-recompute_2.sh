#!/bin/bash
APP_NAME="Synthesizer V Studio 2 Pro"
# Open the application
open -a "$APP_NAME" $1
# Wait for the application to launch
sleep 5

osascript <<EOF
-- Open the application
tell application "Synthesizer V Studio 2 Pro" to activate
-- Wait for the application to fully load and become frontmost
delay 3
-- Click the "Bounce to Files" button
tell application "System Events"
	tell process "Synthesizer V Studio 2 Pro"
		-- Wait until a window is visible
		repeat until (count of windows) > 0
			delay 0.5
		end repeat

		-- Additional small delay to ensure window is fully loaded
		delay 1

		-- Ensure Render Panel is visible
		try
			if not (exists button "Bounce to Files" of front window) then
				click menu item "Render Panel" of menu "View" of menu bar 1
				delay 1
			end if
		end try

		-- Click the button
		try
			click button "Bounce to Files" of front window
			-- Select "Save" from the "File" menu
			delay 0.5

			click menu item "Save" of menu "File" of menu bar 1

			delay 0.5 -- Wait a moment for save to complete


			-- Select "Quit Synthesizer V Studio 2 Pro" from app menu
			click menu item "Quit Synthesizer V Studio 2 Pro" of menu "Synthesizer V Studio 2 Pro" of menu bar 1

			return "Successfully clicked 'Bounce to Files' button"
		on error errMsg
			return "Error: Could not find or click 'Bounce to Files' button - " & errMsg
		end try
	end tell
end tell
EOF
