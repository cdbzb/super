+ Platform {
  *machine {
    var p = Pipe("sysctl -n hw.model","r");
    var l=p.getLine;
    p.close;
    ^l
  }
}
