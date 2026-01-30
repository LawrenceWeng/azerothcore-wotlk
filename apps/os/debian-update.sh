cd ~/

cd ~/azerothcore-wotlk/
git pull origin master

cd ~/azerothcore-wotlk/modules/mod-dungeon-roguelite
git pull origin master
cd ~/azerothcore-wotlk/modules/mod-autobalance
git pull origin master
cd ~/azerothcore-wotlk/modules/mod-statbooster
git pull origin master

# You still need to re-run the compiler
cd ~/azerothcore-wotlk/
./acore.sh compiler all
