//(
//~modelPrototype = (
//	value: 0,
//	// because '.value' gets eaten by the 'value' method
//	getValue: { |self| self[\value] },
//	value_: { |self, newValue|
//		self[\value] = newValue;
//		self.changed(\value, newValue);
//	},
//	destroy: { |self| self.changed(\didFree) }
//);
//)

Model {
  var <value=0;
  *new {|i| ^super.new.init(i) }
  init {|i| value = i }
  value_{ |newValue|
    value = newValue;
    this.changed(\value, newValue)
  }
  destroy {
    this.changed(\didFree)
  }
}
