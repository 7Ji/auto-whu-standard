# auto-whu-standard
Auto WHU for standard linux distribution i.e. Arch Linux, Ubuntu, etc. With systemd in mind, this version is much more concise than [the openwrt version](https://github.com/7Ji/auto-whu-openwrt).  
为标准Linux发行版（如Arch Linux，Ubuntu，Debian等）准备的武大校园网自动登录管理程序，依托于systemd进行后台管理和自动启动以及日志记录，如果计划于在OpenWrt上使用，请使用依赖于SysVinit、和procd等的[OpenWrt版本](https://github.com/7Ji/auto-whu-openwrt)

如何使用？
--
0、确保你使用的发行版的init为systemd，你可以用以下命令确定
````
systemctl --version
````
1、确保curl、sed、grep和bash已安装且grep支持-oP参数，curl支持-d参数，（部分系统可能只内置了不支持这些参数的busybox版，如果发现不支持，那么你应当安装对应的完整版）你可以用以下命令确定
````
curl --help
grep --help
sed --version
bash --version
````
2、下载auto-whu.sh并将之放置到/usr/sbin/下，并为之增加执行权限，（亦可以手动复制文本并创建此文件）
````
wget https://raw.githubusercontent.com/7Ji/auto-whu-standard/main/auto-whu.sh -O /usr/sbin/auto-whu.sh
chmod +x /usr/sbin/auto-whu.sh
````
3、下载auto-whu.service与auto-whu.timer，将之放到/etc/systemd/system/下（亦可以手动复制文本并创建此文件）
````
wget https://raw.githubusercontent.com/7Ji/auto-whu-standard/main/auto-whu.service -O /etc/systemd/system/auto-whu.service
wget https://raw.githubusercontent.com/7Ji/auto-whu-standard/main/auto-whu.timer -O /etc/systemd/system/auto-whu.timer
````
4、下载auto-whu.conf，将之放到/etc/下（亦可以手动复制文本并创建此文件）：
````
wget https://raw.githubusercontent.com/7Ji/auto-whu-standard/main/auto-whu.conf -O /etc/auto-whu.conf
````
5、参照auto-whu.conf.sample，对auto-whu.conf进行修改
````
vi /etc/auto-whu.conf
````
6、启动auto-whu的自动启动
````
systemctl enable --now auto-whu.timer
````
