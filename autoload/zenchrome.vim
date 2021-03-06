function! s:Lex() abort
  let highlights = execute('highlight')
  let highlights = substitute(highlights, '\n\s\+', ' ', 'g')
  let highlights = split(highlights, '\n')
  call map(highlights, "split(v:val, '\\s\\+xxx\\s\\+')")
  call map(highlights, "[copy(v:val)[0], split(copy(v:val)[1])]")
  return highlights
endfunction

function! s:Parse(highlight) abort
  let [group, values] = a:highlight
  let attributes = {}
  if values[0] ==# 'links'
    let attributes['links'] = values[-1]
  elseif values[0] !=# 'cleared'
    call map(values, "split(v:val, '=')")
    call map(values, "{v:val[0]: v:val[1]}")
    call map(values, "extend(attributes, v:val)")
  endif
  return {group : attributes}
endfunction

function! s:Set(group, attributes) abort
  if has_key(a:attributes, 'links')
    execute 'highlight link' a:group join(values(a:attributes))
  else
    execute 'highlight' a:group join(map(items(a:attributes), "join(v:val, '=')"))
  endif
endfunction

function! s:Sync(colors) abort
  let mismatches = filter(copy(g:Colorscheme), "a:colors[v:key] !=# v:val")
  call map(copy(mismatches), "execute('highlight' . ' ' . v:key . ' ' . 'NONE')")
  call map(copy(mismatches), "s:Set(v:key, v:val)")
endfunction

function! s:ClearUndefined(colors) abort
  let undefined = filter(keys(a:colors), "!has_key(g:Colorscheme, v:val)")
  call map(undefined, "execute('highlight' . ' ' . v:val . ' ' . 'NONE')")
endfunction

function! zenchrome#Sync() abort
  let colors = {}
  call map(s:Lex(), "extend(colors, s:Parse(v:val))")

  call s:Sync(colors)
  call s:ClearUndefined(colors)
endfunction
