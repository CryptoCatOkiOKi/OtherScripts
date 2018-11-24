echo 
echo "MASTERCOIN - Masternode updater"
echo 
echo "Welcome to the MASTERCOIN Masternode update script."
echo

IP=$(hostname  -I | cut -f1 -d' ')
file="/$USER/.MasterCoinV2/mastercoin.conf"

cd ~
sudo killall -9 mastercoind
sudo rm -rdf /usr/bin/mastercoind 
cd

mkdir -p MASTERCOINONE_TMP
cd MASTERCOINONE_TMP

wget https://github.com/MasterCoinOne/MasterCoinV2/releases/download/v1.0.3.0/mastercoin-1.0.3-linux.tar.gz -O mastercoin-linux.tar.gz
sudo chmod 775 mastercoin-linux.tar.gz

tar -xvzf mastercoin-linux.tar.gz
sudo chmod 755 *
sudo rm -f mastercoin-linux.tar.gz
sudo mv  * /usr/bin

cd ~
rm -d MASTERCOINONE_TMP

mkdir -p ~/.mastercoin

if [ -f "$file" ]
then
  cp ~/.MasterCoinV2/mastercoin.conf ~/.mastercoin
  sed -i 's/masternodeaddress/#masternodeaddress/g' ~/.mastercoin/mastercoin.conf
else
  sudo apt-get update
  sudo apt-get -y upgrade
  sudo apt-get -y dist-upgrade
  sudo apt-get install -y nano htop git dos2unix
  sudo apt-get install -y software-properties-common
  sudo apt-get install -y build-essential libtool autotools-dev pkg-config libssl-dev
  sudo apt-get install -y libboost-all-dev
  sudo apt-get install -y libevent-dev
  sudo apt-get install -y libminiupnpc-dev
  sudo apt-get install -y autoconf
  sudo apt-get install -y automake unzip
  sudo add-apt-repository  -y  ppa:bitcoin/bitcoin
  sudo apt-get update
  sudo apt-get install -y libdb4.8-dev libdb4.8++-dev
  sudo apt-get install libzmq5-dev

  cd /var
  sudo touch swap.img
  sudo chmod 600 swap.img
  sudo dd if=/dev/zero of=/var/swap.img bs=1024k count=2000
  sudo mkswap /var/swap.img
  sudo swapon /var/swap.img
  sudo free
  sudo echo "/var/swap.img none swap sw 0 0" >> /etc/fstab
  cd ~

  sudo apt-get install -y ufw
  sudo ufw allow ssh/tcp
  sudo ufw limit ssh/tcp
  sudo ufw logging on
  echo "y" | sudo ufw enable
  sudo ufw status

  mkdir -p ~/bin
  echo 'export PATH=~/bin:$PATH' > ~/.bash_aliases
  source ~/.bashrc
    
  echo "rpcuser=user"`shuf -i 100000-10000000 -n 1` > ~/.mastercoin/mastercoin.conf
  echo "rpcpassword=pass"`shuf -i 100000-10000000 -n 1` >> ~/.mastercoin/mastercoin.conf
  echo "listen=1" >> ~/.mastercoin/mastercoin.conf
  echo "server=1" >> ~/.mastercoin/mastercoin.conf
  echo "daemon=1" >> ~/.mastercoin/mastercoin.conf
  echo "maxconnections=256" >> ~/.mastercoin/mastercoin.conf
  echo "port=16000" >> ~/.mastercoin/mastercoin.conf
  echo "masternode=1" >> ~/.mastercoin/mastercoin.conf

  echo "Please enter the 'masternode private key' followed by [ENTER]:"
  echo "You can generate 'masternode private key' in hot wallet console with command masternode genkey"
  read MN_PRIVATE_KEY

  echo "masternodeprivkey=$MN_PRIVATE_KEY" >> ~/.mastercoin/mastercoin.conf
	
fi

echo "rpcallowip=127.0.0.1" >> ~/.mastercoin/mastercoin.conf
echo "rpcport=17301" >> ~/.mastercoin/mastercoin.conf
echo "masternodeaddress=$IP" >> ~/.mastercoin/mastercoin.conf

ufw allow 16000
ufw allow 17301

mastercoind

echo "Your masternode is now updated!"
