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
cp env/dist/etc/modules/mod-dungeon-roguelite.conf.dist env/dist/etc/modules/mod-dungeon-roguelite.conf
cp env/dist/etc/modules/AutoBalance.conf.dist env/dist/etc/modules/AutoBalance.conf
cp env/dist/etc/modules/statbooster.conf.dist env/dist/etc/modules/statbooster.conf

#This start script will make start and stopping your server much easier! Do this.
nano /root/start.sh
#START OF SCRIPT
cd ~/azerothcore-wotlk/env/dist/bin
authserver="./authserver"
worldserver="./worldserver"

authserver_session="auth-session"
worldserver_session="world-session"

if tmux new-session -d -s $authserver_session; then
    echo "Created authserver session: $authserver_session"
else
    echo "Error when trying to create authserver session: $authserver_session"
fi

if tmux new-session -d -s $worldserver_session; then
    echo "Created worldserver session: $worldserver_session"
else
    echo "Error when trying to create worldserver session: $worldserver_session"
fi

if tmux send-keys -t $authserver_session "$authserver" C-m; then
    echo "Executed \"$authserver\" inside $authserver_session"
    echo "You can attach to $authserver_session and check the result using \"tmux attach -t $authserver_session\""
else
    echo "Error when executing \"$authserver\" inside $authserver_session"
fi

if tmux send-keys -t $worldserver_session "$worldserver" C-m; then
    echo "Executed \"$worldserver\" inside $worldserver_session"
    echo "You can attach to $worldserver_session and check the result using \"tmux attach -t $worldserver_session\""
else
    echo "Error when executing \"$worldserver\" inside $worldserver_session"
fi
#END OF SCRIPT.


#Create aliases to start the above script and simplify starting, stopping, and updating your server
nano ~/.bashrc
#scroll to the very bottom of your bashrc file by pressing PAGE DOWN or DOWN ARROW until you get to the bottom. Then paste the following from #START to #END
#START
alias wow='cd ~/azerothcore-wotlk;tmux attach -t world-session'
alias auth='cd ~/azerothcore-wotlk;tmux attach -t auth-session'
alias start='bash /root/start.sh'
alias stop='tmux kill-server'
alias compile='cd ~/azerothcore-wotlk;./acore.sh compiler all'
alias build='cd ~/azerothcore-wotlk;./acore.sh compiler build'
alias update='cd ~/azerothcore-wotlk;git pull;cd ~/azerothcore-wotlk/modules/mod-dungeon-roguelite;git pull;cd ~/azerothcore-wotlk/modules/mod-autobalance;git pull;cd ~/azerothcore-wotlk/modules/mod-statbooster;git pull'
alias confg-roguelite='nano ~/azerothcore-wotlk/env/dist/etc/modules/dungeon-roguelite.conf'
alias config-world='nano ~/azerothcore-wotlk/env/dist/etc/worldserver.conf'
alias updatemods="cd ~/azerothcore-wotlk/modules;find . -mindepth 1 -maxdepth 1 -type d -print -exec git -C {} pull \;"
#END

#CTRL+S to save then CTRL+X to exit the nano text editor. Once exited, this command will update your new bashrc file.
source ~/.bashrc

#Start your server by just typing start.
start
#Type wow to get into the world-server session where we can issue commands. On your first run, it will ask if you want to create your datebase. Type yes and wait.
wow
#To exit the "world session" screen (with the green bar across the bottom), press CTRL+B and then press D to "detatch" from the tmux session. (This is the technical term for what's going on.) 
#If this is too difficult to remember or too cumbersome, you can always just close the putty terminal here.
#CTRL+B, D
#And you can see the auth server any time it's running by typing. This isn't really necessary for most cases and you shouldn't need to go in here.
#auth

#SET YOUR REALM NAME.  
sudo mysql -u root
use acore_auth
UPDATE realmlist SET name = 'Dungeon Roguelite' WHERE id = 1;

#ALLOW LOGIN TO YOUR SERVER. MANDATORY
#IF YOU SKIP THIS, YOU WILL NOT BE ABLE TO LOG IN AND WILL GET STUCK ON THE REALM LIST
#THIS IP MUST MATCH YOURS. CAN BE CHANGED ANY TIME. USE YOUR IPs INSTEAD OF MINE BELOW
#To get your LAN IP, type in terminal: ip a
UPDATE realmlist SET address = '192.168.137.48' WHERE id = 1;

#Allow functions (used for atomically getting next perissitent group id
#SET GLOBAL log_bin_trust_function_creators = ON; #doesnt seem to be necessary on debian

exit;

#DO PORTFORWARDING FOR YOUR SERVER. MANDATORY
#Port forward these to the IP address of your wotlk server:
#3724 TCP AUTH
#8085 TCP WORLD

BEFORE YOU LOG IN, YOU MUST CREATE AN ACCOUNT. 
YOU CAN ONLY CREATE WOW ACCOUNTS FROM THE WORLD SESSION TERMINAL
-----------------------------------------------------------------------------------------------------------------------
Creating your first account and giving him GM powers

Start your server again if it isn't up:
start

Create your account from the world session tmux terminal:
wow

#account create <username> <password>

account create nirv banana

#if you want to make your character a GM
account set gmlevel nirv 3 -1

Now is a good time to download the WotLK 3.3.5a client. I advise you extract this 17GB folder to your fastest drive. Download it here:
https://www.chromiecraft.com/en/downloads/

#if you need to change password. 
account set password nirv banana2 banana2

#set realmlist 192.168.4.70