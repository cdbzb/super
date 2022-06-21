KeyRecorder {
  var <list,time;
  var window;
  *new { ^super.new.init; }
  init {
    var v;
    window = Window.new.front.alwaysOnTop_(true);
    v = window.view;
    //time = Main.elapsedTime;
    //time = SystemClock.seconds;
    v.keyDownAction = { |view char|
      list = list.add(SystemClock.seconds).postln; 
      switch(char,
        //$d , {doOver},
        //$n , {nextt},
        $r , { list.differentiate.drop(1).round(0.001).postln },
        //$s , {save},
        $w , { window.close },
        $q , { window.close }
        )
    }
  }
}
