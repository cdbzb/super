function! CheckIsAddLineStart (lnum)
	execute "normal m'"
	call cursor(a:lnum,0)
	execute "normal %"
	let matched = match(getline("."),"addLine")
	if matched  >= 0
		execute "normal `'"
		return '>1'
	else
		execute "normal `'"
		return -1
endfunction

function! CheckIsAddLineStart2(lnum)
	"getbufline("%",a:lnum)
	call cursor(a:lnum,0)
	"call search('\[','',a:lnum)
	[endline,cursor]= searchpairpos('\[','','\]','n')
	if match(getline("."),"addLine")  >= 0
		return >1
	else
		return -1
	"let thisline=getline(lnn)
	"chom lnn
	"echom thisline
endfunction

function! FoldParts (lnum)
let thisline=getline(a:lnum)
let nextline=getline(a:lnum+1)
if match(thisline, 'P(') >= 0
	return '>2'
  elseif match(thisline, ');') == 0
	  return '<2'
  elseif match(thisline, '(') == 0
	  return '>2'
  elseif match(thisline,"addLine") >= 3
	  if match(nextline,"addLine") >= 0
		  return -1
	  else
		  return '>1'
	  endif
	  "only if NOT in a []!
  elseif match(thisline, '[') == 0
	  "is this the start of an add line?
	  "return CheckIsAddLineStart(a:lnum)
	  return '>1' 
  elseif match(nextline,"addLine") >= 4
	  return '<1'
  else 
	  return -1
  endif
endfunction
"if match(thisline, '[')>=1
"  if searchpair( the [ ) line has addLine
"if match(thisline,'].addLine')>=0
"
