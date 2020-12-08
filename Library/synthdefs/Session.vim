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
let Taboo_tabs = "1	Talon\n2	Classes\n3	Project\n5	Functions\n6	AddSynths\n8	SynthDefs\n"
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
cd ~/tank/super/Library/synthdefs
if expand('%') == '' && !&modified && line('$') <= 1 && getline(1) == ''
  let s:wipebuf = bufnr('%')
endif
set shortmess=aoO
badd +186 ~/.talon/user/knausj_talon/code/numbers.py
badd +25 ~/.talon/user/mw_talon/sclang.talon
badd +12 ~/.talon/user/mw_talon/vocabulary.py
badd +356 ~/.talon/user/mw_talon/vim.talon
badd +491 ~/tank/super/Extensions/MW-Classes/Song-Part.sc
badd +34 ~/tank/super/Extensions/MW-Classes/XTouch.sc
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
badd +1 /private/tmp/trashme.scd
badd +159 ~/tank/super/song-Synthdefs.scd
badd +1 ~/tank/super/More-Organized-Trek/\[sclang]
badd +50 ~/tank/super/More-Organized-Trek/panel2.scd
badd +1 ~/tank/super/return-to-tomorrow.txt
badd +230 ~/tank/super/More-Organized-Trek/Songs/Unnecessary-refmt.scd
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
badd +221 ~/tank/super/additive2020.scd
badd +1005 ~/Library/Application\ Support/SuperCollider/Help/Classes/Array.txt
badd +2600 ~/tank/super/\[sclang]
badd +1 ~/tank/super/Extensions/MW-Classes/Synths
badd +22 ~/tank/super/Extensions/MW-Classes/Synths.sc
badd +370 ~/Library/Application\ Support/SuperCollider/Help/Classes/Stream.txt
badd +2487 ~/Library/Application\ Support/SuperCollider/Help/Classes/SequenceableCollection.txt
badd +1060 ~/tank/super/More-Organized-Trek/Songs/\[sclang]
badd +1 ~/.talon/user/knausj_talon/misc/history.talon
badd +775 ~/Library/Application\ Support/SuperCollider/Help/Classes/Server.txt
badd +81 ~/Library/Application\ Support/SuperCollider/Help/Classes/Event.txt
badd +390 ~/Library/Application\ Support/SuperCollider/Help/Classes/SynthDef.txt
badd +349 ~/Library/Application\ Support/SuperCollider/Help/Classes/Group.txt
badd +79 ~/Library/Application\ Support/SuperCollider/Help/Classes/Function.txt
badd +31 ~/tank/super/Library/synthdefs/reedy.scd
badd +65 /Applications/SuperCollider.app/Contents/Resources/SCClassLibrary/Common/Collections/Harmonics.sc
badd +639 ~/Library/Application\ Support/SuperCollider/Help/Classes/Symbol.txt
badd +748 ~/Library/Application\ Support/SuperCollider/Help/Classes/AbstractFunction.txt
badd +1 ~/Library/Application\ Support/SuperCollider/Help/Classes/SimpleNumber.txt
badd +162 ~/tank/super/Extensions/SC3plugins/LoopBufUGens/classes/LJP\ Classes/ProbabilityDistributions.sc
badd +36 ~/tank/super/probability.scd
badd +267 ~/Library/Application\ Support/SuperCollider/Help/Classes/Phrase.txt
badd +139 ~/Library/Application\ Support/SuperCollider/Help/Classes/Harmonics.txt
badd +536 ~/Library/Application\ Support/SuperCollider/Help/Classes/Pbind.txt
badd +3 ~/Library/Application\ Support/SuperCollider/Help/Classes/Splay.txt
badd +11 ~/Library/Application\ Support/SuperCollider/Help/Classes/SplayAz.txt
badd +0 ~/tank/super/Library/synthdefs/\[sclang]
badd +641 ~/Library/Application\ Support/SuperCollider/Help/Classes/Synth.txt
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
exe '1resize ' . ((&lines * 26 + 27) / 55)
exe 'vert 1resize ' . ((&columns * 84 + 126) / 253)
exe '2resize ' . ((&lines * 25 + 27) / 55)
exe 'vert 2resize ' . ((&columns * 84 + 126) / 253)
exe '3resize ' . ((&lines * 26 + 27) / 55)
exe 'vert 3resize ' . ((&columns * 38 + 126) / 253)
exe '4resize ' . ((&lines * 25 + 27) / 55)
exe 'vert 4resize ' . ((&columns * 38 + 126) / 253)
exe 'vert 5resize ' . ((&columns * 129 + 126) / 253)
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
let s:l = 25 - ((11 * winheight(0) + 13) / 26)
if s:l < 1 | let s:l = 1 | endif
exe s:l
normal! zt
25
normal! 06|
wincmd w
argglobal
if bufexists("~/.talon/user/mw_talon/iterm.talon") | buffer ~/.talon/user/mw_talon/iterm.talon | else | edit ~/.talon/user/mw_talon/iterm.talon | endif
setlocal fdm=manual
setlocal fde=0
setlocal fmr={{{,}}}
setlocal fdi=#
setlocal fdl=0
setlocal fml=1
setlocal fdn=20
setlocal fen
silent! normal! zE
let s:l = 11 - ((0 * winheight(0) + 12) / 25)
if s:l < 1 | let s:l = 1 | endif
exe s:l
normal! zt
11
normal! 04|
wincmd w
argglobal
if bufexists("~/.talon/user/knausj_talon/misc/history.talon") | buffer ~/.talon/user/knausj_talon/misc/history.talon | else | edit ~/.talon/user/knausj_talon/misc/history.talon | endif
setlocal fdm=manual
setlocal fde=0
setlocal fmr={{{,}}}
setlocal fdi=#
setlocal fdl=0
setlocal fml=1
setlocal fdn=20
setlocal fen
silent! normal! zE
let s:l = 4 - ((3 * winheight(0) + 13) / 26)
if s:l < 1 | let s:l = 1 | endif
exe s:l
normal! zt
4
normal! 0
wincmd w
argglobal
if bufexists("~/.talon/user/mw_talon/vim.talon") | buffer ~/.talon/user/mw_talon/vim.talon | else | edit ~/.talon/user/mw_talon/vim.talon | endif
setlocal fdm=manual
setlocal fde=0
setlocal fmr={{{,}}}
setlocal fdi=#
setlocal fdl=0
setlocal fml=1
setlocal fdn=20
setlocal fen
silent! normal! zE
let s:l = 214 - ((6 * winheight(0) + 12) / 25)
if s:l < 1 | let s:l = 1 | endif
exe s:l
normal! zt
214
normal! 0
wincmd w
argglobal
if bufexists("~/.talon/user/mw_talon/vocabulary.py") | buffer ~/.talon/user/mw_talon/vocabulary.py | else | edit ~/.talon/user/mw_talon/vocabulary.py | endif
setlocal fdm=manual
setlocal fde=0
setlocal fmr={{{,}}}
setlocal fdi=#
setlocal fdl=0
setlocal fml=1
setlocal fdn=20
setlocal fen
silent! normal! zE
let s:l = 12 - ((11 * winheight(0) + 26) / 52)
if s:l < 1 | let s:l = 1 | endif
exe s:l
normal! zt
12
normal! 0
wincmd w
exe '1resize ' . ((&lines * 26 + 27) / 55)
exe 'vert 1resize ' . ((&columns * 84 + 126) / 253)
exe '2resize ' . ((&lines * 25 + 27) / 55)
exe 'vert 2resize ' . ((&columns * 84 + 126) / 253)
exe '3resize ' . ((&lines * 26 + 27) / 55)
exe 'vert 3resize ' . ((&columns * 38 + 126) / 253)
exe '4resize ' . ((&lines * 25 + 27) / 55)
exe 'vert 4resize ' . ((&columns * 38 + 126) / 253)
exe 'vert 5resize ' . ((&columns * 129 + 126) / 253)
tabedit ~/tank/super/Extensions/MW-Classes/Synths.sc
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
wincmd w
set nosplitbelow
set nosplitright
wincmd t
set winminheight=0
set winheight=1
set winminwidth=0
set winwidth=1
exe '1resize ' . ((&lines * 26 + 27) / 55)
exe 'vert 1resize ' . ((&columns * 84 + 126) / 253)
exe '2resize ' . ((&lines * 25 + 27) / 55)
exe 'vert 2resize ' . ((&columns * 84 + 126) / 253)
exe 'vert 3resize ' . ((&columns * 38 + 126) / 253)
exe 'vert 4resize ' . ((&columns * 129 + 126) / 253)
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
let s:l = 22 - ((0 * winheight(0) + 13) / 26)
if s:l < 1 | let s:l = 1 | endif
exe s:l
normal! zt
22
normal! 09|
wincmd w
argglobal
if bufexists("~/tank/super/Extensions/MW-Classes/Song-Part.sc") | buffer ~/tank/super/Extensions/MW-Classes/Song-Part.sc | else | edit ~/tank/super/Extensions/MW-Classes/Song-Part.sc | endif
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
let s:l = 491 - ((0 * winheight(0) + 12) / 25)
if s:l < 1 | let s:l = 1 | endif
exe s:l
normal! zt
491
normal! 0
wincmd w
argglobal
if bufexists("~/tank/super/Extensions/MW-Classes/Synths.sc") | buffer ~/tank/super/Extensions/MW-Classes/Synths.sc | else | edit ~/tank/super/Extensions/MW-Classes/Synths.sc | endif
setlocal fdm=manual
setlocal fde=FoldParts(v:lnum)
setlocal fmr={{{,}}}
setlocal fdi=#
setlocal fdl=0
setlocal fml=1
setlocal fdn=20
setlocal fen
silent! normal! zE
let s:l = 22 - ((21 * winheight(0) + 26) / 52)
if s:l < 1 | let s:l = 1 | endif
exe s:l
normal! zt
22
normal! 039|
wincmd w
argglobal
if bufexists("~/tank/super/Library/synthdefs/\[sclang]") | buffer ~/tank/super/Library/synthdefs/\[sclang] | else | edit ~/tank/super/Library/synthdefs/\[sclang] | endif
setlocal fdm=manual
setlocal fde=0
setlocal fmr={{{,}}}
setlocal fdi=#
setlocal fdl=0
setlocal fml=1
setlocal fdn=20
setlocal nofen
silent! normal! zE
let s:l = 1 - ((0 * winheight(0) + 26) / 52)
if s:l < 1 | let s:l = 1 | endif
exe s:l
normal! zt
1
normal! 0
wincmd w
exe '1resize ' . ((&lines * 26 + 27) / 55)
exe 'vert 1resize ' . ((&columns * 84 + 126) / 253)
exe '2resize ' . ((&lines * 25 + 27) / 55)
exe 'vert 2resize ' . ((&columns * 84 + 126) / 253)
exe 'vert 3resize ' . ((&columns * 38 + 126) / 253)
exe 'vert 4resize ' . ((&columns * 129 + 126) / 253)
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
exe '1resize ' . ((&lines * 14 + 27) / 55)
exe 'vert 1resize ' . ((&columns * 202 + 126) / 253)
exe '2resize ' . ((&lines * 37 + 27) / 55)
exe 'vert 2resize ' . ((&columns * 202 + 126) / 253)
exe 'vert 3resize ' . ((&columns * 50 + 126) / 253)
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
let s:l = 1 - ((0 * winheight(0) + 7) / 14)
if s:l < 1 | let s:l = 1 | endif
exe s:l
normal! zt
1
normal! 0
wincmd w
argglobal
if bufexists("~/tank/super/More-Organized-Trek/Songs/Unnecessary-refmt.scd") | buffer ~/tank/super/More-Organized-Trek/Songs/Unnecessary-refmt.scd | else | edit ~/tank/super/More-Organized-Trek/Songs/Unnecessary-refmt.scd | endif
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
215
normal! zo
220
normal! zo
245
normal! zo
253
normal! zo
255
normal! zo
326
normal! zo
328
normal! zo
332
normal! zo
334
normal! zo
let s:l = 230 - ((120 * winheight(0) + 18) / 37)
if s:l < 1 | let s:l = 1 | endif
exe s:l
normal! zt
230
normal! 025|
wincmd w
argglobal
if bufexists("~/tank/super/More-Organized-Trek/Songs/\[sclang]") | buffer ~/tank/super/More-Organized-Trek/Songs/\[sclang] | else | edit ~/tank/super/More-Organized-Trek/Songs/\[sclang] | endif
setlocal fdm=expr
setlocal fde=FoldParts(v:lnum)
setlocal fmr={{{,}}}
setlocal fdi=#
setlocal fdl=1
setlocal fml=1
setlocal fdn=20
setlocal nofen
let s:l = 4009 - ((38 * winheight(0) + 26) / 52)
if s:l < 1 | let s:l = 1 | endif
exe s:l
normal! zt
4009
normal! 0
wincmd w
exe '1resize ' . ((&lines * 14 + 27) / 55)
exe 'vert 1resize ' . ((&columns * 202 + 126) / 253)
exe '2resize ' . ((&lines * 37 + 27) / 55)
exe 'vert 2resize ' . ((&columns * 202 + 126) / 253)
exe 'vert 3resize ' . ((&columns * 50 + 126) / 253)
tabedit ~/tank/super/nine-note-scale.scd
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
setlocal fde=FoldParts(v:lnum)
setlocal fmr={{{,}}}
setlocal fdi=#
setlocal fdl=0
setlocal fml=1
setlocal fdn=20
setlocal fen
silent! normal! zE
let s:l = 1 - ((0 * winheight(0) + 26) / 52)
if s:l < 1 | let s:l = 1 | endif
exe s:l
normal! zt
1
normal! 027|
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
let s:l = 245 - ((84 * winheight(0) + 26) / 52)
if s:l < 1 | let s:l = 1 | endif
exe s:l
normal! zt
245
normal! 09|
tabedit ~/tank/super/Library/synthdefs/reedy.scd
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
exe 'vert 1resize ' . ((&columns * 202 + 126) / 253)
exe 'vert 2resize ' . ((&columns * 50 + 126) / 253)
argglobal
setlocal fdm=expr
setlocal fde=FoldParts(v:lnum)
setlocal fmr={{{,}}}
setlocal fdi=#
setlocal fdl=0
setlocal fml=1
setlocal fdn=20
setlocal nofen
let s:l = 31 - ((30 * winheight(0) + 26) / 52)
if s:l < 1 | let s:l = 1 | endif
exe s:l
normal! zt
31
normal! 05|
wincmd w
argglobal
if bufexists("~/tank/super/More-Organized-Trek/Songs/\[sclang]") | buffer ~/tank/super/More-Organized-Trek/Songs/\[sclang] | else | edit ~/tank/super/More-Organized-Trek/Songs/\[sclang] | endif
setlocal fdm=expr
setlocal fde=FoldParts(v:lnum)
setlocal fmr={{{,}}}
setlocal fdi=#
setlocal fdl=1
setlocal fml=1
setlocal fdn=20
setlocal nofen
let s:l = 4197 - ((25 * winheight(0) + 26) / 52)
if s:l < 1 | let s:l = 1 | endif
exe s:l
normal! zt
4197
normal! 0
wincmd w
exe 'vert 1resize ' . ((&columns * 202 + 126) / 253)
exe 'vert 2resize ' . ((&columns * 50 + 126) / 253)
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
let s:l = 1 - ((0 * winheight(0) + 26) / 52)
if s:l < 1 | let s:l = 1 | endif
exe s:l
normal! zt
1
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
let s:l = 159 - ((158 * winheight(0) + 26) / 52)
if s:l < 1 | let s:l = 1 | endif
exe s:l
normal! zt
159
normal! 09|
tabnext 6
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
