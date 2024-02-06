
ObjectPreCaller  {
	var <>pr_pr_pr_pr_underlying_object;
	var <>pr_pr_pre_func;

	// DO NOT RELY ON THESE METHOD AS THE INTERPRETER USES IT
	// OBJECT SHOULD REALLLLLLYYYY STOP YOU FROM IMPLEMENTING THESE, but lucky for us...
	asString { arg limit; ^pr_pr_pr_pr_underlying_object.asString( limit );  }
	class { ^pr_pr_pr_pr_underlying_object.class()}


	dump { pr_pr_pre_func.(); ^pr_pr_pr_pr_underlying_object.dump() }
	post { pr_pr_pre_func.(); ^pr_pr_pr_pr_underlying_object.post()}
	postln { pr_pr_pre_func.(); ^pr_pr_pr_pr_underlying_object.postln()}
	postc { pr_pr_pre_func.(); ^pr_pr_pr_pr_underlying_object.postc()}
	postcln { pr_pr_pre_func.(); ^pr_pr_pr_pr_underlying_object.postcln()}
	postcs { pr_pr_pre_func.(); ^pr_pr_pr_pr_underlying_object.postcs()}
	// would these cause leaks?
	//totalFree { pr_pr_pre_func.(); ^pr_pr_pr_pr_underlying_object.totalFree() }
	//largestFreeBlock { pr_pr_pre_func.(); ^pr_pr_pr_pr_underlying_object.largestFreeBlock() }
	//gcDumpGrey { pr_pr_pre_func.(); ^pr_pr_pr_pr_underlying_object.gcDumpGrey() }
	//gcDumpSet { pr_pr_pre_func.(); ^pr_pr_pr_pr_underlying_object.gcDumpSet() }
	//gcInfo { pr_pr_pre_func.(); ^pr_pr_pr_pr_underlying_object.gcInfo() }
	//gcSanity { pr_pr_pre_func.(); ^pr_pr_pr_pr_underlying_object.gcSanity() }
	canCallOS { pr_pr_pre_func.(); ^pr_pr_pr_pr_underlying_object.canCallOS() }
	size { pr_pr_pre_func.(); ^pr_pr_pr_pr_underlying_object.size()}
	indexedSize { pr_pr_pre_func.(); ^pr_pr_pr_pr_underlying_object.indexedSize()}
	flatSize { pr_pr_pre_func.(); ^pr_pr_pr_pr_underlying_object.flatSize()}
	functionPerformList { pr_pr_pre_func.(); ^pr_pr_pr_pr_underlying_object.functionPerformList() }
	copy { pr_pr_pre_func.(); ^pr_pr_pr_pr_underlying_object.copy()}
	contentsCopy { pr_pr_pre_func.(); ^pr_pr_pr_pr_underlying_object.contentsCopy()}
	shallowCopy { pr_pr_pre_func.(); ^pr_pr_pr_pr_underlying_object.shallowCopy()}
	copyImmutable { pr_pr_pre_func.(); ^pr_pr_pr_pr_underlying_object.copyImmutable() }
	deepCopy { pr_pr_pre_func.(); ^pr_pr_pr_pr_underlying_object.deepCopy() }
	poll { pr_pr_pre_func.(); ^pr_pr_pr_pr_underlying_object.poll()}
	value { pr_pr_pre_func.(); ^pr_pr_pr_pr_underlying_object.value()}
	valueArray { pr_pr_pre_func.(); ^pr_pr_pr_pr_underlying_object.valueArray()}
	valueEnvir { pr_pr_pre_func.(); ^pr_pr_pr_pr_underlying_object.valueEnvir()}
	valueArrayEnvir { pr_pr_pre_func.(); ^pr_pr_pr_pr_underlying_object.valueArrayEnvir()}
	basicHash { pr_pr_pre_func.(); ^pr_pr_pr_pr_underlying_object.basicHash()}
	hash { pr_pr_pre_func.(); ^pr_pr_pr_pr_underlying_object.hash()}
	identityHash { pr_pr_pre_func.(); ^pr_pr_pr_pr_underlying_object.identityHash()}
	next { pr_pr_pre_func.(); ^pr_pr_pr_pr_underlying_object.next()}
	reset { pr_pr_pre_func.(); ^pr_pr_pr_pr_underlying_object.reset()}
	iter { pr_pr_pre_func.(); ^pr_pr_pr_pr_underlying_object.iter()}
	stop { pr_pr_pre_func.(); ^pr_pr_pr_pr_underlying_object.stop()}
	free { pr_pr_pre_func.(); ^pr_pr_pr_pr_underlying_object.free()}
	clear { pr_pr_pre_func.(); ^pr_pr_pr_pr_underlying_object.clear()}
	removedFromScheduler { pr_pr_pre_func.(); ^pr_pr_pr_pr_underlying_object.removedFromScheduler()}
	isPlaying { pr_pr_pre_func.(); ^pr_pr_pr_pr_underlying_object.isPlaying()}
	embedInStream { pr_pr_pre_func.(); ^pr_pr_pr_pr_underlying_object.embedInStream()}
	loop { pr_pr_pre_func.(); ^pr_pr_pr_pr_underlying_object.loop()}
	asStream { pr_pr_pre_func.(); ^pr_pr_pr_pr_underlying_object.asStream()}
	eventAt { pr_pr_pre_func.(); ^pr_pr_pr_pr_underlying_object.eventAt()}
	finishEvent { pr_pr_pre_func.(); ^pr_pr_pr_pr_underlying_object.finishEvent()}
	atLimit { pr_pr_pre_func.(); ^pr_pr_pr_pr_underlying_object.atLimit()}
	isRest { pr_pr_pre_func.(); ^pr_pr_pr_pr_underlying_object.isRest()}
	threadPlayer { pr_pr_pre_func.(); ^pr_pr_pr_pr_underlying_object.threadPlayer()}
	threadPlayer_ { pr_pr_pre_func.(); ^pr_pr_pr_pr_underlying_object.threadPlayer_()}
	isNil { pr_pr_pre_func.(); ^pr_pr_pr_pr_underlying_object.isNil()}
	notNil { pr_pr_pre_func.(); ^pr_pr_pr_pr_underlying_object.notNil()}
	isNumber { pr_pr_pre_func.(); ^pr_pr_pr_pr_underlying_object.isNumber()}
	isInteger { pr_pr_pre_func.(); ^pr_pr_pr_pr_underlying_object.isInteger()}
	isFloat { pr_pr_pre_func.(); ^pr_pr_pr_pr_underlying_object.isFloat()}
	isSequenceableCollection { pr_pr_pre_func.(); ^pr_pr_pr_pr_underlying_object.isSequenceableCollection()}
	isCollection { pr_pr_pre_func.(); ^pr_pr_pr_pr_underlying_object.isCollection()}
	isArray { pr_pr_pre_func.(); ^pr_pr_pr_pr_underlying_object.isArray()}
	isString { pr_pr_pre_func.(); ^pr_pr_pr_pr_underlying_object.isString()}
	containsSeqColl { pr_pr_pre_func.(); ^pr_pr_pr_pr_underlying_object.containsSeqColl()}
	isValidUGenInput { pr_pr_pre_func.(); ^pr_pr_pr_pr_underlying_object.isValidUGenInput()}
	isException { pr_pr_pre_func.(); ^pr_pr_pr_pr_underlying_object.isException()}
	isFunction { pr_pr_pre_func.(); ^pr_pr_pr_pr_underlying_object.isFunction()}
	trueAt { pr_pr_pre_func.(); ^pr_pr_pr_pr_underlying_object.trueAt()}
	mutable { pr_pr_pre_func.(); ^pr_pr_pr_pr_underlying_object.mutable()}
	frozen { pr_pr_pre_func.(); ^pr_pr_pr_pr_underlying_object.frozen()}
	halt { pr_pr_pre_func.(); ^pr_pr_pr_pr_underlying_object.halt() }
	prHalt { pr_pr_pre_func.(); ^pr_pr_pr_pr_underlying_object.prHalt() }
	primitiveFailed { pr_pr_pre_func.(); ^pr_pr_pr_pr_underlying_object.primitiveFailed() }
	reportError { pr_pr_pre_func.(); ^pr_pr_pr_pr_underlying_object.reportError() }
	mustBeBoolean { pr_pr_pre_func.(); ^pr_pr_pr_pr_underlying_object.mustBeBoolean()}
	notYetImplemented { pr_pr_pre_func.(); ^pr_pr_pr_pr_underlying_object.notYetImplemented()}
	dumpBackTrace { pr_pr_pre_func.(); ^pr_pr_pr_pr_underlying_object.dumpBackTrace() }
	getBackTrace { pr_pr_pre_func.(); ^pr_pr_pr_pr_underlying_object.getBackTrace() }
	throw { pr_pr_pre_func.(); ^pr_pr_pr_pr_underlying_object.throw() }
	//species { pr_pr_pre_func.(); ^pr_pr_pr_pr_underlying_object.species()}
	asCollection { pr_pr_pre_func.(); ^pr_pr_pr_pr_underlying_object.asCollection()}
	asSymbol { pr_pr_pre_func.(); ^pr_pr_pr_pr_underlying_object.asSymbol()}
	asCompileString { pr_pr_pre_func.(); ^pr_pr_pr_pr_underlying_object.asCompileString() }
	cs { pr_pr_pre_func.(); ^pr_pr_pr_pr_underlying_object.cs()}
	storeArgs { pr_pr_pre_func.(); ^pr_pr_pr_pr_underlying_object.storeArgs()}
	dereference { pr_pr_pre_func.(); ^pr_pr_pr_pr_underlying_object.dereference()}
	reference { pr_pr_pre_func.(); ^pr_pr_pr_pr_underlying_object.reference()}
	asRef { pr_pr_pre_func.(); ^pr_pr_pr_pr_underlying_object.asRef()}
	dereferenceOperand { pr_pr_pre_func.(); ^pr_pr_pr_pr_underlying_object.dereferenceOperand()}
	asArray { pr_pr_pre_func.(); ^pr_pr_pr_pr_underlying_object.asArray()}
	asSequenceableCollection { pr_pr_pre_func.(); ^pr_pr_pr_pr_underlying_object.asSequenceableCollection()}
	rank { pr_pr_pre_func.(); ^pr_pr_pr_pr_underlying_object.rank()}
	slice { pr_pr_pre_func.(); ^pr_pr_pr_pr_underlying_object.slice()}
	shape { pr_pr_pre_func.(); ^pr_pr_pr_pr_underlying_object.shape()}
	unbubble { pr_pr_pre_func.(); ^pr_pr_pr_pr_underlying_object.unbubble()}
	yield { pr_pr_pre_func.(); ^pr_pr_pr_pr_underlying_object.yield() }
	alwaysYield { pr_pr_pre_func.(); ^pr_pr_pr_pr_underlying_object.alwaysYield() }
	dependants { pr_pr_pre_func.(); ^pr_pr_pr_pr_underlying_object.dependants() }
	release { pr_pr_pre_func.(); ^pr_pr_pr_pr_underlying_object.release() }
	releaseDependants { pr_pr_pre_func.(); ^pr_pr_pr_pr_underlying_object.releaseDependants() }
	removeUniqueMethods { pr_pr_pre_func.(); ^pr_pr_pr_pr_underlying_object.removeUniqueMethods() }
	inspect { pr_pr_pre_func.(); ^pr_pr_pr_pr_underlying_object.inspect()}
	inspectorClass { pr_pr_pre_func.(); ^pr_pr_pr_pr_underlying_object.inspectorClass()}
	inspector { pr_pr_pre_func.(); ^pr_pr_pr_pr_underlying_object.inspector() }
	crash { pr_pr_pre_func.(); ^pr_pr_pr_pr_underlying_object.crash() }
	stackDepth { pr_pr_pre_func.(); ^pr_pr_pr_pr_underlying_object.stackDepth() }
	dumpStack { pr_pr_pre_func.(); ^pr_pr_pr_pr_underlying_object.dumpStack() }
	dumpDetailedBackTrace { pr_pr_pre_func.(); ^pr_pr_pr_pr_underlying_object.dumpDetailedBackTrace() }
	freeze { pr_pr_pre_func.(); ^pr_pr_pr_pr_underlying_object.freeze() }
	beats_ { pr_pr_pre_func.(); ^pr_pr_pr_pr_underlying_object.beats_()  }
	isUGen { pr_pr_pre_func.(); ^pr_pr_pr_pr_underlying_object.isUGen()}
	numChannels { pr_pr_pre_func.(); ^pr_pr_pr_pr_underlying_object.numChannels()}
	clock_ { pr_pr_pre_func.(); ^pr_pr_pr_pr_underlying_object.clock_()  }
	asTextArchive { pr_pr_pre_func.(); ^pr_pr_pr_pr_underlying_object.asTextArchive() }
	asBinaryArchive { pr_pr_pre_func.(); ^pr_pr_pr_pr_underlying_object.asBinaryArchive() }
	help { pr_pr_pre_func.(); ^pr_pr_pr_pr_underlying_object.help()}
	asArchive { pr_pr_pre_func.(); ^pr_pr_pr_pr_underlying_object.asArchive() }
	initFromArchive { pr_pr_pre_func.(); ^pr_pr_pr_pr_underlying_object.initFromArchive()}
	archiveAsCompileString { pr_pr_pre_func.(); ^pr_pr_pr_pr_underlying_object.archiveAsCompileString()}
	archiveAsObject { pr_pr_pre_func.(); ^pr_pr_pr_pr_underlying_object.archiveAsObject()}
	checkCanArchive { pr_pr_pre_func.(); ^pr_pr_pr_pr_underlying_object.checkCanArchive()}
	isInputUGen { pr_pr_pre_func.(); ^pr_pr_pr_pr_underlying_object.isInputUGen()}
	isOutputUGen { pr_pr_pre_func.(); ^pr_pr_pr_pr_underlying_object.isOutputUGen()}
	isControlUGen { pr_pr_pre_func.(); ^pr_pr_pr_pr_underlying_object.isControlUGen()}
	source { pr_pr_pre_func.(); ^pr_pr_pr_pr_underlying_object.source()}
	asUGenInput { pr_pr_pre_func.(); ^pr_pr_pr_pr_underlying_object.asUGenInput()}
	asControlInput { pr_pr_pre_func.(); ^pr_pr_pr_pr_underlying_object.asControlInput()}
	asAudioRateInput { pr_pr_pre_func.(); ^pr_pr_pr_pr_underlying_object.asAudioRateInput()}
	slotSize { pr_pr_pre_func.(); ^pr_pr_pr_pr_underlying_object.slotSize() }
	getSlots { pr_pr_pre_func.(); ^pr_pr_pr_pr_underlying_object.getSlots() }
	instVarSize { pr_pr_pre_func.(); ^pr_pr_pr_pr_underlying_object.instVarSize()}

	do { arg function; pr_pr_pre_func.(); ^pr_pr_pr_pr_underlying_object.do( function ); }
	generate { arg function, state; pr_pr_pre_func.(); ^pr_pr_pr_pr_underlying_object.generate( function, state ); }
	isKindOf { arg aClass; pr_pr_pre_func.(); ^pr_pr_pr_pr_underlying_object.isKindOf( aClass );  }
	isMemberOf { arg aClass; pr_pr_pre_func.(); ^pr_pr_pr_pr_underlying_object.isMemberOf( aClass ); }
	respondsTo { arg aSymbol; pr_pr_pre_func.(); ^pr_pr_pr_pr_underlying_object.respondsTo( aSymbol ); }
	performMsg { arg msg; pr_pr_pre_func.(); ^pr_pr_pr_pr_underlying_object.performMsg( msg );  }
	perform { arg selector ... args; pr_pr_pre_func.(); ^pr_pr_pr_pr_underlying_object.perform( selector, *args );  }
	performList { arg selector, arglist; pr_pr_pre_func.(); ^pr_pr_pr_pr_underlying_object.performList( selector, arglist );  }
	superPerform { arg selector ... args; pr_pr_pre_func.(); ^pr_pr_pr_pr_underlying_object.superPerform( selector, *args );  }
	superPerformList { arg selector, arglist; pr_pr_pre_func.(); ^pr_pr_pr_pr_underlying_object.superPerformList( selector, arglist );  }
	tryPerform { arg selector ... args; pr_pr_pre_func.(); ^pr_pr_pr_pr_underlying_object.tryPerform( selector, *args );  }
	multiChannelPerform { arg selector ... args; pr_pr_pre_func.(); ^pr_pr_pr_pr_underlying_object.multiChannelPerform( selector, *args );  }
	performWithEnvir { arg selector, envir; pr_pr_pre_func.(); ^pr_pr_pr_pr_underlying_object.performWithEnvir( selector, envir );  }
	performKeyValuePairs { arg selector, pairs; pr_pr_pre_func.(); ^pr_pr_pr_pr_underlying_object.performKeyValuePairs( selector, pairs );  }
	dup { arg n ; pr_pr_pre_func.(); ^pr_pr_pr_pr_underlying_object.dup( n );  }
	! { arg n; pr_pr_pre_func.(); ^(pr_pr_pr_pr_underlying_object !  n);  }
	== { arg obj; pr_pr_pre_func.(); ^(pr_pr_pr_pr_underlying_object ==  obj);  }
	!= { arg obj; pr_pr_pre_func.(); ^(pr_pr_pr_pr_underlying_object !=  obj);  }
	=== { arg obj; pr_pr_pre_func.(); ^(pr_pr_pr_pr_underlying_object ===  obj); }
	!== { arg obj; pr_pr_pre_func.(); ^(pr_pr_pr_pr_underlying_object !==  obj); }
	equals { arg that, properties; pr_pr_pre_func.(); ^pr_pr_pr_pr_underlying_object.equals( that, properties );  }
	compareObject { arg that, instVarNames; pr_pr_pre_func.(); ^pr_pr_pr_pr_underlying_object.compareObject( that, instVarNames );  }
	instVarHash { arg instVarNames; pr_pr_pre_func.(); ^pr_pr_pr_pr_underlying_object.instVarHash( instVarNames );  }
	|==| { arg that; pr_pr_pre_func.(); ^(pr_pr_pr_pr_underlying_object |==|  that);  }
	|!=| { arg that; pr_pr_pre_func.(); ^(pr_pr_pr_pr_underlying_object |!=|  that);  }
	prReverseLazyEquals { arg that; pr_pr_pre_func.(); ^pr_pr_pr_pr_underlying_object.prReverseLazyEquals( that );  }
	-> { arg obj; pr_pr_pre_func.(); ^(pr_pr_pr_pr_underlying_object ->  obj);  }
	first { arg inval; pr_pr_pre_func.(); ^pr_pr_pr_pr_underlying_object.first( inval ); }
	cyc { arg n; pr_pr_pre_func.(); ^pr_pr_pr_pr_underlying_object.cyc( n );  }
	fin { arg n; pr_pr_pre_func.(); ^pr_pr_pr_pr_underlying_object.fin( n );  }
	repeat { arg repeats; pr_pr_pre_func.(); ^pr_pr_pr_pr_underlying_object.repeat( repeats ); }
	nextN { arg n, inval; pr_pr_pre_func.(); ^pr_pr_pr_pr_underlying_object.nextN( n, inval );  }
	streamArg { arg embed; pr_pr_pre_func.(); ^pr_pr_pr_pr_underlying_object.streamArg( embed );  }
	composeEvents { arg event; pr_pr_pre_func.(); ^pr_pr_pr_pr_underlying_object.composeEvents( event ); }
	? { arg obj; pr_pr_pre_func.(); ^(pr_pr_pr_pr_underlying_object ?  obj); }
	?? { arg obj; pr_pr_pre_func.(); ^(pr_pr_pr_pr_underlying_object ??  obj); }
	!? { arg obj; pr_pr_pre_func.(); ^(pr_pr_pr_pr_underlying_object !?  obj); }
	matchItem { arg item; pr_pr_pre_func.(); ^pr_pr_pr_pr_underlying_object.matchItem( item ); }
	falseAt { arg key; pr_pr_pre_func.(); ^pr_pr_pr_pr_underlying_object.falseAt( key );  }
	pointsTo { arg obj; pr_pr_pre_func.(); ^pr_pr_pr_pr_underlying_object.pointsTo( obj ); }
	subclassResponsibility { arg method; pr_pr_pre_func.(); ^pr_pr_pr_pr_underlying_object.subclassResponsibility( method );  }
	doesNotUnderstand { arg selector ... args; pr_pr_pre_func.(); ^pr_pr_pr_pr_underlying_object.doesNotUnderstand( selector, *args );  }
	shouldNotImplement { arg method; pr_pr_pre_func.(); ^pr_pr_pr_pr_underlying_object.shouldNotImplement( method );  }
	outOfContextReturn { arg method, result; pr_pr_pre_func.(); ^pr_pr_pr_pr_underlying_object.outOfContextReturn( method, result );  }
	immutableError { arg value; pr_pr_pre_func.(); ^pr_pr_pr_pr_underlying_object.immutableError( value );  }
	deprecated { arg method, alternateMethod; pr_pr_pre_func.(); ^pr_pr_pr_pr_underlying_object.deprecated( method, alternateMethod );  }
	printClassNameOn { arg stream; pr_pr_pre_func.(); ^pr_pr_pr_pr_underlying_object.printClassNameOn( stream );  }
	printOn { arg stream; pr_pr_pre_func.(); ^pr_pr_pr_pr_underlying_object.printOn( stream );  }
	storeOn { arg stream; pr_pr_pre_func.(); ^pr_pr_pr_pr_underlying_object.storeOn( stream );  }
	storeParamsOn { arg stream; pr_pr_pre_func.(); ^pr_pr_pr_pr_underlying_object.storeParamsOn( stream );  }
	simplifyStoreArgs { arg args; pr_pr_pre_func.(); ^pr_pr_pr_pr_underlying_object.simplifyStoreArgs( args );  }
	storeModifiersOn { arg stream; pr_pr_pre_func.(); ^pr_pr_pr_pr_underlying_object.storeModifiersOn( stream ); }
	as { arg aSimilarClass; pr_pr_pre_func.(); ^pr_pr_pr_pr_underlying_object.as( aSimilarClass ); }
	deepCollect { arg depth, function, index, rank ; pr_pr_pre_func.(); ^pr_pr_pr_pr_underlying_object.deepCollect( depth, function, index , rank ); }
	deepDo { arg depth, function, index , rank ; pr_pr_pre_func.(); ^pr_pr_pr_pr_underlying_object.deepDo( depth, function, index , rank ); }
	bubble { arg depth, levels; pr_pr_pre_func.(); ^pr_pr_pr_pr_underlying_object.bubble( depth, levels);  }
	obtain { arg index, default; pr_pr_pre_func.(); ^pr_pr_pr_pr_underlying_object.obtain( index, default ); }
	instill { arg index, item, default; pr_pr_pre_func.(); ^pr_pr_pr_pr_underlying_object.instill( index, item, default );  }
	addFunc { arg ... functions; pr_pr_pre_func.(); ^pr_pr_pr_pr_underlying_object.addFunc(*functions );  }
	removeFunc { arg function; pr_pr_pre_func.(); ^pr_pr_pr_pr_underlying_object.removeFunc( function );  }
	replaceFunc { arg find, replace; pr_pr_pre_func.(); ^pr_pr_pr_pr_underlying_object.replaceFunc( find, replace );  }
	addFuncTo { arg variableName ... functions; pr_pr_pre_func.(); ^pr_pr_pr_pr_underlying_object.addFuncTo( variableName, *functions );  }
	removeFuncFrom { arg variableName, function; pr_pr_pre_func.(); ^pr_pr_pr_pr_underlying_object.removeFuncFrom( variableName, function );  }
	while { arg body; pr_pr_pre_func.(); ^pr_pr_pr_pr_underlying_object.while( body );  }
	switch { arg ... cases; pr_pr_pre_func.(); ^pr_pr_pr_pr_underlying_object.switch(*cases );  }
	yieldAndReset { arg reset ; pr_pr_pre_func.(); ^pr_pr_pr_pr_underlying_object.yieldAndReset( reset );  }
	idle { arg val; pr_pr_pre_func.(); ^pr_pr_pr_pr_underlying_object.idle( val );  }
	changed { arg what ... moreArgs; pr_pr_pre_func.(); ^pr_pr_pr_pr_underlying_object.changed( what, *moreArgs );  }
	addDependant { arg dependant; pr_pr_pre_func.(); ^pr_pr_pr_pr_underlying_object.addDependant( dependant );  }
	removeDependant { arg dependant; pr_pr_pre_func.(); ^pr_pr_pr_pr_underlying_object.removeDependant( dependant );  }
	update { arg theChanged, theChanger; pr_pr_pre_func.(); ^pr_pr_pr_pr_underlying_object.update( theChanged, theChanger ); }
	addUniqueMethod { arg selector, function; pr_pr_pre_func.(); ^pr_pr_pr_pr_underlying_object.addUniqueMethod( selector, function );  }
	removeUniqueMethod { arg selector; pr_pr_pre_func.(); ^pr_pr_pr_pr_underlying_object.removeUniqueMethod( selector );  }
	& { arg that; pr_pr_pre_func.(); ^(pr_pr_pr_pr_underlying_object &  that); }
	| { arg that; pr_pr_pre_func.(); ^(pr_pr_pr_pr_underlying_object |  that); }
	% { arg that; pr_pr_pre_func.(); ^(pr_pr_pr_pr_underlying_object %  that); }
	** { arg that; pr_pr_pre_func.(); ^(pr_pr_pr_pr_underlying_object **  that); }
	<< { arg that; pr_pr_pre_func.(); ^(pr_pr_pr_pr_underlying_object <<  that); }
	>> { arg that; pr_pr_pre_func.(); ^(pr_pr_pr_pr_underlying_object >>  that); }
	+>> { arg that; pr_pr_pre_func.(); ^(pr_pr_pr_pr_underlying_object +>>  that); }
	<! { arg that; pr_pr_pre_func.(); ^(pr_pr_pr_pr_underlying_object <!  that); }
	blend { arg that, blendFrac; pr_pr_pre_func.(); ^pr_pr_pr_pr_underlying_object.blend( that, blendFrac );  }
	blendAt { arg index, method; pr_pr_pre_func.(); ^pr_pr_pr_pr_underlying_object.blendAt( index, method);  }
	blendPut { arg index, val, method; pr_pr_pre_func.(); ^pr_pr_pr_pr_underlying_object.blendPut( index, val, method);  }
	fuzzyEqual { arg that, precision; pr_pr_pre_func.(); ^pr_pr_pr_pr_underlying_object.fuzzyEqual( that, precision); }
	pair { arg that; pr_pr_pre_func.(); ^pr_pr_pr_pr_underlying_object.pair( that ); }
	pairs { arg that; pr_pr_pre_func.(); ^pr_pr_pr_pr_underlying_object.pairs( that );  }
	awake { arg beats, seconds, clock; pr_pr_pre_func.(); ^pr_pr_pr_pr_underlying_object.awake( beats, seconds, clock );  }
	performBinaryOpOnSomething { arg aSelector, thing, adverb; pr_pr_pre_func.(); ^pr_pr_pr_pr_underlying_object.performBinaryOpOnSomething( aSelector, thing, adverb );  }
	performBinaryOpOnSimpleNumber { arg aSelector, thing, adverb; pr_pr_pre_func.(); ^pr_pr_pr_pr_underlying_object.performBinaryOpOnSimpleNumber( aSelector, thing, adverb );  }
	performBinaryOpOnSignal { arg aSelector, thing, adverb; pr_pr_pre_func.(); ^pr_pr_pr_pr_underlying_object.performBinaryOpOnSignal( aSelector, thing, adverb );  }
	performBinaryOpOnComplex { arg aSelector, thing, adverb; pr_pr_pre_func.(); ^pr_pr_pr_pr_underlying_object.performBinaryOpOnComplex( aSelector, thing, adverb );  }
	performBinaryOpOnSeqColl { arg aSelector, thing, adverb; pr_pr_pre_func.(); ^pr_pr_pr_pr_underlying_object.performBinaryOpOnSeqColl( aSelector, thing, adverb );  }
	performBinaryOpOnUGen { arg aSelector, thing, adverb; pr_pr_pre_func.(); ^pr_pr_pr_pr_underlying_object.performBinaryOpOnUGen( aSelector, thing, adverb );  }
	writeDefFile { arg name, dir, overwrite; pr_pr_pre_func.(); ^pr_pr_pr_pr_underlying_object.writeDefFile( name, dir, overwrite );  }
	slotAt { arg index; pr_pr_pre_func.(); ^pr_pr_pr_pr_underlying_object.slotAt( index );  }
	slotPut { arg index, value; pr_pr_pre_func.(); ^pr_pr_pr_pr_underlying_object.slotPut( index, value );  }
	slotKey { arg index; pr_pr_pre_func.(); ^pr_pr_pr_pr_underlying_object.slotKey( index );  }
	slotIndex { arg key; pr_pr_pre_func.(); ^pr_pr_pr_pr_underlying_object.slotIndex( key );  }
	slotsDo { arg function; pr_pr_pre_func.(); ^pr_pr_pr_pr_underlying_object.slotsDo( function );  }
	slotValuesDo { arg function; pr_pr_pre_func.(); ^pr_pr_pr_pr_underlying_object.slotValuesDo( function );  }
	setSlots { arg array; pr_pr_pre_func.(); ^pr_pr_pr_pr_underlying_object.setSlots( array );  }
	instVarAt { arg index; pr_pr_pre_func.(); ^pr_pr_pr_pr_underlying_object.instVarAt( index );  }
	instVarPut { arg index, item; pr_pr_pre_func.(); ^pr_pr_pr_pr_underlying_object.instVarPut( index, item );  }
	writeArchive { arg pathname; pr_pr_pre_func.(); ^pr_pr_pr_pr_underlying_object.writeArchive( pathname );  }
	writeTextArchive { arg pathname; pr_pr_pre_func.(); ^pr_pr_pr_pr_underlying_object.writeTextArchive( pathname );  }
	getContainedObjects { arg objects; pr_pr_pre_func.(); ^pr_pr_pr_pr_underlying_object.getContainedObjects( objects );  }
	writeBinaryArchive { arg pathname; pr_pr_pre_func.(); ^pr_pr_pr_pr_underlying_object.writeBinaryArchive( pathname );  }
}

// this needs tidying up 
ServerResourceWrapper : ObjectPreCaller {
	var <>pr_pr_cond_var;
	var <>pr_pr_has_finished_loading_on_server;

	*new{
		var self = super.new();

		self
		.pr_pr_has_finished_loading_on_server_(false)
		.pr_pr_cond_var_(CondVar());

		self.pr_pr_pre_func_({
			if(self.pr_pr_has_finished_loading_on_server.not, {
				try {
					self.pr_pr_cond_var.wait({ self.pr_pr_has_finished_loading_on_server })
				}
				{
					|er|
					if((er.class == PrimitiveFailedError) && (er.failedPrimitiveName == '_RoutineYield'),
						{  (self.class.asString ++ "'s value has not completed, "
							+ "either call use in a Routine/Thread, "
							+ "or, literally wait until the proccess has finished and try again").throw
						},
						{er.throw} // some other error
					);

				}
			})
		});
		^self
	}

	pr_pr_add_underlying_object {|obj|
		// only call this once
		this.pr_pr_pr_pr_underlying_object = obj
	}


	pr_pr_mark_has_finished_loading_on_server {
		pr_pr_has_finished_loading_on_server = true;
		pr_pr_cond_var.signalAll;
	}

	doesNotUnderstand { |selector ... args|
		this.pr_pr_pre_func.();
		^this.pr_pr_pr_pr_underlying_object.perform(selector.asSymbol, *args)
	}
}
+Buffer {
	*readAsResource { |server, path, startFrame=0, numFrames=(-1), action, bufnum|
		var r = ServerResourceWrapper();
		var buffer = Buffer.read(
			server,
			path,
			startFrame,
			numFrames,
			{|buf|
				r.pr_pr_mark_has_finished_loading_on_server();
				action !? {action.(buf)};
			},
			bufnum
		);
		r.pr_pr_add_underlying_object(buffer);
		^r
	}
}
+SynthDef {
	addAsResource {
		var r = ServerResourceWrapper();
			fork{
				this.add;
				Server.default.sync;
				r.pr_pr_mark_has_finished_loading_on_server();
		r.pr_pr_add_underlying_object(this);
			};
		^r
	}
}
