#!/usr/bin/env 

export ARCH_START_CONFIG=/opt/admins/configs

echo '--------------- update grub'
cd $ARCH_START_CONFIG && sudo cp -i /etc/default/grub  ./grub-config/grub.bak
cd $ARCH_START_CONFIG && sudo cp ./grub-config/grub   /etc/default/grub
sudo grub-mkconfig -o /boot/grub/grub.cfg

echo '--------------- Copy pacman.conf to /etc/pacman.conf'

cd $ARCH_START_CONFIG && sudo cp -i /etc/pacman.conf  ./etc/pacman.conf.bak
cd $ARCH_START_CONFIG && sudo cp ./etc/pacman.conf   /etc/pacman.conf

echo '--------------- pacman-mirrors rank ...'

sudo  pacman-mirrors -i -c China -m rank   #只留下清华源能令带宽跑满

echo '--------------- Update System ...'

sudo pacman -Syy  && sudo pacman -S --noconfirm wqy-microhei && fc-cache -fv && sudo pacman -Syyu --noconfirm && sudo pacman -S --noconfirm yay  && sudo pacman -S --noconfirm archlinuxcn-keyring 

echo '--------------- Install numlockontty ...'

yay -S --noconfirm systemd-numlockontty && sudo systemctl enable numLockOnTty.service

echo '--------------- 中文输入法 ...'
# 安装搜狗输入法#xfce桌面
sudo pacman -S --noconfirm fcitx-im fcitx-configtool fcitx-sogoupinyin 
# #配置fcitx
cd $ARCH_START_CONFIG && sudo cp -i ~/.xprofile ./.xprofile.bak
sudo echo -e "export GTK_IM_MODULE=fcitx\nexport QT_IM_MODULE=fcitx\nexport XMODIFIERS=\"@im=fcitx\"" | sudo tee ~/.xprofile

echo '--------------- 中文汉化 ...'

sudo pacman -S --noconfirm firefox-i18n-zh-cn thunderbird-i18n-zh-cn gimp-help-zh_cn  man-pages-zh_cn

echo '--------------- 禁用xorg CTRL+ALT+Fn 快捷键 ...'

mkdir -p ./etc/X11/xorg.conf.d
cd $ARCH_START_CONFIG && sudo cp -i /etc/X11/xorg.conf.d/00-keyboard.conf ./etc/X11/xorg.conf.d/00-keyboard.conf.bak
echo -e "Section \"ServerFlags\"\n Option \"DontVTSwitch\" \"on\"\nEndSection\nSection \"InputClass\"\n Identifier \"system-keyboard\"\n MatchIsKeyboard \"on\"\n Option \"XkbLayout\" \"us\"\n Option \"XkbModel\" \"pc105\"\n Option \"XKbOptions\" \"srvrkeys:none\"\nEndSection" | sudo tee /etc/X11/xorg.conf.d/00-keyboard.conf

echo '--------------- ZSH ...'
sudo pacman -S --noconfirm zsh


echo '--------------- 定时更新racaljk的hosts ...'

#定时更新racaljk的hosts（更新github #使用jetbrains激活码要在hosts中屏蔽）
mkdir -p ./etc/cron.hourly/
cd $ARCH_START_CONFIG && sudo cp -i /etc/cron.hourly/update-hosts ./etc/cron.hourly/update-hosts.bak
cd /etc/cron.hourly&&sudo touch update-hosts&&sudo chmod a+x update-hosts&&echo -e '#!/bin/sh\nLOG=/var/log/update-hosts.log\nif ping -c 1 151.101.72.133 2>&1 >/dev/null ;then\nwget https://raw.githubusercontent.com/racaljk/hosts/master/hosts -qO /tmp/hosts\necho "* $(date) * update hosts success">>$LOG\nmv /tmp/hosts /etc/hosts\nelse\necho "* $(date) * no internet access">>$LOG\nfi\necho "127.0.0.1 jmenv.tbsite.net">>/etc/hosts'|sudo tee /etc/cron.hourly/update-hosts&&sudo /etc/cron.hourly/update-hosts

echo '--------------- 卸载暂时不需要的软件 ...'
#卸载暂时不需要的软件
yay -R --noconfirm audacious audacious-plugins

echo '--------------- 文件管理器 ...'

sudo pacman -S --noconfirm  nemo nemo-python nemo-fileroller nemo-preview nemo-terminal cinnamon-translations  


echo '--------------- xfce桌面环境美化 ...'

#在 设置》外观  中选择 对应图标 （numix  或 papirus 系列 ）设置, 推荐 numix
yay -S --noconfirm numix-circle-icon-theme

sudo pacman -S --noconfirm papirus-icon-theme

#在 设置》窗口管理器  中选择 对应 主题 （arc系列）设置
sudo pacman -S --noconfirm gtk-theme-arc-git

# 解决xfce4桌面图标下字体阴影偶用这个：
xfconf-query -c xfce4-desktop -p /desktop-icons/center-text -n -t bool -s false


echo '--------------- 常用软件 ...'

sudo rm -rf /opt/google  /opt/netease/netease-cloud-music/  /opt/master-pdf-editor-5
sudo pacman -S --noconfirm wps-office ttf-wps-fonts netease-cloud-music smplayer smplayer-skins smplayer-themes google-chrome

sudo pacman -S --noconfirm vim masterpdfeditor  uget amule qbittorrent filezilla shadowsocks-qt5 deepin-screenshot
 
yay -S --noconfirm remarkable

yay -S --noconfirm bleachbit redshift

yay -S --noconfirm keepassx2 screenfetch 

sudo pacman -S --noconfirm net-tools dnsutils inetutils iproute2

yay -S --noconfirm wiznote meld goldendict easystroke catfish peek kazam zeal


echo '--------------- 编程开发 ...'

sudo rm -rf /opt/jetbrains-toolbox

yay -S --noconfirm jetbrains-toolbox visualvm subversion git

yay -S --noconfirm jre-openjdk jre-openjdk-headless jre8-openjdk jre8-openjdk-headless openjdk-doc openjdk-src openjdk8-doc openjdk8-src 

yay -S --noconfirm gcc go python nodejs npm

yay -S --noconfirm gdb codeblocks qtcreator glade

yay -S --noconfirm nginx docker
cd $ARCH_START_CONFIG && sudo cp -i /usr/lib/systemd/system/docker.service ./docker/docker.service.bak
cd $ARCH_START_CONFIG && sudo cp ./docker/docker.service /usr/lib/systemd/system/docker.service

yay -S --noconfirm mercurial bzr

echo '--------------- 虚拟机 ...'

yay -S --noconfirm virtualbox linux419-virtualbox-host-modules virtualbox-ext-oracle

echo '--------------- 有意思 ...'

yay -S --noconfirm cmatrix geogebra stellarium celestia tree

echo '--------------- 游戏 ...'

yay -S --noconfirm nethack gnome-mines sudokuki zaz 

echo '--------------- VPN ...'

yay -S --noconfirm networkmanager-l2tp networkmanager-strongswan










