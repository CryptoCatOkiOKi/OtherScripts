# OtherScripts
Generic MasterNode Script for installing multiple nodes with one script run

wget https://raw.githubusercontent.com/CryptoCatOkiOKi/OtherScripts/master/generic_mn_setup.sh -O generic_mn_setup.sh && chmod 755 generic_mn_setup.sh && ./generic_mn_setup.sh

Instruction based on bitcoingreen
1. Install one node with offical script. This node will be used for copying blockchain to all others nodes
    * alias name mn0
    * port 16100
    * rpcport 17100
2. Start script generic script
3. Enter coin name: 
   * type bitcoingreen (coin name must be name of blockchain folder without alias)
5. How many nodes do you want to create on this server?
   * type e.g. 10 if you want to install 10 additional nodes
6. Enter the starting number:
    * type e.g. 1, means your nodes alias names will be mn1, mn2,... mn10
7. Enter starting port:
    * type 16101 (the already used one from first node +1)
8. Enter starting RPC port:
   * type 17101 (the already used one from first node +1)
9. Enter blockchain wallet alias for copying chain to new wallets
    * type mn0 as we named the first node 