echo 
echo "MASTERCOIN - Masternode updater"
echo 
echo "Welcome to the MASTERCOIN Masternode update script."
echo

cd ~
sudo killall -9 mastercoind
sudo rm -rdf /usr/bin/mastercoind 
cd

mkdir -p MASTERCOINONE_TMP
cd MASTERCOINONE_TMP
wget https://github.com/MasterCoinOne/MasterCoinNew/releases/download/v1.0/MasterCoin-1.0.0-x86_64-pc-linux-gnu.zip
sudo chmod 775 MasterCoin-1.0.0-x86_64-pc-linux-gnu.zip 
unzip MasterCoin-1.0.0-x86_64-pc-linux-gnu.zip 

sudo rm -f MasterCoin-1.0.0-x86_64-pc-linux-gnu.zip
sudo mv  * /usr/bin

cd ~
rm -d MASTERCOINONE_TMP

mkdir -p ~/.mastercoin
cp ~/.MasterCoinV2/mastercoin.conf ~/.mastercoin

echo "rpcallowip=127.0.0.1" >> ~/.mastercoin/mastercoin.conf
echo "rpcport=17301" >> ~/.mastercoin/mastercoin.conf

mastercoind

echo "Your masternode is now updated!"
