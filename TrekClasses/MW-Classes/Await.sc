AsyncTimeoutError : Error {
	errorString { ^"Function.await: timeout." }
}

+ Function {
	
	await { |timeout = nil, onTimeout = nil|
		var cond = CondVar(), done = false, res = nil;
		
		this.value({|...results|
			res = results; done = true;
			cond.signalOne;
		});
		
		if (timeout.isNil) { 
			cond.wait { done } 
		} { 
			cond.waitFor(timeout) { done } 
		};
		
		if (done.not) {
			if (onTimeout.isFunction) {
				^onTimeout.value 
			} {
				AsyncTimeoutError().throw
			}
		};
		^res.unbubble;
	}
}

/* Example:
fork { 
var res1, res2;
res1 = await { |done| fork { 3.wait; done.value(\ok) } }; 
res1.postln;
res2 = await { |done| doSomethingAsync(res1, action: done) }; 
res2.postln;
}
*/

/* Timeout example:

// with timeout callback
fork {
	var asyncFn = { |done| fork { 3.wait; done.value(\ok) } };
	var res = asyncFn.await(
	);
	res.postln
}

// with timeout error
fork {
	var asyncFn = { |done| fork { 3.wait; done.value(\ok) } };
	var res;
	try {
		res = asyncFn.await(1);
	} { |err|
		if (err.isKindOf(AsyncTimeoutError)) {
			"timeout".postln;
		} {
			err.throw;
		}
	};
	res.postln
}
*/
