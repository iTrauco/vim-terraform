" terraform.vim - basic vim/terraform integration
" Maintainer: HashiVim <https://github.com/hashivim>

if exists('b:did_ftplugin') || v:version < 700 || &compatible || !executable('terraform')
  finish
endif
let b:did_ftplugin = 1

let s:cpo_save = &cpoptions
set cpoptions&vim

if !exists('g:terraform_align')
  let g:terraform_align = 0
endif

if !exists('g:terraform_remap_spacebar')
  let g:terraform_remap_spacebar = 0
endif

if !exists('g:terraform_fold_sections')
  let g:terraform_fold_sections = 0
endif

if g:terraform_align && exists(':Tabularize')
  inoremap <buffer> <silent> = =<Esc>:call <SID>terraformalign()<CR>a
  function! s:terraformalign()
    let p = '^.*=[^>]*$'
    if exists(':Tabularize') && getline('.') =~# '^.*=' && (getline(line('.')-1) =~# p || getline(line('.')+1) =~# p)
      let column = strlen(substitute(getline('.')[0:col('.')],'[^=]','','g'))
      let position = strlen(matchstr(getline('.')[0:col('.')],'.*=\s*\zs.*'))
      Tabularize/=/l1
      normal! 0
      call search(repeat('[^=]*=',column).'\s\{-\}'.repeat('.',position),'ce',line('.'))
    endif
  endfunction
endif

if g:terraform_fold_sections
  function! TerraformFolds()
    let thisline = getline(v:lnum)
    if match(thisline, '^resource') >= 0
      return '>1'
    elseif match(thisline, '^provider') >= 0
      return '>1'
    elseif match(thisline, '^module') >= 0
      return '>1'
    elseif match(thisline, '^variable') >= 0
      return '>1'
    elseif match(thisline, '^output') >= 0
      return '>1'
    elseif match(thisline, '^data') >= 0
      return '>1'
    elseif match(thisline, '^terraform') >= 0
      return '>1'
    elseif match(thisline, '^locals') >= 0
      return '>1'
    else
      return '='
    endif
  endfunction
  setlocal foldmethod=expr
  setlocal foldexpr=TerraformFolds()
  setlocal foldlevel=1

  function! TerraformFoldText()
    let foldsize = (v:foldend-v:foldstart)
    return getline(v:foldstart).' ('.foldsize.' lines)'
  endfunction
  setlocal foldtext=TerraformFoldText()
endif

" Re-map the space bar to fold and unfold
if get(g:, 'terraform_remap_spacebar', 1)
  "inoremap <space> <C-O>za
  nnoremap <space> za
  onoremap <space> <C-C>za
  vnoremap <space> zf
endif

" Set the commentstring
if exists('g:terraform_commentstring')
    let &l:commentstring=g:terraform_commentstring
else
    setlocal commentstring=#%s
endif
setlocal formatoptions-=t

if !exists('g:terraform_fmt_on_save') || !filereadable(expand('%:p'))
  let g:terraform_fmt_on_save = 0
endif

function! s:commands(A, L, P)
  return [
  \ 'apply',
  \ 'console',
  \ 'destroy',
  \ 'env',
  \ 'fmt',
  \ 'get',
  \ 'graph',
  \ 'import',
  \ 'init',
  \ 'output',
  \ 'plan',
  \ 'providers',
  \ 'push',
  \ 'refresh',
  \ 'show',
  \ 'taint',
  \ 'untaint',
  \ 'validate',
  \ 'version',
  \ 'workspace',
  \ '0.12checklist',
  \ 'debug',
  \ 'force-unlock',
  \ 'state'
  \ ]
endfunction

augroup terraform
  autocmd!
  autocmd BufEnter *
        \ command! -nargs=+ -complete=customlist,s:commands Terraform execute '!terraform '.<q-args>. ' -no-color'
  autocmd BufEnter * command! -nargs=0 TerraformFmt call terraform#fmt()
  if get(g:, 'terraform_fmt_on_save', 1)
    autocmd BufWritePre *.tf call terraform#fmt()
    autocmd BufWritePre *.tfvars call terraform#fmt()
  endif
augroup END

let b:undo_ftplugin = 'setlocal formatoptions<'

let &cpoptions = s:cpo_save
unlet s:cpo_save
