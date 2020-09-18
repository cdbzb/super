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
let UltiSnipsExpandTrigger = "<s-tab>"
let NERDTreeRespectWildIgnore = "0"
let AutoPairsShortcutToggle = "<M-p>"
let NERDTreeAutoDeleteBuffer =  0 
let NERDTreeBookmarksFile = "/Users/michael/.NERDTreeBookmarks"
let UltiSnipsJumpForwardTrigger = "<tab>"
let NERDTreeMapToggleHidden = "I"
let NERDTreeWinSize = "31"
let NERDTreeMenuUp = "k"
let NERDTreeSortDirs = "1"
let NERDTreeUseTCD = "0"
let UltiSnipsRemoveSelectModeMappings =  1 
let NERDTreeMapPreview = "go"
let NERDTreeCascadeSingleChildDir = "1"
let Taboo_tabs = "3	Classes\n6	Project\n7	SynthDef\n"
let NERDTreeMapActivateNode = "o"
let NERDTreeMapCustomOpen = "<CR>"
let NERDTreeWinPos = "left"
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
cd ~/tank/super/Extensions/MW-Classes
if expand('%') == '' && !&modified && line('$') <= 1 && getline(1) == ''
  let s:wipebuf = bufnr('%')
endif
set shortmess=aoO
badd +1 ~/tank/super/More-Organized-Trek/chamber.scd
badd +24 ~/.talon/user/knausj_talon/modes/modes.talon
badd +9 ~/tank/super/Extensions/MW-Classes/XTouch.sc
badd +2 ~/scripts/pressf1.sh
badd +139 ~/.talon/user/knausj_talon/lang/sclang.talon
badd +55 ~/tank/super/vocoder.scd
badd +81 ~/tank/super/vocoder2.scd
badd +43 ~/tank/super/Extensions/SC3plugins/JoshUGens/classes/Vocoder.sc
badd +119 ~/tank/super/Extensions/MW-Classes/Item.sc
badd +1 ~/tank/super/Extensions/MW-Classes/Synths.sc
badd +216 ~/.local/share/SuperCollider/Help/Classes/Signal.txt
badd +116 ~/.local/share/SuperCollider/Help/Classes/Buffer.txt
badd +575 ~/.local/share/SuperCollider/Help/Classes/Function.txt
badd +177 ~/.local/share/SuperCollider/Help/Classes/Bus.txt
badd +60 ~/.local/share/SuperCollider/Help/Classes/RecordBuf.txt
badd +1 ~/.local/share/SuperCollider/Help/Classes/Item.txt
badd +14 ~/.talon/user/knausj_talon/text/symbols.talon
badd +23 ~/.talon/user/knausj_talon/misc/standard.talon
badd +18 ~/.local/share/SuperCollider/Help/Classes/StkShakers.txt
badd +51 ~/tank/super/Extensions/SC3plugins/StkUGens/STKclassdefs.sc
badd +1 /private/tmp/trashme.scd
badd +93 ~/.local/share/SuperCollider/Help/Classes/PlayBuf.txt
badd +330 ~/tank/super/Extensions/MW-Classes/Song-Part.sc
badd +1 ~/tank/super/Extensions/MW-Classes/plusArray.sc
badd +214 ~/.talon/user/knausj_talon/apps/vim.talon
badd +31 ~/.local/share/SuperCollider/Help/Classes/Array.txt
badd +32 ~/.talon/user/knausj_talon/code/vocabulary.py
badd +948 ~/tank/super/More-Organized-Trek/TheyUsedToThink-sketches.scd
badd +1440 ~/.local/share/SuperCollider/Help/Classes/SequenceableCollection.txt
badd +34 ~/tank/super/Extensions/miSCellaneous_lib-master/Classes/Patterns/extSequenceableCollection.sc
badd +5 ~/tank/super/song-Synthdefs.scd
badd +3 ~/.local/share/SuperCollider/Help/Classes/Pset.txt
badd +1 ~/.dotfiles/vim/snippets/lilypond.snippets
badd +31 ~/tank/super/UltiSnips/supercollider.snippets
badd +1 ~/.talon/user/knausj_talon/apps/slack.talon
badd +35 ~/.talon/user/knausj_talon/lang/talon.talon
badd +63 ~/.local/share/SuperCollider/Help/Classes/Pkey.txt
badd +322 ~/tank/super/More-Organized-Trek/Im-a-scientist.scd
badd +401 ~/tank/super/More-Organized-Trek/OLD-VERSION.scd
badd +16 ~/tank/super/Extensions/MW-Classes/myClasses.sc
badd +1 ~/.talon/user/knausj_talon/sc.py
badd +1 ~/.talon/user/knausj_talon
badd +165 ~/tank/super/Library/functions/trek.scd
badd +42 ~/tank/super/More-Organized-Trek/moon-mars.scd
badd +1 ~/tank/super/More-Organized-Trek/chamber_rewrite.scd
badd +1 ~/tank/super/More-Organized-Trek/small-chamber.scd
badd +1 ~/tank/super/Extensions/SC3plugins/JoshUGens/classes/\[sclang]
badd +1 /private/tmp/\[sclang]
badd +1 ~/.local/share/SuperCollider/Help/Classes/Scinth.txt
badd +27 ~/tank/super/Extensions/MW-Classes/Effect.sc
badd +438 ~/.local/share/SuperCollider/Help/Classes/SynthDef.txt
badd +1241 ~/.local/share/SuperCollider/Help/Classes/Object.txt
badd +53 /Applications/SuperCollider.app/Contents/Resources/SCClassLibrary/Common/Control/asDefName.sc
badd +1 ~/.local/share/SuperCollider/Help/Classes/Klang.txt
badd +63 ~/tank/super/More-Organized-Trek/international.scd
badd +49 ~/.local/share/SuperCollider/Help/Classes/StkBeeThree.txt
badd +118 ~/.local/share/SuperCollider/Help/Classes/List.txt
badd +210 ~/.vimrc
badd +25 ~/.config/nvim/init.vim
badd +86 ~/.local/share/SuperCollider/Help/Classes/Pmono.txt
badd +29 ~/.config/nvim/plugged/scnvim/plugin/supercollider.vim
badd +49 ~/.config/nvim/plugged/scnvim/autoload/scnvim.vim
badd +1 ~/.config/nvim/plugged/scnvim/syntax/classes.vim
badd +141 ~/.config/nvim/plugged/scnvim/syntax/supercollider.vim
badd +1 ~/.config/nvim/plugged/scnvim/syntax
badd +3987 /usr/local/Cellar/neovim/0.4.3/share/nvim/runtime/doc/syntax.txt
badd +1 ~/tank/super/More-Organized-Trek/\[sclang]
badd +1 ~/.config/nvim/plugged/scnvim/ftplugin/supercollider/mine.vim
badd +50 ~/.config/nvim/ftplugin/supercollider.vim
badd +29 ~/tank/super/More-Organized-Trek/Songs/small-chamber.scd
badd +1 ~/tank/super/More-Organized-Trek/panel1.scd
badd +1 ~/tank/super/More-Organized-Trek
badd +166 ~/tank/super/More-Organized-Trek/panel2.scd
badd +2 ~/tank/super/Library/synthdefs/synful3.scd
badd +1 ~/tank/super/Library/synthdefs/synful2.scd
badd +1 ~/tank/super/808-mod.scd
badd +1 ~/tank/super/voicel
badd +40 ~/tank/super/voiceLeading.scd
badd +16 ~/Library/Application\ Support/SuperCollider/Help/Classes/BMoog.txt
badd +181 ~/Library/Application\ Support/SuperCollider/Help/Classes/SynthDef.txt
badd +3 ~/Library/Application\ Support/SuperCollider/Help/Classes/Gendy4.txt
badd +101 ~/Library/Application\ Support/SuperCollider/Help/Classes/Gendy1.txt
badd +253 ~/Library/Application\ Support/SuperCollider/Help/Classes/Pproto.txt
badd +1 ~/tank/super/\[sclang]
badd +23 ~/tank/super/Extensions/MW-Classes/VoiceLeading.sc
badd +847 ~/Library/Application\ Support/SuperCollider/Help/Classes/SequenceableCollection.txt
badd +24 ~/Library/Application\ Support/SuperCollider/Help/Classes/List.txt
badd +2 ~/tank/super/Extensions/MW-Classes/beatHelper.scd
badd +1 ~/tank/super/Extensions/MW-Classes/\[sclang]
argglobal
%argdel
set stal=2
edit /private/tmp/trashme.scd
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
let s:l = 1 - ((0 * winheight(0) + 19) / 38)
if s:l < 1 | let s:l = 1 | endif
exe s:l
normal! zt
1
normal! 0
tabedit ~/.config/nvim/ftplugin/supercollider.vim
set splitbelow splitright
wincmd _ | wincmd |
vsplit
1wincmd h
wincmd _ | wincmd |
split
1wincmd k
wincmd w
wincmd w
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
exe '1resize ' . ((&lines * 12 + 20) / 41)
exe 'vert 1resize ' . ((&columns * 60 + 94) / 189)
exe '2resize ' . ((&lines * 25 + 20) / 41)
exe 'vert 2resize ' . ((&columns * 60 + 94) / 189)
exe '3resize ' . ((&lines * 19 + 20) / 41)
exe 'vert 3resize ' . ((&columns * 128 + 94) / 189)
exe '4resize ' . ((&lines * 18 + 20) / 41)
exe 'vert 4resize ' . ((&columns * 128 + 94) / 189)
argglobal
if bufexists("/usr/local/Cellar/neovim/0.4.3/share/nvim/runtime/doc/eval.txt") | buffer /usr/local/Cellar/neovim/0.4.3/share/nvim/runtime/doc/eval.txt | else | edit /usr/local/Cellar/neovim/0.4.3/share/nvim/runtime/doc/eval.txt | endif
setlocal fdm=manual
setlocal fde=0
setlocal fmr={{{,}}}
setlocal fdi=#
setlocal fdl=0
setlocal fml=1
setlocal fdn=20
setlocal nofen
silent! normal! zE
let s:l = 1 - ((0 * winheight(0) + 6) / 12)
if s:l < 1 | let s:l = 1 | endif
exe s:l
normal! zt
1
normal! 0
wincmd w
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
let s:l = 13 - ((12 * winheight(0) + 12) / 25)
if s:l < 1 | let s:l = 1 | endif
exe s:l
normal! zt
13
normal! 0
wincmd w
argglobal
if bufexists("~/.config/nvim/plugged/scnvim/syntax/classes.vim") | buffer ~/.config/nvim/plugged/scnvim/syntax/classes.vim | else | edit ~/.config/nvim/plugged/scnvim/syntax/classes.vim | endif
setlocal fdm=manual
setlocal fde=0
setlocal fmr={{{,}}}
setlocal fdi=#
setlocal fdl=0
setlocal fml=1
setlocal fdn=20
setlocal fen
silent! normal! zE
let s:l = 1 - ((0 * winheight(0) + 9) / 19)
if s:l < 1 | let s:l = 1 | endif
exe s:l
normal! zt
1
normal! 0
wincmd w
argglobal
if bufexists("~/.config/nvim/plugged/scnvim/syntax/supercollider.vim") | buffer ~/.config/nvim/plugged/scnvim/syntax/supercollider.vim | else | edit ~/.config/nvim/plugged/scnvim/syntax/supercollider.vim | endif
setlocal fdm=manual
setlocal fde=0
setlocal fmr={{{,}}}
setlocal fdi=#
setlocal fdl=0
setlocal fml=1
setlocal fdn=20
setlocal fen
silent! normal! zE
let s:l = 139 - ((0 * winheight(0) + 9) / 18)
if s:l < 1 | let s:l = 1 | endif
exe s:l
normal! zt
139
normal! 0
wincmd w
exe '1resize ' . ((&lines * 12 + 20) / 41)
exe 'vert 1resize ' . ((&columns * 60 + 94) / 189)
exe '2resize ' . ((&lines * 25 + 20) / 41)
exe 'vert 2resize ' . ((&columns * 60 + 94) / 189)
exe '3resize ' . ((&lines * 19 + 20) / 41)
exe 'vert 3resize ' . ((&columns * 128 + 94) / 189)
exe '4resize ' . ((&lines * 18 + 20) / 41)
exe 'vert 4resize ' . ((&columns * 128 + 94) / 189)
tabedit ~/tank/super/Extensions/MW-Classes/Song-Part.sc
set splitbelow splitright
wincmd _ | wincmd |
vsplit
1wincmd h
wincmd w
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
exe 'vert 1resize ' . ((&columns * 94 + 94) / 189)
exe '2resize ' . ((&lines * 19 + 20) / 41)
exe 'vert 2resize ' . ((&columns * 94 + 94) / 189)
exe '3resize ' . ((&lines * 18 + 20) / 41)
exe 'vert 3resize ' . ((&columns * 94 + 94) / 189)
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
let s:l = 290 - ((7 * winheight(0) + 19) / 38)
if s:l < 1 | let s:l = 1 | endif
exe s:l
normal! zt
290
normal! 016|
wincmd w
argglobal
if bufexists("~/tank/super/Extensions/MW-Classes/XTouch.sc") | buffer ~/tank/super/Extensions/MW-Classes/XTouch.sc | else | edit ~/tank/super/Extensions/MW-Classes/XTouch.sc | endif
setlocal fdm=manual
setlocal fde=0
setlocal fmr={{{,}}}
setlocal fdi=#
setlocal fdl=0
setlocal fml=1
setlocal fdn=20
setlocal fen
silent! normal! zE
let s:l = 18 - ((0 * winheight(0) + 9) / 19)
if s:l < 1 | let s:l = 1 | endif
exe s:l
normal! zt
18
normal! 09|
wincmd w
argglobal
if bufexists("~/tank/super/Extensions/MW-Classes/Item.sc") | buffer ~/tank/super/Extensions/MW-Classes/Item.sc | else | edit ~/tank/super/Extensions/MW-Classes/Item.sc | endif
setlocal fdm=marker
setlocal fde=0
setlocal fmr={{{,}}}
setlocal fdi=#
setlocal fdl=0
setlocal fml=1
setlocal fdn=20
setlocal fen
let s:l = 119 - ((21 * winheight(0) + 9) / 18)
if s:l < 1 | let s:l = 1 | endif
exe s:l
normal! zt
119
normal! 0
wincmd w
exe 'vert 1resize ' . ((&columns * 94 + 94) / 189)
exe '2resize ' . ((&lines * 19 + 20) / 41)
exe 'vert 2resize ' . ((&columns * 94 + 94) / 189)
exe '3resize ' . ((&lines * 18 + 20) / 41)
exe 'vert 3resize ' . ((&columns * 94 + 94) / 189)
tabedit ~/.talon/user/knausj_talon/code/vocabulary.py
set splitbelow splitright
wincmd _ | wincmd |
vsplit
1wincmd h
wincmd _ | wincmd |
split
1wincmd k
wincmd w
wincmd w
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
exe '1resize ' . ((&lines * 19 + 20) / 41)
exe 'vert 1resize ' . ((&columns * 185 + 94) / 189)
exe '2resize ' . ((&lines * 18 + 20) / 41)
exe 'vert 2resize ' . ((&columns * 185 + 94) / 189)
exe '3resize ' . ((&lines * 18 + 20) / 41)
exe 'vert 3resize ' . ((&columns * 3 + 94) / 189)
exe '4resize ' . ((&lines * 19 + 20) / 41)
exe 'vert 4resize ' . ((&columns * 3 + 94) / 189)
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
let s:l = 32 - ((7 * winheight(0) + 9) / 19)
if s:l < 1 | let s:l = 1 | endif
exe s:l
normal! zt
32
normal! 09|
wincmd w
argglobal
if bufexists("~/.talon/user/knausj_talon/sc.py") | buffer ~/.talon/user/knausj_talon/sc.py | else | edit ~/.talon/user/knausj_talon/sc.py | endif
setlocal fdm=manual
setlocal fde=0
setlocal fmr={{{,}}}
setlocal fdi=#
setlocal fdl=0
setlocal fml=1
setlocal fdn=20
setlocal fen
silent! normal! zE
let s:l = 5 - ((4 * winheight(0) + 9) / 18)
if s:l < 1 | let s:l = 1 | endif
exe s:l
normal! zt
5
normal! 017|
wincmd w
argglobal
if bufexists("~/.talon/user/knausj_talon/apps/vim.talon") | buffer ~/.talon/user/knausj_talon/apps/vim.talon | else | edit ~/.talon/user/knausj_talon/apps/vim.talon | endif
setlocal fdm=manual
setlocal fde=0
setlocal fmr={{{,}}}
setlocal fdi=#
setlocal fdl=0
setlocal fml=1
setlocal fdn=20
setlocal fen
silent! normal! zE
let s:l = 47 - ((0 * winheight(0) + 9) / 18)
if s:l < 1 | let s:l = 1 | endif
exe s:l
normal! zt
47
normal! 051|
wincmd w
argglobal
if bufexists("~/.talon/user/knausj_talon/lang/sclang.talon") | buffer ~/.talon/user/knausj_talon/lang/sclang.talon | else | edit ~/.talon/user/knausj_talon/lang/sclang.talon | endif
setlocal fdm=manual
setlocal fde=0
setlocal fmr={{{,}}}
setlocal fdi=#
setlocal fdl=0
setlocal fml=1
setlocal fdn=20
setlocal fen
silent! normal! zE
157,157fold
157
normal! zo
let s:l = 129 - ((0 * winheight(0) + 9) / 19)
if s:l < 1 | let s:l = 1 | endif
exe s:l
normal! zt
129
normal! 011|
wincmd w
exe '1resize ' . ((&lines * 19 + 20) / 41)
exe 'vert 1resize ' . ((&columns * 185 + 94) / 189)
exe '2resize ' . ((&lines * 18 + 20) / 41)
exe 'vert 2resize ' . ((&columns * 185 + 94) / 189)
exe '3resize ' . ((&lines * 18 + 20) / 41)
exe 'vert 3resize ' . ((&columns * 3 + 94) / 189)
exe '4resize ' . ((&lines * 19 + 20) / 41)
exe 'vert 4resize ' . ((&columns * 3 + 94) / 189)
tabedit ~/tank/super/Library/synthdefs/synful3.scd
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
exe 'vert 1resize ' . ((&columns * 50 + 94) / 189)
exe 'vert 2resize ' . ((&columns * 138 + 94) / 189)
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
let s:l = 2 - ((1 * winheight(0) + 19) / 38)
if s:l < 1 | let s:l = 1 | endif
exe s:l
normal! zt
2
normal! 025|
wincmd w
argglobal
if bufexists("~/tank/super/More-Organized-Trek/\[sclang]") | buffer ~/tank/super/More-Organized-Trek/\[sclang] | else | edit ~/tank/super/More-Organized-Trek/\[sclang] | endif
setlocal fdm=manual
setlocal fde=0
setlocal fmr={{{,}}}
setlocal fdi=#
setlocal fdl=0
setlocal fml=1
setlocal fdn=20
setlocal nofen
silent! normal! zE
let s:l = 1 - ((0 * winheight(0) + 19) / 38)
if s:l < 1 | let s:l = 1 | endif
exe s:l
normal! zt
1
normal! 0
wincmd w
exe 'vert 1resize ' . ((&columns * 50 + 94) / 189)
exe 'vert 2resize ' . ((&columns * 138 + 94) / 189)
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
exe '1resize ' . ((&lines * 9 + 20) / 41)
exe 'vert 1resize ' . ((&columns * 138 + 94) / 189)
exe '2resize ' . ((&lines * 28 + 20) / 41)
exe 'vert 2resize ' . ((&columns * 138 + 94) / 189)
exe 'vert 3resize ' . ((&columns * 50 + 94) / 189)
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
let s:l = 2 - ((1 * winheight(0) + 4) / 9)
if s:l < 1 | let s:l = 1 | endif
exe s:l
normal! zt
2
normal! 049|
wincmd w
argglobal
if bufexists("~/tank/super/More-Organized-Trek/panel2.scd") | buffer ~/tank/super/More-Organized-Trek/panel2.scd | else | edit ~/tank/super/More-Organized-Trek/panel2.scd | endif
setlocal fdm=expr
setlocal fde=FoldParts(v:lnum)
setlocal fmr={{{,}}}
setlocal fdi=#
setlocal fdl=2
setlocal fml=1
setlocal fdn=20
setlocal fen
1
normal! zo
162
normal! zo
168
normal! zo
182
normal! zo
let s:l = 168 - ((6 * winheight(0) + 14) / 28)
if s:l < 1 | let s:l = 1 | endif
exe s:l
normal! zt
168
normal! 0
wincmd w
argglobal
enew
file ~/tank/super/Extensions/MW-Classes/\[sclang]
setlocal fdm=marker
setlocal fde=0
setlocal fmr={{{,}}}
setlocal fdi=#
setlocal fdl=0
setlocal fml=1
setlocal fdn=20
setlocal nofen
wincmd w
exe '1resize ' . ((&lines * 9 + 20) / 41)
exe 'vert 1resize ' . ((&columns * 138 + 94) / 189)
exe '2resize ' . ((&lines * 28 + 20) / 41)
exe 'vert 2resize ' . ((&columns * 138 + 94) / 189)
exe 'vert 3resize ' . ((&columns * 50 + 94) / 189)
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
exe 'vert 1resize ' . ((&columns * 91 + 94) / 189)
exe 'vert 2resize ' . ((&columns * 97 + 94) / 189)
argglobal
setlocal fdm=expr
setlocal fde=FoldParts(v:lnum)
setlocal fmr={{{,}}}
setlocal fdi=#
setlocal fdl=3
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
let s:l = 75 - ((73 * winheight(0) + 19) / 38)
if s:l < 1 | let s:l = 1 | endif
exe s:l
normal! zt
75
normal! 01|
wincmd w
argglobal
if bufexists("~/tank/super/808-mod.scd") | buffer ~/tank/super/808-mod.scd | else | edit ~/tank/super/808-mod.scd | endif
setlocal fdm=expr
setlocal fde=FoldParts(v:lnum)
setlocal fmr={{{,}}}
setlocal fdi=#
setlocal fdl=1
setlocal fml=1
setlocal fdn=20
setlocal fen
let s:l = 19 - ((16 * winheight(0) + 19) / 38)
if s:l < 1 | let s:l = 1 | endif
exe s:l
normal! zt
19
normal! 0
wincmd w
exe 'vert 1resize ' . ((&columns * 91 + 94) / 189)
exe 'vert 2resize ' . ((&columns * 97 + 94) / 189)
tabedit ~/tank/super/Extensions/MW-Classes/VoiceLeading.sc
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
let s:l = 37 - ((31 * winheight(0) + 19) / 38)
if s:l < 1 | let s:l = 1 | endif
exe s:l
normal! zt
37
normal! 0
tabnext 3
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
