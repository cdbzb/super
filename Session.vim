let SessionLoad = 1
let s:so_save = &so | let s:siso_save = &siso | set so=0 siso=0
let v:this_session=expand("<sfile>:p")
silent only
cd ~/tank/super
if expand('%') == '' && !&modified && line('$') <= 1 && getline(1) == ''
  let s:wipebuf = bufnr('%')
endif
set shortmess=aoO
badd +1971 ~/tank/super/song.scd
badd +8 ~/tank/super/song-Synthdefs.scd
badd +22 ~/tank/super/song-sketches.scd
badd +70 ~/tank/super/Library/functions/trek.scd
argglobal
silent! argdel *
set stal=2
edit ~/tank/super/song.scd
set splitbelow splitright
set nosplitbelow
set nosplitright
wincmd t
set winminheight=0
set winheight=1
set winminwidth=0
set winwidth=1
argglobal
setlocal fdm=marker
setlocal fde=0
setlocal fmr={{{,}}}
setlocal fdi=#
setlocal fdl=0
setlocal fml=1
setlocal fdn=20
setlocal fen
1
normal! zo
23
normal! zo
175
normal! zo
200
normal! zo
226
normal! zo
689
normal! zo
716
normal! zo
717
normal! zo
726
normal! zo
735
normal! zo
772
normal! zo
797
normal! zo
811
normal! zo
828
normal! zo
842
normal! zo
854
normal! zo
867
normal! zo
888
normal! zo
925
normal! zo
925
normal! zc
1016
normal! zo
1016
normal! zc
1204
normal! zo
1222
normal! zo
1226
normal! zo
1232
normal! zo
1272
normal! zo
1950
normal! zo
1950
normal! zc
1969
normal! zo
let s:l = 1971 - ((98 * winheight(0) + 18) / 36)
if s:l < 1 | let s:l = 1 | endif
exe s:l
normal! zt
1971
normal! 0
tabedit ~/tank/super/Library/functions/trek.scd
set splitbelow splitright
set nosplitbelow
set nosplitright
wincmd t
set winminheight=0
set winheight=1
set winminwidth=0
set winwidth=1
argglobal
setlocal fdm=marker
setlocal fde=0
setlocal fmr={{{,}}}
setlocal fdi=#
setlocal fdl=0
setlocal fml=1
setlocal fdn=20
setlocal fen
2
normal! zo
2
normal! zo
40
normal! zo
2
normal! zc
70
normal! zo
70
normal! zc
let s:l = 70 - ((69 * winheight(0) + 18) / 36)
if s:l < 1 | let s:l = 1 | endif
exe s:l
normal! zt
70
normal! 0
tabedit ~/tank/super/song-Synthdefs.scd
set splitbelow splitright
set nosplitbelow
set nosplitright
wincmd t
set winminheight=0
set winheight=1
set winminwidth=0
set winwidth=1
argglobal
setlocal fdm=manual
setlocal fde=0
setlocal fmr={{{,}}}
setlocal fdi=#
setlocal fdl=0
setlocal fml=1
setlocal fdn=20
setlocal fen
silent! normal! zE
let s:l = 9 - ((8 * winheight(0) + 18) / 36)
if s:l < 1 | let s:l = 1 | endif
exe s:l
normal! zt
9
normal! 0
tabnext 1
set stal=1
if exists('s:wipebuf') && getbufvar(s:wipebuf, '&buftype') isnot# 'terminal'
  silent exe 'bwipe ' . s:wipebuf
endif
unlet! s:wipebuf
set winheight=1 winwidth=20 winminheight=1 winminwidth=1 shortmess=filnxtToOFIc
let s:sx = expand("<sfile>:p:r")."x.vim"
if file_readable(s:sx)
  exe "source " . fnameescape(s:sx)
endif
let &so = s:so_save | let &siso = s:siso_save
doautoall SessionLoadPost
unlet SessionLoad
" vim: set ft=vim :
