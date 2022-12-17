/*
Copy to Extensions folder and re-compile

Ryhthmically sequences numeric values which can then be used with any event key, e.g. degree or midinote.

operators:
" "   - empty space separates beats/values
~     - rest
[]    - beat sub division
<>    - alternating values
^n    - stretch duration - where n is a float
!n    - repeat value - where n is an integer
$     - shuffle group of values
#(nn) - choose from group of values - optionally provide weights as integers 0-9
%n    - chance value is chosen vs rest - where n is an integer 0-9 - can be used on value or group


note: a key of \g1 is added to the stream at beginning of each cycle which can then be used with Pgate

examples:

// basic sequence
~p = Pbind(\degree, Pdv.parse("0 1 2 3")).asStream; // commas are ignored
~p.next(Event.default)
  ( 'degree': 0.0, 'dur': 1.0, 'g1': true )
  ( 'degree': 1.0, 'dur': 1.0 )
  ( 'degree': 2.0, 'dur': 1.0 )
  ( 'degree': 3.0, 'dur': 1.0 )

// sequence with rest
~p = ~p = Pbind(\degree, Pdv.parse("0 1 ~ 2")).asStream;
~p.next(Event.default)
  ( 'degree': 0.0, 'dur': 1.0, 'g1': true )
  ( 'degree': 1.0, 'dur': 1.0 )
  ( 'degree': rest, 'dur': Rest(1.0) )
  ( 'degree': 2.0, 'dur': 1.0 )

// sequence with sub division
~p = Pbind(\degree, Pdv.parse("0 1 [2 3]")).asStream;
~p.next(Event.default)
  ( 'degree': 0.0, 'dur': 1.0, 'g1': true )
  ( 'degree': 1.0, 'dur': 1.0 )
  ( 'degree': 2.0, 'dur': 0.5 )
  ( 'degree': 3.0, 'dur': 0.5 )

// sequence with nested sub divisions
~p = Pbind(\degree, Pdv.parse("0 1 [2 [3 4]]")).asStream;
~p.next(Event.default)
  ( 'degree': 0.0, 'dur': 1.0, 'g1': true )
  ( 'degree': 1.0, 'dur': 1.0 )
  ( 'degree': 2.0, 'dur': 0.5 )
  ( 'degree': 3.0, 'dur': 0.25 )
  ( 'degree': 4.0, 'dur': 0.25 )
  
// sequence with irregular sub division
~p = Pbind(\degree, Pdv.parse("0 1 [2 3 4]")).asStream;
~p.next(Event.default)
  ( 'degree': 0.0, 'dur': 1.0, 'g1': true )
  ( 'degree': 1.0, 'dur': 1.0 )
  ( 'degree': 2.0, 'dur': 0.33333333333333 )
  ( 'degree': 3.0, 'dur': 0.33333333333333 )
  ( 'degree': 4.0, 'dur': 0.33333333333333 )
  
// sequence with sub division stretched
~p = Pbind(\degree, Pdv.parse("0 1 [2 3 4]^2")).asStream;
~p.next(Event.default)
  ( 'degree': 0.0, 'dur': 1.0, 'g1': true )
  ( 'degree': 1.0, 'dur': 1.0 )
  ( 'degree': 2.0, 'dur': 0.66666666666667 )
  ( 'degree': 3.0, 'dur': 0.66666666666667 )
  ( 'degree': 4.0, 'dur': 0.66666666666667 )

// sequence with repeated value
~p = Pbind(\degree, Pdv.parse("0!4 1")).asStream;
~p.next(Event.default)
  ( 'degree': 0.0, 'dur': 0.25, 'g1': true )
  ( 'degree': 0.0, 'dur': 0.25 )
  ( 'degree': 0.0, 'dur': 0.25 )
  ( 'degree': 0.0, 'dur': 0.25 )
  ( 'degree': 1.0, 'dur': 1.0 )
 
// sequence with shuffled values each cycle
~p = Pbind(\degree, Pdv.parse("[0 1 2 3]$")) 
  equivalent: Pbind(\degree, Pshuf([ 1, 3, 2, 0 ], inf), \dur, 0.25)
  
// sequence with randomly selected value
~p = Pbind(\degree, Pdv.parse("[0 1 2 3]#")) 
  equivalent: Pbind(\degree, Prand([0, 1, 2, 3], inf), \dur, 1)

// optionally provide weights to values
~p = Pbind(\degree, Pdv.parse("[0 1 2 3]#(4321)")) 
  equivalent: Pbind(\degree, Pwrand([0, 1, 2, 3], [4, 3, 2, 1].normalizeSum, inf), \dur, 1)

// sequence with value or rest chosen by % chance
~p = Pbind(\degree, Pdv.parse("0%4 1%3 2%9 3%0")).asStream;
~p.next(Event.default)
  ( 'degree': rest, 'dur': Rest(1.0), 'g1': true )
  ( 'degree': rest, 'dur': Rest(1.0) )  
  ( 'degree': 2.0, 'dur': 1.0 )
  ( 'degree': rest, 'dur': Rest(1.0) )
  ( 'degree': rest, 'dur': Rest(1.0), 'g1': true )
  ( 'degree': 1.0, 'dur': 1.0 )
  ( 'degree': 2.0, 'dur': 1.0 )
  ( 'degree': rest, 'dur': Rest(1.0) )
 
// sequence with value or rest chosen by % chance at group level
~p = Pbind(\degree, Pdv.parse("[0 1 2 3]%4")).asStream;
~p.next(Event.default)
  ( 'degree': 0.0, 'dur': 0.25, 'g1': true )
  ( 'degree': 1.0, 'dur': 0.25 )
  ( 'degree': 2.0, 'dur': 0.25 )
  ( 'degree': rest, 'dur': Rest(0.25) )
  
// sequence with alternating values - similar to ppatlace
~p = Pbind(\degree, Pdv.parse("0 <1 2>")).asStream;
~p.next(Event.default)
  ( 'degree': 0.0, 'dur': 1.0, 'g1': true )
  ( 'degree': 1.0, 'dur': 1.0 )
  ( 'degree': 0.0, 'dur': 1.0, 'g1': true )
  ( 'degree': 2.0, 'dur': 1.0 )
  
// sequence with alternating values with grouping
~p = Pbind(\degree, Pdv.parse("0 <1 [2 3]>")).asStream;
~p.next(Event.default)
  ( 'degree': 0.0, 'dur': 1.0, 'g1': true )
  ( 'degree': 1.0, 'dur': 1.0 )
  ( 'degree': 0.0, 'dur': 1.0, 'g1': true )
  ( 'degree': 2.0, 'dur': 0.5 )
  ( 'degree': 3.0, 'dur': 0.5 )

// alternating values with stretched durs
~p = Pbind(\degree, Pdv.parse("0 <1 [2 3]>^2")).asStream;
~p.next(Event.default)
  ( 'degree': 0.0, 'dur': 1.0, 'g1': true )
  ( 'degree': 1.0, 'dur': 2.0 )
  ( 'degree': 0.0, 'dur': 1.0, 'g1': true )
  ( 'degree': 2.0, 'dur': 1.0 )
  ( 'degree': 3.0, 'dur': 1.0 )
  
// combining operators
~p = Pbind(\degree, Pdv.parse("0 <[2 3 4]$ [7 9 10]#>")).asStream;
~p.next(Event.default)
  ( 'degree': 0.0, 'dur': 1.0, 'g1': true )
  ( 'degree': 3.0, 'dur': 0.33333333333333 )
  ( 'degree': 4.0, 'dur': 0.33333333333333 )
  ( 'degree': 2.0, 'dur': 0.33333333333333 )
  ( 'degree': 0.0, 'dur': 1.0, 'g1': true )
  ( 'degree': 7.0, 'dur': 1.0 )

// use with midinote
~p = Pbind(\midinote, Pdv.parse("60 <[62 63 64]$ [67 69 70]#>")).asStream
~p.next(Event.default)
  ( 'dur': 1.0, 'midinote': 60.0, 'g1': true )
  ( 'dur': 0.33333333333333, 'midinote': 62.0 )
  ( 'dur': 0.33333333333333, 'midinote': 63.0 )
  ( 'dur': 0.33333333333333, 'midinote': 64.0 )
  ( 'dur': 1.0, 'midinote': 60.0, 'g1': true )
  ( 'dur': 1.0, 'midinote': 67.0 )
  
// you can further modulate values and durations with regular event keys
// e.g. modulate durations with \stretch
~p = Pbind(\degree, Pdv.parse("0 1 [2 3]"), \stretch, 0.5).asStream;
~p.next(Event.default)
  ( 'degree': 0.0, 'dur': 1.0, 'stretch': 0.5, 'g1': true )
  ( 'degree': 1.0, 'dur': 1.0, 'stretch': 0.5 )
  ( 'degree': 2.0, 'dur': 0.5, 'stretch': 0.5 )
  ( 'degree': 3.0, 'dur': 0.5, 'stretch': 0.5 )

*/

Pdv {

    *new {
    }

    *rout {|list|

        var gate = nil;

        ^Prout({|inval|

            var parse;

            parse = {|obj, div=1, stretch=1, chance=9|

                var val, rep, shuf, choose, weights;
                var result = ();

                val = obj['val'].value;
                stretch = (obj['stretch'] ?? stretch).value.asFloat;
                chance = (obj['chance'] ?? chance).value.asInteger;
                rep = (obj['rep'] ?? 1).value.asInteger;
                choose = obj['choose'];
                weights = obj['weights'];

                if (choose == true) {
                    if (val.isSequenceableCollection) {
                        if (weights.notNil) {
                            val = val.wchoose(weights.normalizeSum);
                        }{
                            val = val.choose;
                        }
                    }
                };

                if (val.isSequenceableCollection) {
                    var size = val.size;
                    val.do({|item|
                        parse.(item, div * size.reciprocal, stretch, chance);
                    });
                }{

                    if (obj['type'] == \value) {

                        if ( (chance/9).coin.not ) {
                            val = \rest;
                        };

                        if (val.isRest) {
                            div = Rest(div);
                        };
                        rep.do({|i|
                            inval[\g1] = gate;
                            inval['dur'] = div * rep.reciprocal * stretch;
                            inval = val.embedInStream(inval);
                            gate = nil
                        })
                    } {
                        parse.(val, div, stretch, chance)
                    }
                };
            };

            inf.do({
                gate = true;
                list.asArray.do({|val|
                    parse.(val);
                });
            });

            inval;
        });
    }

    *sequence {|list|

        var parse;

        parse = {|list, result|

            list.do({|item|
                var val = item['val'];
                if (item['type'] == \group) {
                    var mylist = List.new;
                    mylist = parse.(val, mylist);
                    result.add(
                        // is it necessary to do this here?
                        // or would it be better to move to rout function
                        item['val'] = if (item['shuf'] == true) {
                            { mylist.asArray.scramble }
                        } {
                            mylist
                        };
                    );
                } {
                    if (item['type'] == \alt) {
                        var mylist = List.new;
                        mylist = parse.(val, mylist);
                        result.add(
                            // we need to create the routine here
                            // otherwise we end up creating it each cycle
                            // and it would sequnce properly
                            item['val'] = Routine({
                                var cnt = 0;
                                inf.do({|i|
                                    if (item['shuf'] == true) {
                                        mylist = mylist.asArray.scramble;
                                    };
                                    mylist.wrapAt(i).yield;
                                    cnt = cnt + 1;
                                });
                            })
                        );
                    }{
                        result.add( item )
                    }
                }
            });
            result;
        };

        ^parse.(list, List.new);
    }

    *tokenize {|str|

        var exec, match;
        var getNextToken;
        var hasMoreTokens;
        var spec;
        var cursor = 0;

        // as pairs
        spec = [
            'number', "^[+-]?([0-9]*[.])?[0-9]+",
            'stretch', "^\\^",
            'rep', "^\!",
            'rest', "^\~",
            'shuf', "^\\$",
            'choose', "^\#",
            'chance', "^\%",
            'weights', "^\\([0-9]+\\)",
            '[', "^\\[",
            ']', "^\\]",
            '<', "^\<",
            '>', "^\>",
            nil, "^\\s+",
            nil, "^\,",

        ];

        hasMoreTokens = {
            cursor < str.size;
        };

        match = {|regex, str|
            var val = nil;
            var m = str.findRegexp(regex);
            if (m.size > 0) {
                val = m[0][1];
                cursor = cursor + val.size;
            };
            val;
        };

        getNextToken = {
            var getNext;
            var result = nil;
            getNext = {
                if (hasMoreTokens.()) {
                    spec.pairsDo({|k, v|
                        if (result.isNil) {
                            var val = match.(v, str[cursor..]);
                            //[k, v, val].debug("match");
                            if (val.notNil) {
                                if (k.isNil) {
                                    getNext.()
                                }{
                                    result = (
                                        type: k,
                                        val: val
                                    );
                                }
                            }
                        }
                    });
                };
            };

            getNext.();

            if (result.isNil) {
                "unexpected token %".format(str[cursor]).throw
            };
            result;
        };

        exec = {|list|

            var exit = false;
            while ({ hasMoreTokens.() and: { exit.not } }, {
                var token = getNextToken.();
                //token.debug("token");
                switch(token['type'],
                    // entities
                    'number', {
                        list.add( (val:token['val'].asFloat, type:\value) )
                    },
                    'rest', {
                        list.add( (val:\rest, type:\value) )
                    },
                    // modifiers
                    'stretch', {
                        list.last['stretch'] = getNextToken.()['val'].asFloat
                    },
                    'rep', {
                        list.last['rep'] = getNextToken.()['val'].asInteger;
                    },
                    'chance', {
                        list.last['chance'] = getNextToken.()['val'].asInteger;
                    },
                    'shuf', {
                        list.last['shuf'] = true;
                    },
                    'choose', {
                        list.last['choose'] = true;
                    },
                    'weights', {
                        var weights = token['val'];
                        weights = weights.findRegexp("\\d+")[0][1];
                        weights = weights.asString.as(Array).collect(_.digit);
                        list.last['weights'] = weights;//.debug("weights");
                    },
                    // grouping delimiters
                    '[', {
                        var result;
                        list.add( () );
                        result = exec.(List.new);
                        list.last['val'] = result;
                        list.last['type'] = 'group'
                    },
                    ']', {
                        exit = true
                    },
                    '<', {
                        var result;
                        list.add( () );
                        result = exec.(List.new);
                        list.last['val'] = result;
                        list.last['type'] = 'alt'
                    },
                    '>', {
                        exit = true
                    }
                );
            });

            list;
        };

        ^exec.(List.new);
    }

    *parse {|str|
        var list, seq;
        list = Pdv.tokenize(str);
        seq = Pdv.sequence(list)
        ^Pdv.rout(seq);
    }
}
