KeyboardWindow.new
KeyState.kr


s.boot;

// execute the code below to find out a key's keycode
// the char and keycode of any key you press will be printed in the post window
(
var last=SystemClock.seconds;
w = Window.new("I catch keystrokes");
w.view.keyDownAction = { arg view, char, modifiers, unicode, keycode; var delta=SystemClock.seconds-last; last=SystemClock.seconds;  [delta ,char, keycode].postln; };
w.front;
w.alwaysOnTop_(true);
)

// then execute this and then press the 'j' key
(
w.front; // something safe to type on
{ SinOsc.ar(800*SinOsc.kr(5,0,mul:0.1,add:0.9), 0, KeyState.kr(38, 0, 0.1)) }.play; //j
{ SinOsc.ar(700, 0, KeyState.kr(6, 0, 0.1)) }.play; //z
{ SinOsc.ar(840, 0, KeyState.kr(40, 0, 0.1)) }.play; //k
{ BPF.ar( Saw.ar([300,360,390]*KeyState.kr(7,0.8,1,2),0.1),KeyState.kr(8,10,1000,3.1)) }.play; //c-x
{ BPF.ar( Saw.ar([300,360,390],0.1),KeyState.kr(8,0,1000,3.1)) }.play;
)
(
{
SystemClock.seconds;	
}
)


