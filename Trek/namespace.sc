MQ_Controller { }
MQ_Synth { }
MQ_View { }
MQ {
	*new { ^( 
		Controller: MQ_Controller,
		Synth: MQ_Synth ,
		View: MQ_View
	)
}}
// controller = MyQuark.controller.new();
