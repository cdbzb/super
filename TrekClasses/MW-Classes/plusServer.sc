+Server {
	forceReboot {
		Server.default.addr=NetAddr("127.0.0.1",rrand(6000,7000));
		Server.default.reboot
	}
}
