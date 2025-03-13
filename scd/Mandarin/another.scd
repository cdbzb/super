《心跳的节奏》
(The Rhythm of a Heartbeat)

短短短短长，
你的笑在回荡，
短短短短长，
像星光落我心上。

短短短短长，
思念悄悄生长，
短短短短长，
梦里有你在身旁。

长长长长长，
我想和你去远方，
长长长长长，
爱是唯一的方向。
The Rhythm of a Heartbeat》

Short short short short long,
Your laughter echoes in my mind,
Short short short short long,
Like starlight falling on my heart.

Short short short short long,
Longing quietly grows,
Short short short short long,
In my dreams, you're by my side.

Long long long long long,
I want to wander far with you,
Long long long long long,
Love is the only direction
---------
《心跳的节奏》
(The Rhythm of a Heartbeat)

微风轻轻吹，
你眼神在徘徊，
星光洒下来，
照亮了我的期待。

脚步慢慢追，
心跳乱了节拍，
梦醒也不悔，
因为你在我脑海。

我想带你飞，
去天涯和海角，
爱像一首歌，
唱出永远的承诺。

English Translation:

《The Rhythm of a Heartbeat》

The breeze whispers softly,
Your gaze lingers near,
Starlight spills gently,
Lighting up all my hopes here.

I follow your steps slow,
My heartbeat’s out of tune,
Even when dreams let go,
You’re all I think of soon.

I want to fly with you,
To the ends of the earth,
Love is a melody true,
Singing a promise of worth.

(
Song(\another, []).current;
["短 短 短 短 长", "3 2 1 -7 5".dm(\f, 4), "e e e e eeee".beats].addLine;
P.synthV(\an, take: \lead, params: {|p b| [
	lyrics: " 微 风 轻 轻 吹， ",
	pitchTake: 1,
	legato: [1, 1 ,1, 1, 0.8],
	language: \Mandarin
] }, music:{|p b e|
	{
		e.playbuf
		// => p.synthVTracks.at(e.key).()
	}.play
});
["line2 ","6 5 3 4 11 12".dm(\f, 4), "e e e e eee e".beats].addLine;
P.synthV(\an, take: \lead, 
	pbind: Song.enlarge(5),
	params: {|p b| [
	lyrics: "你 眼 神 在 徘 徊 星 光 洒 下 来 ",
	lag: [0.02, 0, 0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ],
	pitchTake: 3,
	language: \Mandarin
] }, music:{|p b e|
	{
		e.playbuf
		// => p.synthVTracks.at(e.key).()
	}.play
});
["Line 3", "13 12 11 7 6.7".dm(\f, 4), "e e e e eeee".beats].addLine;
P.synthV(\an, take: \lead, params: {|p b| [
	lyrics: "星 光 洒 下 来 ",
	pitchTake: 1, 
	language: \Mandarin
] }, music:{|p b e|
	{
		e.playbuf
		// => p.synthVTracks.at(e.key).()
	}//.play
});

)
