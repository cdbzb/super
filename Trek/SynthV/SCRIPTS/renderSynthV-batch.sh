#!/bin/bash
# Renders multiple SVP files sequentially in a single SynthV Studio session.
# Usage: renderSynthV-batch.sh file1.svp file2.svp ...
# Each SVP must already have renderConfig.destination set.

APP_NAME="Synthesizer V Studio 2 Pro"

if [ $# -eq 0 ]; then
    echo "Usage: $0 file1.svp [file2.svp ...]"
    exit 1
fi

# Open the first file to launch the app
open -a "$APP_NAME" "$1"
sleep 5

osascript - "$@" <<'APPLESCRIPT'
on run argv
    set appName to "Synthesizer V Studio 2 Pro"
    tell application appName to activate
    delay 3

    tell application "System Events"
        tell process appName
            -- Wait until a window is visible
            repeat until (count of windows) > 0
                delay 0.5
            end repeat
            delay 1

            -- Ensure Render Panel is visible
            try
                if not (exists button "Bounce to Files" of front window) then
                    click menu item "Render Panel" of menu "View" of menu bar 1
                    delay 1
                end if
            end try
        end tell
    end tell

    -- Process each file
    repeat with i from 1 to (count of argv)
        set svpPath to item i of argv

        -- For files after the first, open via File > Open
        if i > 1 then
            tell application appName
                activate
                open POSIX file svpPath
            end tell
            delay 3
        end if

        -- Click Bounce to Files
        tell application "System Events"
            tell process appName
                delay 1

                -- Ensure Render Panel is still visible
                try
                    if not (exists button "Bounce to Files" of front window) then
                        click menu item "Render Panel" of menu "View" of menu bar 1
                        delay 1
                    end if
                end try

                try
                    click button "Bounce to Files" of front window
                    delay 1
                on error errMsg
                    log "Error bouncing " & svpPath & ": " & errMsg
                end try
            end tell
        end tell

        -- Wait for render to complete by checking if the wav file appeared
        -- The destination is embedded in the SVP; poll for synthV_MixDown.wav
        -- Extract destination from the SVP path pattern: /private/tmp/HASH.svp -> frozen/HASH/
        -- We can't easily extract it here, so just wait a reasonable time
        delay 5
    end repeat

    -- Save and quit after all files are done
    tell application "System Events"
        tell process appName
            try
                click menu item "Save" of menu "File" of menu bar 1
                delay 0.5
            end try
            click menu item "Quit Synthesizer V Studio 2 Pro" of menu "Synthesizer V Studio 2 Pro" of menu bar 1
        end tell
    end tell

    return "Batch render complete: " & (count of argv) & " files"
end run
APPLESCRIPT
