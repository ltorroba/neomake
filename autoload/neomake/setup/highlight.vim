let s:defined_fg_hl_groups = 0

" Setup base highlight groups for foreground attributes.
function! neomake#setup#highlight#define_fg_highlight_groups() abort
    for [group, fg_from] in items({
                \ 'NeomakeFgError': 'Error',
                \ 'NeomakeFgWarning': 'Todo',
                \ 'NeomakeFgInfo': 'Question',
                \ 'NeomakeFgMessage': 'ModeMsg'
                \ })
        call s:define_with_accent_color(group, fg_from)
    endfor
endfunction

" Helper function to define default highlight for a:group (e.g.
" "Neomake%sSign"), using fg from another highlight, abd given background.
function! neomake#setup#highlight#define_derived_highlights(group_format, bg) abort
    if !s:defined_fg_hl_groups
        call neomake#setup#highlight#define_fg_highlight_groups()
        let s:defined_fg_hl_groups = 1
    endif
    for [type, fg_from] in items({
                \ 'Error': 'NeomakeFgError',
                \ 'Warning': 'NeomakeFgWarning',
                \ 'Info': 'NeomakeFgInfo',
                \ 'Message': 'NeomakeFgMessage'
                \ })
        let group = printf(a:group_format, type)
        call s:define_derived_highlight_group(group, fg_from, a:bg)
    endfo
endfunction

function! s:define_derived_highlight_group(group, fg_from, bg) abort
    let [ctermbg, guibg] = a:bg
    let bg = 'ctermbg='.ctermbg.' guibg='.guibg

    " NOTE: fg falls back to "Normal" always, not bg (for e.g. "SignColumn")
    " inbetween.
    " Ensure that we're not using bg as fg (as with gotham
    " colorscheme, issue https://github.com/neomake/neomake/pull/659).
    let ctermfg = neomake#utils#GetHighlight(a:fg_from, 'fg')
    if ctermfg !=# 'NONE' && ctermfg ==# ctermbg
        " XXX
        echom string([a:group, a:fg_from, ctermfg, ctermbg])
        echoerr 'should not happen 1?!'
        let ctermfg = neomake#utils#GetHighlight(a:fg_from, 'bg')
        " let cterm_reverse = ' cterm=reverse'
    " else
    "     let cterm_reverse = ''
    endif
    let guifg = neomake#utils#GetHighlight(a:fg_from, 'fg#')
    if guifg !=# 'NONE' && guifg ==# guibg
        echom string([a:group, a:fg_from, guifg, guibg])
        echoerr 'should not happen 2?!'
        let guifg = neomake#utils#GetHighlight(a:fg_from, 'bg#')
        " let gui_reverse = ' gui=reverse'
    " else
    "     let gui_reverse = ''
    endif

    exe 'hi '.a:group.'Default ctermfg='.ctermfg.' guifg='.guifg.' '.bg
    if !neomake#utils#highlight_is_defined(a:group)
        exe 'hi link '.a:group.' '.a:group.'Default'
    endif
endfunction

function! neomake#setup#highlight#define_highlights() abort
    call neomake#setup#highlight#define_fg_highlight_groups()

    if g:neomake_place_signs
        call neomake#signs#DefineHighlights()
    endif
    if get(g:, 'neomake_highlight_columns', 1)
                \ || get(g:, 'neomake_highlight_lines', 0)
        call neomake#highlights#DefineHighlights()
    endif
    call neomake#virtualtext#DefineHighlights()
endfunction

function! s:define_with_accent_color(group, from) abort
    if synIDattr(synIDtrans(hlID(a:from)), 'bold')
        let use = 'fg'
    elseif index(['0', '7', '8', '15', 'NONE'], neomake#utils#GetHighlight(a:from, 'fg')) != -1
        let use = 'bg'
    else
        let use = 'fg'
    endif
    " TODO: keep cterm and gui attributes?
    let ctermfg = neomake#utils#GetHighlight(a:from, use)
    let guifg = neomake#utils#GetHighlight(a:from, use.'#')
    " echom printf('hi %s ctermfg=%s guifg=%s', a:group, ctermfg, guifg)
    exe printf('hi %s ctermfg=%s guifg=%s', a:group, ctermfg, guifg)
endfunction
