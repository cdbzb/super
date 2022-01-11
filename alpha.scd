(
var w = Window("globes", bounds:Rect(0,0,1000,1000), border:false)
        .background_(Color.clear)
        .front;

var t = StaticText(w,Rect (500,500,400,200))
    .string_("test")
    .stringColor_(Color.rand)
    .align_(\center)
    .font_(Font(\helvetica,90,bold:true));

{t.string_("blah")}.defer(2);
{w.close}.defer(5)
)
