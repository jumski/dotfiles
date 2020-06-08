
orca_path=$HOME/installed/orca

if test ! -d $orca_path
  git clone https://github.com/hundredrabbits/Orca.git $orca_path
  cd $orca_path
  npm install
end
