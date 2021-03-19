# auto-whu-standard
Auto WHU for standard linux distribution i.e. Arch Linux, Ubuntu, etc. With systemd in mind, this version is much more concise than [the openwrt version](https://github.com/7Ji/auto-whu-openwrt).  
为标准Linux发行版（如Arch Linux，Ubuntu，Debian等）准备的武大校园网自动登录管理程序，依托于systemd进行后台管理和自动启动以及日志记录，如果计划于在OpenWrt上使用，请使用依赖于SysVinit、和procd等的[OpenWrt版本](https://github.com/7Ji/auto-whu-openwrt)

如何使用？
--
### 方法一：使用systemd进行后台管理，设置开机登录，并定时进行在线认证   
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
6、若要设置开机自动验证，并定时检测在线情况，请启动auto-whu.timer的开机启动，你可以修改auto-whu.timer中的``OnUnitActiveSec=1min``项来修改检测间隔。如果不需要定时检测，则应改为启动auto-whu.service。
````
systemctl enable --now auto-whu.timer
或
systemctl enable --now auto-whu.service
````
**你不可以同时启用auto-whu.timer和auto-whu.service**
### 方法二：手动调用auto-whu.sh来进行网络认证

*除非你计划将auto-whu.sh放置入你自己的开机脚本中，或是每次进行手动验证，或是使用crontab进行定时管理，否则你不应该手动调用此脚本。如果你的Linux发行版使用的init程序为systemd，你应当使用方法一，而不是启用crontab再手动将auto-whu.sh添加到crontab中*

0、确保curl、sed、grep和bash已安装且grep支持-oP参数，curl支持-d参数，（部分系统可能只内置了不支持这些参数的busybox版，如果发现不支持，那么你应当安装对应的完整版）你可以用以下命令确定
````
curl --help
grep --help
sed --version
bash --version
````
1、下载auto-whu.sh并将之放置到/usr/sbin/下，并为之增加执行权限，（亦可以手动复制文本并创建此文件）
````
wget https://raw.githubusercontent.com/7Ji/auto-whu-standard/main/auto-whu.sh -O /usr/sbin/auto-whu.sh
chmod +x /usr/sbin/auto-whu.sh
````
2、使用命令调用auto-whu，你可以使用-h参数来查看帮助信息，auto-whu接受传入以下参数：  
``-u [username]`` 声明登录用户名，应为13位数字  
``-p [password]`` 声明密码，不应为空字段  
``-n [network]`` 声明登陆网络类型，0-3的整数，0为教育网（默认），1为电信，2为联通，3为移动  
``-m [network_manual]`` 手动声明网络名称，会覆盖``-n``参数，例如教育网在此处为``-m Internet``，除非后期网络情况有变，或你计划把auto-whu使用在非武大校园网的环境中，否则不应该使用此参数  
``-c [config file]`` 配置文件路径，将会从中读取用户名、密码、网络类型、手动网络名称、验证URL、是否检测systemd、各变量合法性等，这些选项将会被命令行提供的参数覆盖（例如，``-u``会覆盖配置文件中的``USERNAME``项）  
``-a [authorization URL]`` eportal的验证URL，只推荐非武大校园网环境的用户声明此项。如果你自行抓包发现武大校园网的验证方法有变动，你应当fork本repo后修改并提出pull request。  
``-f`` 开启前台模式，将会禁用systemd检测  
``-s`` 跳过参数合法性检查，包括禁用13位数字用户名检查，非空密码检查，0-3整数网络编号检查  
``-h``  打印帮助文本  

例如，一位用户名为 *2017300000000* 的用户，他的密码是 *123456* ，希望登录 *电信* 网络，他应该使用下面这条命令：
``/usr/sbin/auto-whu.sh -u 2017300000000 -p 123456 -n 1 -f`` 或 ``/usr/sbin/auto-whu.sh -u 2017300000000 -p 123456 -m dianixn -f``  
*(``-f``可以省略)*