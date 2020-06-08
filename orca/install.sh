
orca_path=$HOME/installed/orca

if [ ! -d $orca_path ]; then
  git clone https://github.com/hundredrabbits/Orca.git $orca_path
  cd $orca_path
  npm install
fi
