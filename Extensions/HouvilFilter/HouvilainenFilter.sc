HouvilainenFilter : Filter {
	*ar { |in, freq = 1000, res = 0, filtertype = 1|
		freq = freq.expexp(25, 22000, 0.001, 0.588);
		^this.multiNew('audio', in, freq, res, filtertype);
	}
}
/*
## 0 || Bypass
## 1 || LP 24db
## 2 || LP 18db
## 3 || LP 12db
## 4 || LP 6db
## 5 || HP 24db
## 6 || BP 24db
## 7 || N 24db
*/
HLPF : HouvilainenFilter {
  *ar { |in , freq = 1000, res = 0|
		^HouvilainenFilter.multiNew('audio', in, freq, res, 1);
              }
}
HLPF2 : HouvilainenFilter {
  *ar { |in , freq = 1000, res = 0|
		^HouvilainenFilter.multiNew('audio', in, freq, res, 2);
              }
}
HLPF3 : HouvilainenFilter {
  *ar { |in , freq = 1000, res = 0|
		^HouvilainenFilter.multiNew('audio', in, freq, res, 3);
              }
}
HLPF4 : HouvilainenFilter {
  *ar { |in , freq = 1000, res = 0|
		^HouvilainenFilter.multiNew('audio', in, freq, res, 4);
              }
}
HHPF : HouvilainenFilter {
  *ar { |in , freq = 1000, res = 0|
		^HouvilainenFilter.multiNew('audio', in, freq, res, 5);
              }
}
HNF : HouvilainenFilter {
  *ar { |in , freq = 1000, res = 0|
		^HouvilainenFilter.multiNew('audio', in, freq, res, 7);
              }
            }
HBPF : HouvilainenFilter {
  *ar { |in , freq = 1000, res = 0|
		^HouvilainenFilter.multiNew('audio', in, freq, res, 6);
              }
            }
