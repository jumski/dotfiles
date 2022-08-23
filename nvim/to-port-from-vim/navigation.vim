
" rails.vim navcommands
"
"
autocmd User Rails Rnavcommand admin app/admin/ -suffix=.rb
autocmd User Rails Rnavcommand factory spec/factories/ -suffix=.rb
" autocmd User Rails Rnavcommand job app/jobs/ -suffix=_job.rb
autocmd User Rails Rnavcommand override app/overrides/ -suffix=.rb
autocmd User Rails Rnavcommand serializer app/serializers/ -suffix=_serializer.rb
autocmd User Rails Rnavcommand support spec/support/ -suffix=.rb
autocmd User Rails Rnavcommand shared spec/shared/ -suffix=.rb
autocmd User Rails Rnavcommand uploader app/uploaders/ -suffix=.rb
autocmd User Rails Rnavcommand observer app/models/ -suffix=_observer.rb

" backbone related
autocmd User Rails Rnavcommand jcollection app/assets/javascripts/collections/ -glob=**/* -suffix=.js.coffee
autocmd User Rails Rnavcommand jmodel app/assets/javascripts/models/ -glob=**/* -suffix=.js.coffee
autocmd User Rails Rnavcommand jview app/assets/javascripts/views/ -glob=**/* -suffix=.js.coffee
autocmd User Rails Rnavcommand jrouter app/assets/javascripts/routers/ -glob=**/* -suffix=.js.coffee
autocmd User Rails Rnavcommand jspec js_spec/ -glob=**/* -suffix=.js.coffee
autocmd User Rails Rnavcommand template app/assets/templates/ -glob=**/* -suffix=.hamlc
"
" " project specific
" autocmd User Rails Rnavcommand jspec vendor/backbone-widgets/spec/ -glob=**/* -suffix=.js.coffee
" autocmd User Rails Rnavcommand widget vendor/backbone-widgets/src/ -glob=**/* -suffix=.js.coffee

"
"
"
"
" rails vim speed mappings
"map <leader>rm :Rmodel<Space>
"map <leader>rc :Rcontroller<Space>
"map <leader>rv :Rview<Space>
"map <leader>rh :Rhelper<Space>
"map <leader>rf :Rfactory<Space>
"map <leader>rsr :Rserializer<Space>
"map <leader>rsp :Rspec<Space>
"map <leader>rsu :Rsupport<Space>
"
"map <leader>rjj :Rjavascript<Space>
"map <leader>rjm :Rjmodel<Space>
"map <leader>rjv :Rjview<Space>
"map <leader>rjc :Rjcollection<Space>
"map <leader>rjr :Rjrouter<Space>
"map <leader>rjs :Rjspec<Space>
"map <leader>rt :Rtemplate<Space>
"map <leader>rw :Rwidget<Space>
"
"map <leader>rjo :Rjob<Space>
"map <leader>ra :Radmin<Space>
"map <leader>ru :Ruploader<Space>
"map <leader>rst :Rstylesheet<Space>
