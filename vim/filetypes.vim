
" augroup filetypedetect
"   au! BufRead,BufNewFile *_spec.rb		set filetype=rspec.ruby
" augroup END

" syntax highlight .nghaml files
au BufRead,BufNewFile *.nghaml set filetype=haml

" force syntax highlighting on certain filetypes
au BufNewFile,BufRead Rakefile,Capfile,Guardfile,Gemfile,Vagrantfile,pryrc,*.god,*.cap,*.rake setfiletype ruby
au BufNewFile,BufRead *.erb.deface setfiletype eruby
au BufNewFile,BufRead *.haml.deface setfiletype eruby
au BufNewFile,BufRead *.json set ft=javascript
au BufNewFile,BufRead *.hamlc setfiletype haml
au BufNewFile,BufRead Dockerfile setfiletype conf
au BufNewFile,BufRead .psqlrc setfiletype sql

" force tabwidth per filetype
autocmd Filetype javascript setlocal ts=2 sts=2 sw=2

" " disable some features for certain filetypes
" au BufRead *.yml,*.json se nomodeline


