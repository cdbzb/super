(
	~properPlay={|i| switch (i.class,
		Function,1,
		Routine,2,
		Event,3
	)};
	b={|i|i.postln};
	c=(a:1);
	~properPlay.(c)
)
