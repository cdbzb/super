let SessionLoad = 1
let s:so_save = &so | let s:siso_save = &siso | set so=0 siso=0
let v:this_session=expand("<sfile>:p")
let NERDTreeMapPreviewSplit = "gi"
let NERDTreeMapCloseChildren = "X"
let AutoPairsMapCh =  1 
let NERDTreeShowHidden =  1 
let NERDTreeMapCloseDir = "x"
let AutoPairsMapBS =  1 
let NERDTreeSortHiddenFirst = "1"
let AutoPairsShortcutBackInsert = "<M-b>"
let NERDTreeMinimalUI = "0"
let AutoPairsLoaded =  1 
let UltiSnipsExpandTrigger = "<tab>"
let NERDTreeRespectWildIgnore = "0"
let AutoPairsShortcutToggle = "<M-p>"
let NERDTreeAutoDeleteBuffer =  0 
let NERDTreeBookmarksFile = "/Users/michael/.NERDTreeBookmarks"
let UltiSnipsJumpForwardTrigger = "<c-j>"
let NERDTreeMapToggleHidden = "I"
let NERDTreeWinSize = "31"
let NERDTreeMenuUp = "k"
let NERDTreeSortDirs = "1"
let NERDTreeUseTCD = "0"
let UltiSnipsRemoveSelectModeMappings =  1 
let NERDTreeMapPreview = "go"
let NERDTreeCascadeSingleChildDir = "1"
let Taboo_tabs = "1	Talon\n2	Classes\n3	Project\n4	Functions\n6	SynthDefs\n7	additive \n"
let NERDTreeMapActivateNode = "o"
let NERDTreeMapCustomOpen = "<CR>"
let NERDTreeDirArrowExpandable = "▸"
let AutoPairsSmartQuotes =  1 
let NERDTreeMapMenu = "m"
let NERDTreeStatusline = "%{exists('b:NERDTree')?b:NERDTree.root.path.str():''}"
let NERDTreeMapOpenInTabSilent = "T"
let NERDTreeMapHelp = "?"
let NERDTreeMapJumpParent = "p"
let NERDTreeMapToggleFilters = "f"
let AutoPairsShortcutFastWrap = "<M-e>"
let NERDTreeMapJumpLastChild = "J"
let NERDTreeMapJumpPrevSibling = "<C-k>"
let NERDTreeNodeDelimiter = ""
let NERDTreeShowBookmarks = "0"
let NERDTreeRemoveDirCmd = "rm -rf "
let NERDTreeMapOpenInTab = "t"
let NERDTreeChDirMode = "0"
let AutoPairsCenterLine =  1 
let NERDTreeAutoCenterThreshold = "3"
let NERDTreeShowFiles = "1"
let NERDTreeMapOpenSplit = "i"
let NERDTreeCaseSensitiveSort = "0"
let NERDTreeHijackNetrw = "1"
let NERDTreeMapRefresh = "r"
let NERDTreeBookmarksSort = "1"
let NERDTreeHighlightCursorline = "1"
let UltiSnipsEnableSnipMate =  1 
let NERDTreeMouseMode = "1"
let NERDTreeMapCWD = "CD"
let NERDTreeNaturalSort = "0"
let NERDTreeMenuDown = "j"
let NERDTreeMapPreviewVSplit = "gs"
let NERDTreeNotificationThreshold = "100"
let AutoPairsMultilineClose =  1 
let NERDTreeMapJumpRoot = "P"
let UltiSnipsJumpBackwardTrigger = "<c-k>"
let BufExplorer_title = "[Buf List]"
let NERDTreeMapChdir = "cd"
let NERDTreeMapToggleZoom = "A"
let AutoPairsShortcutJump = "<M-n>"
let NERDTreeMarkBookmarks = "1"
let NERDTreeShowLineNumbers = "0"
let AutoPairsMapSpace =  1 
let NERDTreeMinimalMenu = "0"
let NERDTreeMapRefreshRoot = "R"
let NERDTreeCreatePrefix = "silent"
let NERDTreeAutoCenter = "1"
let NERDTreeCascadeOpenSingleChildDir = "1"
let AutoPairsFlyMode =  0 
let NERDTreeMapOpenVSplit = "s"
let NERDTreeWinPos = "left"
let NERDTreeMapDeleteBookmark = "D"
let UltiSnipsListSnippets = "<c-tab>"
let UltiSnips#ExpandTrigger = "�kB"
let NERDTreeMapJumpNextSibling = "<C-j>"
let UltiSnipsEditSplit = "normal"
let NERDTreeCopyCmd = "cp -r "
let NERDTreeMapQuit = "q"
let NERDTreeMapChangeRoot = "C"
let NERDTreeMapToggleFiles = "F"
let AutoPairsMapCR =  0 
let NERDTreeMapOpenExpl = "e"
let NERDTreeMapJumpFirstChild = "K"
let NERDTreeGlyphReadOnly = "RO"
let NERDTreeDirArrowCollapsible = "▾"
let NERDTreeMapOpenRecursively = "O"
let NERDTreeMapToggleBookmarks = "B"
let AutoPairsMoveCharacter = "()[]{}\"'"
let AutoPairsWildClosedPair = ""
let NERDTreeMapUpdir = "u"
let NERDTreeMapUpdirKeepOpen = "U"
let NERDTreeQuitOnOpen = "0"
silent only
cd ~/tank/super/Library
if expand('%') == '' && !&modified && line('$') <= 1 && getline(1) == ''
  let s:wipebuf = bufnr('%')
endif
set shortmess=aoO
badd +186 ~/.talon/user/knausj_talon/code/numbers.py
badd +15 ~/.talon/user/mw_talon/sclang.talon
badd +12 ~/.talon/user/mw_talon/vocabulary.py
badd +356 ~/.talon/user/mw_talon/vim.talon
badd +491 ~/tank/super/Extensions/MW-Classes/Song-Part.sc
badd +27 ~/tank/super/Extensions/MW-Classes/XTouch.sc
badd +1 ~/tank/super/More-Organized-Trek/panelTesting2.scd
badd +5 ~/.talon/user/knausj_talon/settings/additional_words.csv
badd +1 ~/.talon/user/knausj_talon/misc/macro.talon
badd +2 ~/.talon/user/knausj_talon/misc/micropone_selection.talon
badd +9 ~/.talon/user/knausj_talon/misc/standard.talon
badd +10 ~/.talon/user/w2l.py
badd +11 ~/.talon/user/knausj_talon/misc/keys.talon
badd +48 ~/.talon/COPY/knausj_talon_copy/apps/terminal.talon
badd +22 ~/.talon/user/knausj_talon/apps/mac/terminal.talon
badd +1 ~/.talon/user/knausj_talon/apps/linux/terminal.talon
badd +1 ~/.talon/user/mw_talon/iterm.talon
badd +9 /private/tmp/trashme.scd
badd +159 ~/tank/super/song-Synthdefs.scd
badd +1 ~/tank/super/More-Organized-Trek/\[sclang]
badd +50 ~/tank/super/More-Organized-Trek/panel2.scd
badd +1 ~/tank/super/return-to-tomorrow.txt
badd +300 ~/tank/super/More-Organized-Trek/Songs/Unnecessary-refmt.scd
badd +245 ~/tank/super/Library/functions/trek.scd
badd +2 ~/.talon/user/mw_talon/symbols.talon
badd +3 ~/.talon/user/mw_talon/symbols2.talon
badd +31 ~/.talon/user/knausj_talon/text/symbols.talon
badd +3 ~/.talon/user/knausj_talon/text/numbers.talon
badd +35 ~/.talon/user/knausj_talon/code/user_settings.py
badd +133 ~/.talon/user/knausj_talon/code/keys.py
badd +1 ~/.talon/user/mw_talon/key.py
badd +1 ~/.talon/user/knausj_talon/code
badd +1 ~/tank/super/scales.scd
badd +6 ~/tank/super/nine-note-scale.scd
badd +73 ~/Library/Application\ Support/SuperCollider/Help/Classes/Scale.txt
badd +183 ~/tank/super/additive2020.scd
badd +1004 ~/Library/Application\ Support/SuperCollider/Help/Classes/Array.txt
badd +3336 ~/tank/super/\[sclang]
badd +1 ~/tank/super/Extensions/MW-Classes/Synths
badd +34 ~/tank/super/Extensions/MW-Classes/Synths.sc
badd +370 ~/Library/Application\ Support/SuperCollider/Help/Classes/Stream.txt
badd +1557 ~/Library/Application\ Support/SuperCollider/Help/Classes/SequenceableCollection.txt
badd +1060 ~/tank/super/More-Organized-Trek/Songs/\[sclang]
badd +1 ~/.talon/user/knausj_talon/misc/history.talon
badd +775 ~/Library/Application\ Support/SuperCollider/Help/Classes/Server.txt
badd +81 ~/Library/Application\ Support/SuperCollider/Help/Classes/Event.txt
argglobal
%argdel
set stal=2
edit ~/.talon/user/mw_talon/sclang.talon
set splitbelow splitright
wincmd _ | wincmd |
vsplit
wincmd _ | wincmd |
vsplit
2wincmd h
wincmd _ | wincmd |
split
1wincmd k
wincmd w
wincmd w
wincmd _ | wincmd |
split
1wincmd k
wincmd w
wincmd w
set nosplitbelow
set nosplitright
wincmd t
set winminheight=0
set winheight=1
set winminwidth=0
set winwidth=1
exe '1resize ' . ((&lines * 18 + 20) / 40)
exe 'vert 1resize ' . ((&columns * 50 + 75) / 151)
exe '2resize ' . ((&lines * 18 + 20) / 40)
exe 'vert 2resize ' . ((&columns * 50 + 75) / 151)
exe '3resize ' . ((&lines * 18 + 20) / 40)
exe 'vert 3resize ' . ((&columns * 22 + 75) / 151)
exe '4resize ' . ((&lines * 18 + 20) / 40)
exe 'vert 4resize ' . ((&columns * 22 + 75) / 151)
exe 'vert 5resize ' . ((&columns * 77 + 75) / 151)
argglobal
setlocal fdm=manual
setlocal fde=FoldParts(v:lnum)
setlocal fmr={{{,}}}
setlocal fdi=#
setlocal fdl=0
setlocal fml=1
setlocal fdn=20
setlocal fen
silent! normal! zE
let s:l = 15 - ((0 * winheight(0) + 9) / 18)
if s:l < 1 | let s:l = 1 | endif
exe s:l
normal! zt
15
normal! 0
wincmd w
argglobal
if bufexists("~/.talon/user/mw_talon/iterm.talon") | buffer ~/.talon/user/mw_talon/iterm.talon | else | edit ~/.talon/user/mw_talon/iterm.talon | endif
if &buftype ==# 'terminal'
  silent file ~/.talon/user/mw_talon/iterm.talon
endif
setlocal fdm=manual
setlocal fde=0
setlocal fmr={{{,}}}
setlocal fdi=#
setlocal fdl=0
setlocal fml=1
setlocal fdn=20
setlocal fen
silent! normal! zE
let s:l = 8 - ((0 * winheight(0) + 9) / 18)
if s:l < 1 | let s:l = 1 | endif
exe s:l
normal! zt
8
normal! 0
wincmd w
argglobal
if bufexists("~/.talon/user/knausj_talon/misc/history.talon") | buffer ~/.talon/user/knausj_talon/misc/history.talon | else | edit ~/.talon/user/knausj_talon/misc/history.talon | endif
if &buftype ==# 'terminal'
  silent file ~/.talon/user/knausj_talon/misc/history.talon
endif
setlocal fdm=manual
setlocal fde=0
setlocal fmr={{{,}}}
setlocal fdi=#
setlocal fdl=0
setlocal fml=1
setlocal fdn=20
setlocal fen
silent! normal! zE
let s:l = 4 - ((3 * winheight(0) + 9) / 18)
if s:l < 1 | let s:l = 1 | endif
exe s:l
normal! zt
4
normal! 0
wincmd w
argglobal
if bufexists("~/.talon/user/mw_talon/vim.talon") | buffer ~/.talon/user/mw_talon/vim.talon | else | edit ~/.talon/user/mw_talon/vim.talon | endif
if &buftype ==# 'terminal'
  silent file ~/.talon/user/mw_talon/vim.talon
endif
setlocal fdm=manual
setlocal fde=0
setlocal fmr={{{,}}}
setlocal fdi=#
setlocal fdl=0
setlocal fml=1
setlocal fdn=20
setlocal fen
silent! normal! zE
let s:l = 82 - ((5 * winheight(0) + 9) / 18)
if s:l < 1 | let s:l = 1 | endif
exe s:l
normal! zt
82
normal! 0
wincmd w
argglobal
if bufexists("~/.talon/user/mw_talon/vocabulary.py") | buffer ~/.talon/user/mw_talon/vocabulary.py | else | edit ~/.talon/user/mw_talon/vocabulary.py | endif
if &buftype ==# 'terminal'
  silent file ~/.talon/user/mw_talon/vocabulary.py
endif
setlocal fdm=manual
setlocal fde=0
setlocal fmr={{{,}}}
setlocal fdi=#
setlocal fdl=0
setlocal fml=1
setlocal fdn=20
setlocal fen
silent! normal! zE
let s:l = 12 - ((8 * winheight(0) + 18) / 37)
if s:l < 1 | let s:l = 1 | endif
exe s:l
normal! zt
12
normal! 0
wincmd w
exe '1resize ' . ((&lines * 18 + 20) / 40)
exe 'vert 1resize ' . ((&columns * 50 + 75) / 151)
exe '2resize ' . ((&lines * 18 + 20) / 40)
exe 'vert 2resize ' . ((&columns * 50 + 75) / 151)
exe '3resize ' . ((&lines * 18 + 20) / 40)
exe 'vert 3resize ' . ((&columns * 22 + 75) / 151)
exe '4resize ' . ((&lines * 18 + 20) / 40)
exe 'vert 4resize ' . ((&columns * 22 + 75) / 151)
exe 'vert 5resize ' . ((&columns * 77 + 75) / 151)
tabedit ~/tank/super/Extensions/MW-Classes/Synths.sc
set splitbelow splitright
wincmd _ | wincmd |
vsplit
1wincmd h
wincmd _ | wincmd |
split
1wincmd k
wincmd w
wincmd w
set nosplitbelow
set nosplitright
wincmd t
set winminheight=0
set winheight=1
set winminwidth=0
set winwidth=1
exe '1resize ' . ((&lines * 18 + 20) / 40)
exe 'vert 1resize ' . ((&columns * 50 + 75) / 151)
exe '2resize ' . ((&lines * 18 + 20) / 40)
exe 'vert 2resize ' . ((&columns * 50 + 75) / 151)
exe 'vert 3resize ' . ((&columns * 100 + 75) / 151)
argglobal
setlocal fdm=manual
setlocal fde=FoldParts(v:lnum)
setlocal fmr={{{,}}}
setlocal fdi=#
setlocal fdl=0
setlocal fml=1
setlocal fdn=20
setlocal fen
silent! normal! zE
let s:l = 34 - ((9 * winheight(0) + 9) / 18)
if s:l < 1 | let s:l = 1 | endif
exe s:l
normal! zt
34
normal! 09|
wincmd w
argglobal
if bufexists("~/tank/super/Extensions/MW-Classes/Song-Part.sc") | buffer ~/tank/super/Extensions/MW-Classes/Song-Part.sc | else | edit ~/tank/super/Extensions/MW-Classes/Song-Part.sc | endif
if &buftype ==# 'terminal'
  silent file ~/tank/super/Extensions/MW-Classes/Song-Part.sc
endif
setlocal fdm=manual
setlocal fde=FoldParts(v:lnum)
setlocal fmr={{{,}}}
setlocal fdi=#
setlocal fdl=0
setlocal fml=1
setlocal fdn=20
setlocal fen
silent! normal! zE
56,69fold
70,92fold
93,105fold
106,106fold
106,165fold
56
normal! zo
70
normal! zo
93
normal! zo
106
normal! zo
let s:l = 491 - ((12 * winheight(0) + 9) / 18)
if s:l < 1 | let s:l = 1 | endif
exe s:l
normal! zt
491
normal! 0
wincmd w
argglobal
if bufexists("~/tank/super/Extensions/MW-Classes/XTouch.sc") | buffer ~/tank/super/Extensions/MW-Classes/XTouch.sc | else | edit ~/tank/super/Extensions/MW-Classes/XTouch.sc | endif
if &buftype ==# 'terminal'
  silent file ~/tank/super/Extensions/MW-Classes/XTouch.sc
endif
setlocal fdm=manual
setlocal fde=FoldParts(v:lnum)
setlocal fmr={{{,}}}
setlocal fdi=#
setlocal fdl=0
setlocal fml=1
setlocal fdn=20
setlocal fen
silent! normal! zE
let s:l = 27 - ((18 * winheight(0) + 18) / 37)
if s:l < 1 | let s:l = 1 | endif
exe s:l
normal! zt
27
normal! 09|
wincmd w
exe '1resize ' . ((&lines * 18 + 20) / 40)
exe 'vert 1resize ' . ((&columns * 50 + 75) / 151)
exe '2resize ' . ((&lines * 18 + 20) / 40)
exe 'vert 2resize ' . ((&columns * 50 + 75) / 151)
exe 'vert 3resize ' . ((&columns * 100 + 75) / 151)
tabedit /private/tmp/trashme.scd
set splitbelow splitright
wincmd _ | wincmd |
vsplit
1wincmd h
wincmd _ | wincmd |
split
1wincmd k
wincmd w
wincmd w
set nosplitbelow
set nosplitright
wincmd t
set winminheight=0
set winheight=1
set winminwidth=0
set winwidth=1
exe '1resize ' . ((&lines * 9 + 20) / 40)
exe 'vert 1resize ' . ((&columns * 73 + 75) / 151)
exe '2resize ' . ((&lines * 27 + 20) / 40)
exe 'vert 2resize ' . ((&columns * 73 + 75) / 151)
exe 'vert 3resize ' . ((&columns * 77 + 75) / 151)
argglobal
setlocal fdm=manual
setlocal fde=FoldParts(v:lnum)
setlocal fmr={{{,}}}
setlocal fdi=#
setlocal fdl=0
setlocal fml=1
setlocal fdn=20
setlocal fen
silent! normal! zE
let s:l = 9 - ((0 * winheight(0) + 4) / 9)
if s:l < 1 | let s:l = 1 | endif
exe s:l
normal! zt
9
normal! 0
wincmd w
argglobal
if bufexists("~/tank/super/More-Organized-Trek/Songs/Unnecessary-refmt.scd") | buffer ~/tank/super/More-Organized-Trek/Songs/Unnecessary-refmt.scd | else | edit ~/tank/super/More-Organized-Trek/Songs/Unnecessary-refmt.scd | endif
if &buftype ==# 'terminal'
  silent file ~/tank/super/More-Organized-Trek/Songs/Unnecessary-refmt.scd
endif
setlocal fdm=expr
setlocal fde=FoldParts(v:lnum)
setlocal fmr={{{,}}}
setlocal fdi=#
setlocal fdl=1
setlocal fml=1
setlocal fdn=20
setlocal fen
1
normal! zo
1
normal! zo
1
normal! zo
177
normal! zo
195
normal! zo
215
normal! zo
242
normal! zo
250
normal! zo
260
normal! zo
284
normal! zo
286
normal! zo
288
normal! zo
290
normal! zo
297
normal! zo
299
normal! zo
307
normal! zo
320
normal! zo
323
normal! zo
326
normal! zo
let s:l = 320 - ((0 * winheight(0) + 13) / 27)
if s:l < 1 | let s:l = 1 | endif
exe s:l
normal! zt
320
normal! 0
wincmd w
argglobal
if bufexists("~/tank/super/More-Organized-Trek/Songs/\[sclang]") | buffer ~/tank/super/More-Organized-Trek/Songs/\[sclang] | else | edit ~/tank/super/More-Organized-Trek/Songs/\[sclang] | endif
if &buftype ==# 'terminal'
  silent file ~/tank/super/More-Organized-Trek/Songs/\[sclang]
endif
setlocal fdm=manual
setlocal fde=FoldParts(v:lnum)
setlocal fmr={{{,}}}
setlocal fdi=#
setlocal fdl=0
setlocal fml=1
setlocal fdn=20
setlocal nofen
silent! normal! zE
let s:l = 1060 - ((0 * winheight(0) + 18) / 37)
if s:l < 1 | let s:l = 1 | endif
exe s:l
normal! zt
1060
normal! 0
wincmd w
exe '1resize ' . ((&lines * 9 + 20) / 40)
exe 'vert 1resize ' . ((&columns * 73 + 75) / 151)
exe '2resize ' . ((&lines * 27 + 20) / 40)
exe 'vert 2resize ' . ((&columns * 73 + 75) / 151)
exe 'vert 3resize ' . ((&columns * 77 + 75) / 151)
tabedit ~/tank/super/Library/functions/trek.scd
set splitbelow splitright
wincmd _ | wincmd |
split
1wincmd k
wincmd w
set nosplitbelow
set nosplitright
wincmd t
set winminheight=0
set winheight=1
set winminwidth=0
set winwidth=1
exe '1resize ' . ((&lines * 18 + 20) / 40)
exe '2resize ' . ((&lines * 18 + 20) / 40)
argglobal
setlocal fdm=marker
setlocal fde=FoldParts(v:lnum)
setlocal fmr={{{,}}}
setlocal fdi=#
setlocal fdl=0
setlocal fml=1
setlocal fdn=20
setlocal fen
3
normal! zo
74
normal! zo
80
normal! zo
241
normal! zo
let s:l = 245 - ((18 * winheight(0) + 9) / 18)
if s:l < 1 | let s:l = 1 | endif
exe s:l
normal! zt
245
normal! 021|
wincmd w
argglobal
enew
file ~/tank/super/Library/NERD_tree_1
setlocal fdm=manual
setlocal fde=FoldParts(v:lnum)
setlocal fmr={{{,}}}
setlocal fdi=#
setlocal fdl=0
setlocal fml=1
setlocal fdn=20
setlocal nofen
wincmd w
2wincmd w
exe '1resize ' . ((&lines * 18 + 20) / 40)
exe '2resize ' . ((&lines * 18 + 20) / 40)
tabedit ~/tank/super/return-to-tomorrow.txt
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
let s:l = 331 - ((257 * winheight(0) + 18) / 37)
if s:l < 1 | let s:l = 1 | endif
exe s:l
normal! zt
331
normal! 0
tabedit ~/tank/super/song-Synthdefs.scd
set splitbelow splitright
wincmd _ | wincmd |
vsplit
1wincmd h
wincmd w
set nosplitbelow
set nosplitright
wincmd t
set winminheight=0
set winheight=1
set winminwidth=0
set winwidth=1
exe 'vert 1resize ' . ((&columns * 73 + 75) / 151)
exe 'vert 2resize ' . ((&columns * 77 + 75) / 151)
argglobal
setlocal fdm=expr
setlocal fde=FoldParts(v:lnum)
setlocal fmr={{{,}}}
setlocal fdi=#
setlocal fdl=1
setlocal fml=1
setlocal fdn=20
setlocal fen
3
normal! zo
3
normal! zo
3
normal! zo
3
normal! zo
149
normal! zo
let s:l = 159 - ((113 * winheight(0) + 18) / 37)
if s:l < 1 | let s:l = 1 | endif
exe s:l
normal! zt
159
normal! 09|
wincmd w
argglobal
enew
setlocal fdm=manual
setlocal fde=0
setlocal fmr={{{,}}}
setlocal fdi=#
setlocal fdl=0
setlocal fml=1
setlocal fdn=20
setlocal nofen
wincmd w
exe 'vert 1resize ' . ((&columns * 73 + 75) / 151)
exe 'vert 2resize ' . ((&columns * 77 + 75) / 151)
tabedit ~/Library/Application\ Support/SuperCollider/Help/Classes/Array.txt
set splitbelow splitright
wincmd _ | wincmd |
vsplit
1wincmd h
wincmd _ | wincmd |
split
wincmd _ | wincmd |
split
2wincmd k
wincmd w
wincmd w
wincmd w
set nosplitbelow
set nosplitright
wincmd t
set winminheight=0
set winheight=1
set winminwidth=0
set winwidth=1
exe '1resize ' . ((&lines * 13 + 20) / 40)
exe 'vert 1resize ' . ((&columns * 93 + 75) / 151)
exe '2resize ' . ((&lines * 12 + 20) / 40)
exe 'vert 2resize ' . ((&columns * 93 + 75) / 151)
exe '3resize ' . ((&lines * 10 + 20) / 40)
exe 'vert 3resize ' . ((&columns * 93 + 75) / 151)
exe 'vert 4resize ' . ((&columns * 57 + 75) / 151)
argglobal
setlocal fdm=manual
setlocal fde=FoldParts(v:lnum)
setlocal fmr={{{,}}}
setlocal fdi=#
setlocal fdl=0
setlocal fml=1
setlocal fdn=20
setlocal fen
silent! normal! zE
let s:l = 1004 - ((5 * winheight(0) + 6) / 13)
if s:l < 1 | let s:l = 1 | endif
exe s:l
normal! zt
1004
normal! 0
wincmd w
argglobal
if bufexists("~/tank/super/additive2020.scd") | buffer ~/tank/super/additive2020.scd | else | edit ~/tank/super/additive2020.scd | endif
if &buftype ==# 'terminal'
  silent file ~/tank/super/additive2020.scd
endif
setlocal fdm=manual
setlocal fde=FoldParts(v:lnum)
setlocal fmr={{{,}}}
setlocal fdi=#
setlocal fdl=0
setlocal fml=1
setlocal fdn=20
setlocal fen
silent! normal! zE
let s:l = 153 - ((5 * winheight(0) + 6) / 12)
if s:l < 1 | let s:l = 1 | endif
exe s:l
normal! zt
153
normal! 0
wincmd w
argglobal
enew
setlocal fdm=manual
setlocal fde=FoldParts(v:lnum)
setlocal fmr={{{,}}}
setlocal fdi=#
setlocal fdl=0
setlocal fml=1
setlocal fdn=20
setlocal fen
wincmd w
argglobal
if bufexists("~/tank/super/\[sclang]") | buffer ~/tank/super/\[sclang] | else | edit ~/tank/super/\[sclang] | endif
if &buftype ==# 'terminal'
  silent file ~/tank/super/\[sclang]
endif
setlocal fdm=manual
setlocal fde=FoldParts(v:lnum)
setlocal fmr={{{,}}}
setlocal fdi=#
setlocal fdl=0
setlocal fml=1
setlocal fdn=20
setlocal nofen
silent! normal! zE
let s:l = 4158 - ((24 * winheight(0) + 18) / 37)
if s:l < 1 | let s:l = 1 | endif
exe s:l
normal! zt
4158
normal! 0
wincmd w
exe '1resize ' . ((&lines * 13 + 20) / 40)
exe 'vert 1resize ' . ((&columns * 93 + 75) / 151)
exe '2resize ' . ((&lines * 12 + 20) / 40)
exe 'vert 2resize ' . ((&columns * 93 + 75) / 151)
exe '3resize ' . ((&lines * 10 + 20) / 40)
exe 'vert 3resize ' . ((&columns * 93 + 75) / 151)
exe 'vert 4resize ' . ((&columns * 57 + 75) / 151)
tabnext 4
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
