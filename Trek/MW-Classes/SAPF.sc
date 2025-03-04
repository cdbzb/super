+ String {
	sapf {
		this.split(Char.space).reject{|i| i.size == 0}.rotate
		=> {|i|
			^Message(i[0].interpret, \ar, i.drop(1).collect{|j| j.interpret}).value
		}
	
	}
}
