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

#optional override config files
cp env/dist/etc/authserver.conf.dist env/dist/etc/authserver.conf
cp env/dist/etc/worldserver.conf.dist env/dist/etc/worldserver.conf
cp ~/azerothcore-wotlk/env/dist/etc/modules/dungeon-roguelite.conf.dist ~/azerothcore-wotlk/env/dist/etc/modules/dungeon-roguelite.conf
cp ~/azerothcore-wotlk/env/dist/etc/modules/autobalance.conf.dist ~/azerothcore-wotlk/env/dist/etc/modules/autobalance.conf
cp ~/azerothcore-wotlk/env/dist/etc/modules/statbooster.conf.dist ~/azerothcore-wotlk/env/dist/etc/modules/statbooster.conf
