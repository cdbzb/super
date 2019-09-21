(
	~parse={|song phrase array start=0| //array of rhythms
		var counter = 0;
		var beatNum = array.flatten.collect{|m i| array.flatten.[0..i].sum};
		beatNum = beatNum.collect{|i|(i-0.001).floor};
		array.collect{ |item|
			item.isArray.not.if(
				{
					var b=beatNum[counter];
					counter=counter+1;
					item*song.durs[phrase].list[b+start]
				},
				{
					var subArray=item.collect{|i x| 
						var b = beatNum[counter+x];
						i*song.durs[phrase].list[b+start]
					}; 
					counter=counter+item.size; 
					subArray.sum;
				}
			);
		}
	};
)
