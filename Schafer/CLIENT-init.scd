(
	~remoteInit={
		s=Server.remote(\hack,NetAddr.new("192.168.1.136",57110));
		Server.default=s;
	}.value;

	~speakers = Array.series(8,2);
	Server.local.boot;
)

//Server.fromName( 'hack' ).defaultGroup.release;
//Server.fromName( 'hack' ).statusWatcher.prFinalizeBoot;
