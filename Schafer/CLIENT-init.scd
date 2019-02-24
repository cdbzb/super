s=Server.remote(\hack,NetAddr.new("192.168.1.136",57110));
//s=Server(\hack);
Server.default=s;

~speakers = Array.series(8,10);

//Server.fromName( 'hack' ).defaultGroup.release;
//Server.fromName( 'hack' ).statusWatcher.prFinalizeBoot;
