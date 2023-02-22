#! /bin/bash

osascript -e '
on run argv
	set filename to item 1 of argv
	tell application "VOCALOID6 Editor.app" 
		activate
		delay 1 -- give it time to react
		tell application "System Events" 
			keystroke "e" using {command down}
			delay 2
			keystroke return
			delay 2
			keystroke filename
			delay 2
			keystroke return
			delay 1
			keystroke return
		end tell
	end tell
end run
' $1
#--  # Start the screen recording.
#
#tell application "System Events" to tell process "Screen Shot"
#    repeat until exists its front window
#        delay 0.1
#    end repeat
#    if not (exists button "Record" of its front window) then
#        click checkbox "Record Entire Screen" of its front window
#    end if
#    click button "Record" of its front window
#end tell
#
#--  # Set the time in seconds you want the recording to be.
#
#delay 2
#
#--  # Stop the recording.
#
#tell application "System Events" to ¬
#    click menu bar item 1 ¬
#        of menu bar 1 ¬
#        of application process "screencaptureui"
#'
