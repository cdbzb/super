////////// save as .sc file in Extensions folder and recompile

SmoothControl : UGen {

	*initClass {
		Fb1_ODEdef(\smoothControl, { |t, y, k1 = 0, k2 = 1, k3 = 1, x = 1, dxdt = 0|
			[
				{ y[1] },
				{ (x / k2) + (k3 * dxdt / k2) - (y[0] / k2) - (k1 * y[1] / k2) }
			]
		}, 0, [0, 0], 1, 1);
	}

	*ar { |in, f = 3, zeta = 0.5, r = 2|
		var k1 = zeta / (pi * f);
		var k2 = 1 / ((2 * pi * f) ** 2);
		var k3 = r * zeta / (2 * pi * f);
		^Fb1_ODE.ar(\smoothControl, [k1, k2, k3, in, Slope.ar(in)], leakDC: false)[0]
	}

	*kr { |in, f = 3, zeta = 0.5, r = 2|
		var k1 = zeta / (pi * f);
		var k2 = 1 / ((2 * pi * f) ** 2);
		var k3 = r * zeta / (2 * pi * f);
		^Fb1_ODE.kr(\smoothControl, [k1, k2, k3, in, Slope.kr(in)], leakDC: false)[0]
	}

}

//////////
