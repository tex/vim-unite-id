" unite source: id
" Version: 0.1.0
" Author : Milan Svoboda<milan.svoboda@centrum.cz>
" License: The MIT License

let s:save_cpo = &cpo
set cpo&vim

" Variables "{{{
call unite#util#set_default('g:unite_source_id_required_pattern_length', 3)
call unite#util#set_default('g:unite_source_id_max_candidates', 1000)
"}}}

let s:source = {
\   'action_table': {},
\   'hooks' : {},
\ }

function! s:source.hooks.on_init(args, context)
  let a:context.source__input = get(a:args, 0, '')
  if a:context.source__input == ''
    let a:context.source__input = unite#util#input('Pattern: ')
  endif
endfunction

function! s:source.gather_candidates(args, context)
    let l:result = unite#util#system(self.type . ' -R grep "' . a:context.source__input . '"')
    let l:matches = split(l:result, '\r\n\|\r\|\n')
    let l:entries = map(l:matches, 'split(v:val, ":")')
    return map(l:entries,
                \ '{
                \ "kind": "jump_list",
                \ "word": v:val[0] . " |". v:val[1] ."| ".join(v:val[2:], ":"),
                \ "action__path": v:val[0],
                \ "action__line": v:val[1],
                \ "action__text": join(v:val[2:], ":"),
                \ }')
endfunction"}}}


function! unite#sources#id#define()
  return map([{'name': 'lid', 'type': 'lid'},
  \           {'name': 'aid', 'type': 'aid'}],
  \      'extend(copy(s:source),
  \       extend(v:val, {"name": "id/" . v:val.name,
  \      "description": "candidates from " . v:val.name}))')
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
