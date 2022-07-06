(
var sliders, numbers, controllers;
a = Array.fill(10, { Model(1.0.rand) });

w = Window("MVC", Rect(800, 200, 500, 400));

// I'm ignoring spec mapping, let's assume 0.0-1.0 for now
sliders = a.collect { |model, i|
	Slider()
	.orientation_(\vertical)
	.value_(model.value)
	.action_({ |view|
		model.value = view.value;
		numbers[i].value = view.value;
	})
	.onClose_({ controllers[i].remove });
};

numbers = a.collect { |model, i|
	NumberBox()
	.value_(model.value)
	.action_({ |view|
		model.value = view.value;
		sliders[i].value = view.value;
	})
	.onClose_({ controllers[i].remove });
};

controllers = a.collect { |model, i|
	SimpleController(model)
	.put(\value, { |object, whatChanged, value|
		defer {
			sliders[i].value = value;
			numbers[i].value = value;
		}
	})
	.put(\didFree, {
		defer {
			sliders[i].remove;
			numbers[i].remove;
			controllers[i].remove;
		}
	})
};

w.layout = HLayout(
	*Array.fill(a.size, { |i|
		VLayout(
			sliders[i],
			numbers[i]
		)
	})
);

w.front;
)


// change one value programmatically, GUI updates
a.choose.value = 1.0.rand; 
