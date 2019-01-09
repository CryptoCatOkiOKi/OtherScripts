#/bin/bash
echo 
echo "MASTERCOIN - Masternode updater"
echo ""
echo "Welcome to the MASTERCOIN Masternode update script."
echo "Wallet v1.0.4.0"
echo

mastercoin-cli stop

cd ~
sudo killall -9 mastercoin
sudo rm -rdf /usr/bin/mastercoind
sudo rm -rdf /usr/bin/mastercoin-cli
sudo rm -rdf /usr/bin/mastercoin-tx
cd

cd ~
mkdir -p MASTERCOIN_TMP
cd MASTERCOIN_TMP
wget https://github.com/MasterCoinOne/MasterCoinV2/releases/download/v1.0.4.0/mastercoin-1.0.4-linux.tar.gz -O mastercoin-linux.tar.gz
sudo chmod 775 mastercoin-linux.tar.gz
tar -xvzf mastercoin-linux.tar.gz

rm -f mastercoin-linux.tar.gz
sudo chmod 775 *
sudo mv mastercoin* /usr/bin

cd ~
rm -rdf MASTERCOIN_TMP

cd ~/.mastercoin
rm -R ./database
rm -R ./blocks	
rm -R ./sporks
rm -R ./chainstate
rm -R ./budget.dat	
rm -R ./fee_estimates.dat
rm -R ./mastercoind.pid
rm -R ./mncache.dat
rm -R ./mnpayments.dat
rm -R ./peers.dat

cd ~

mastercoind

echo "Your masternode wallets are now updated!"
