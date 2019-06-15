#!/usr/bin/env 

echo '--------------- ZSH ...'
rm -rf ~/.oh-my-zsh
sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)" 
sudo chsh -s /bin/zsh
