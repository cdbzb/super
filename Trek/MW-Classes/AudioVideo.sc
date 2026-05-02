VideoAudio {
    var <videoPath, <audioPath, <outputPath;

    *new { |videoPath|
        ^super.newCopyArgs(videoPath.standardizePath)
    }

    extractAudio { |outPath, sampleRate = 48000, bitDepth = 24, action|
        var cmd;
        audioPath = outPath ?? {
            videoPath.splitext[0] ++ "_audio.wav"
        };
        audioPath = audioPath.standardizePath;

        cmd = "ffmpeg -y -i \"%\" -vn -acodec pcm_s%le -ar % \"%\"".format(
            videoPath, bitDepth, sampleRate, audioPath
        );

        cmd.unixCmd({ |exitCode|
            if(exitCode == 0) {
                "Audio extracted to: %".format(audioPath).postln;
            } {
                "Error extracting audio (exit code %)".format(exitCode).warn;
            };
            action.value(exitCode, audioPath);
        });

        ^audioPath
    }

    recombine { |processedAudioPath, outPath, audioCodec = "aac", audioBitrate = "256k", action|
        var cmd;
        outputPath = outPath ?? {
            videoPath.splitext[0] ++ "_processed" ++ videoPath.splitext[1]
        };
        outputPath = outputPath.standardizePath;
        processedAudioPath = processedAudioPath.standardizePath;

        cmd = "ffmpeg -y -i \"%\" -i \"%\" -c:v copy -c:a % -b:a % -map 0:v:0 -map 1:a:0 \"%\"".format(
            videoPath, processedAudioPath, audioCodec, audioBitrate, outputPath
        );

        cmd.unixCmd({ |exitCode|
            if(exitCode == 0) {
                "Video with new audio saved to: %".format(outputPath).postln;
            } {
                "Error recombining (exit code %)".format(exitCode).warn;
            };
            action.value(exitCode, outputPath);
        });

        ^outputPath
    }

    // Convenience: extract, process with a function, recombine
    processAudio { |processFunc, outPath, action|
        this.extractAudio(action: { |exitCode, extractedPath|
            if(exitCode == 0) {
                var processedPath = processFunc.value(extractedPath);
                this.recombine(processedPath, outPath, action: action);
            } {
                action.value(exitCode, nil);
            };
        });
    }
}
