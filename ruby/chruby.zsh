source /usr/local/share/chruby/chruby.sh
source /usr/local/share/chruby/auto.sh

chruby_default_gems=~/.chruby-default-gems/chruby-default-gems.sh
[ -f $chruby_default_gems ] && source $chruby_default_gems

export DEFAULT_GEMFILE=$ZSH/ruby/default_gems.rb
