+ String {
	pbcopy { 
		Pipe.new("echo " ++ this ++ "pbcopy","w")
	}
}
