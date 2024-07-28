Kitty {
	classvar dir = "/Applications/Kitty.app/Contents/MacOS";

	*open{ |cmd|
		"touch /tmp/kitty".systemCmd;
		"%/kitty --listen-on unix:/tmp/kitty % &".format(dir, cmd ? "").systemCmd;
	}

	*zellij{
		"touch /tmp/post".systemCmd;
		Kitty.open("zellij --layout monitorTwo")
	}

	*sendText{ |command|
		"%/kitten @ --to unix:/tmp/kitty send-text %".format(dir,command).systemCmd
	}

	*opacity{ |opacity|
		"%/kitten @ --to unix:/tmp/kitty set_background_opacity %".format(dir, opacity).systemCmd
	}
}
