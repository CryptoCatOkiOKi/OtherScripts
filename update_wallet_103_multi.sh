#/bin/bash
echo 
echo "MASTERCOIN - Masternode updater"
echo ""
echo "Welcome to the MASTERCOIN Masternode update script."
echo "Wallet v1.0.3.0"
echo

for filename in ~/bin/mastercoin-cli*.sh; do
  echo $filename stop
  sh $filename stop
  sleep 1
done

cd ~
sudo killall -9 mastercoin
sudo rm -rdf /usr/bin/mastercoind
sudo rm -rdf /usr/bin/mastercoin-cli
sudo rm -rdf /usr/bin/mastercoin-tx
cd

cd ~
mkdir -p MASTERCOIN_TMP
cd MASTERCOIN_TMP
wget https://github.com/MasterCoinOne/MasterCoinV2/releases/download/v1.0.3.0/mastercoin-1.0.3-linux.tar.gz -O mastercoin-linux.tar.gz
sudo chmod 775 mastercoin-linux.tar.gz
tar -xvzf mastercoin-linux.tar.gz

rm -f mastercoin-linux.tar.gz
sudo chmod 775 *
sudo mv mastercoin* /usr/bin

cd ~
rm -rdf MASTERCOIN_TMP

for d in ~/.mastercoin*; do
	cd $d
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
done

cd ~

for filename in ~/bin/mastercoind*.sh; do
  echo $filename
  sh $filename
  sleep 1
done

echo "Your masternode wallets are now updated!"