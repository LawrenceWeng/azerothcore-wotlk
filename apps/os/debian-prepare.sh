#Change root password
sudo passwd
#don't make the password too large. we'll be typing it frequently

#Allow logging in SSH as root directly (you can only SSH into user accounts if you do not change this)
sed -ie '0,/#PermitRootLogin prohibit-password/s/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && service sshd restart

#Faster boot
nano /etc/default/grub
#GRUB_DEFAULT=1
#GRUB_TIMEOUT=0
update-grub

#get git and install dependencies for azerothcore and modules
apt update && apt upgrade -y
apt install git curl unzip sudo tmux -y
cd ~/
git clone https://github.com/LawrenceWeng/azerothcore-wotlk.git --branch=master
cd ~/azerothcore-wotlk/modules

# get access to private repositories
read -p "Enter your GitHub token: " GH_TOKEN
git clone https://LawrenceWeng:${GH_TOKEN}@github.com/LawrenceWeng/mod-dungeon-roguelite.git --branch=master
git clone https://github.com/LawrenceWeng/mod-autobalance.git --branch=master
git clone https://github.com/LawrenceWeng/mod-statbooster.git --branch=master

# use azerothcore's script to install dependencies
cd ~/azerothcore-wotlk
./acore.sh install-deps

#build / compile azerothcore
./acore.sh compiler all

#stop mysql from logging to binary logs
nano /etc/mysql/mysql.conf.d/mysqld.cnf
#COPY AND PASTE AT THE BOTTOM OF THE FILE
bind-address            = 0.0.0.0
mysqlx-bind-address     = 0.0.0.0
disable_log_bin
#END OF PASTE
sudo systemctl restart mysql

#Now create the "acore" mysql user. 
#SEVERAL PEOPLE FOR SOME REASON HAVE HAD A PROBLEM WITH THIS. I DO NOT KNOW WHY, BUT YOU NEED TO CREATE THIS DATABASE ACCOUNT OR YOUR SERVER WILL NOT START. 
sudo mysql -u root

DROP USER IF EXISTS 'acore'@'localhost';
CREATE USER 'acore'@'localhost' IDENTIFIED BY 'acore' WITH MAX_QUERIES_PER_HOUR 0 MAX_CONNECTIONS_PER_HOUR 0 MAX_UPDATES_PER_HOUR 0;
GRANT ALL PRIVILEGES ON * . * TO 'acore'@'localhost' WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON `acore_playerbots` . * TO 'acore'@'localhost' WITH GRANT OPTION;
CREATE DATABASE IF NOT EXISTS `acore_world` DEFAULT CHARACTER SET UTF8MB4 COLLATE utf8mb4_unicode_ci;
CREATE DATABASE IF NOT EXISTS `acore_characters` DEFAULT CHARACTER SET UTF8MB4 COLLATE utf8mb4_unicode_ci;
CREATE DATABASE IF NOT EXISTS `acore_auth` DEFAULT CHARACTER SET UTF8MB4 COLLATE utf8mb4_unicode_ci;
GRANT ALL PRIVILEGES ON `acore_world` . * TO 'acore'@'localhost' WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON `acore_characters` . * TO 'acore'@'localhost' WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON `acore_auth` . * TO 'acore'@'localhost' WITH GRANT OPTION;
exit;

# get client data
cd ~/azerothcore-wotlk
./acore.sh client-data

# cp config files
cp env/dist/etc/authserver.conf.dist env/dist/etc/authserver.conf
cp env/dist/etc/worldserver.conf.dist env/dist/etc/worldserver.conf
cp ~/azerothcore-wotlk/env/dist/etc/modules/dungeon-roguelite.conf.dist ~/azerothcore-wotlk/env/dist/etc/modules/dungeon-roguelite.conf
cp ~/azerothcore-wotlk/env/dist/etc/modules/autobalance.conf.dist ~/azerothcore-wotlk/env/dist/etc/modules/autobalance.conf
cp ~/azerothcore-wotlk/env/dist/etc/modules/statbooster.conf.dist ~/azerothcore-wotlk/env/dist/etc/modules/statbooster.conf
