+Pattern {
	+= { |that|
			(that.class==Ppar).if{
					that.list_(that.list++this)
					^that
			}{
					^Ppar([this,that])
			}
	}
}
