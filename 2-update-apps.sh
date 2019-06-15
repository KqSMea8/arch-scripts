#!/usr/bin/env 

echo '--------------- gsettings ...'
sudo gsettings set org.cinnamon.desktop.default-applications.terminal exec xfce4-terminal

echo '--------------- 需要网络 ...'

yay -S --noconfirm sublime-text-dev-imfix-fcitx 

#需要网络
yay -S --noconfirm freefilesync 

#需要网络
yay -S --noconfirm xmind

sudo rm -rf /opt/teamviewer
yay -S --noconfirm teamviewer

yay -S --noconfirm redis-desktop-manager

yay -S --noconfirm 2048-qt 

# yay -S --noconfirm wesnoth 0ad


