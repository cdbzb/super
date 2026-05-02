AD : String {
    var <>chans;
    *new {|string chans| ^ super.new(string).init(chans) }
    init{|inChans| chans = inChans}
}
