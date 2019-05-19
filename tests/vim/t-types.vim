" Test for different error types.  Can be called using `vim -u ...`.
"
" E: error
" W: warning
" I: info
" M: message
" S: style
" ?: no-type

let &runtimepath = expand('<sfile>:p:h:h:h') . ',' . &runtimepath
let s:sfile = expand('<sfile>')

" Use some specific colorscheme.
" let &runtimepath = expand('<sfile>:p:h') . '/colorscheme-colorish,' . &runtimepath
" set termguicolors
" colorscheme onedarkish

let s:maker = {}
function! s:maker.get_list_entries(...) abort
  let entries = [
        \ {'lnum': 3, 'type': 'E', 'text': 'error'},
        \ {'lnum': 4, 'type': 'W', 'text': 'warning'},
        \ {'lnum': 5, 'type': 'I', 'text': 'info'},
        \ {'lnum': 6, 'type': 'M', 'text': 'message'},
        \ {'lnum': 7, 'type': 'S', 'text': 'style'},
        \ {'lnum': 8, 'type': '',  'text': 'no-type'},
        \ ]
  let bufnr = bufnr('%')
  call map(entries, 'extend(v:val, {''bufnr'': bufnr})')
  return entries
endfunction

function! s:VimEnter() abort
  filetype plugin indent on
  syntax on

  exe 'edit '.s:sfile
  call neomake#Make(1, [s:maker])
endfunction

augroup test
  au VimEnter * ++nested call s:VimEnter()
augroup END

" vim: set et sw=2
