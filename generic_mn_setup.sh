#!/bin/bash

NAME="bitcoingreen"
NAMEALIAS="bitg"
URL="https://github.com/bitcoingreen/bitcoingreen/releases/download/v1.3.0/bitcoingreen-1.3.0-x86_64-linux-gnu.tar.gz"
WALLETDL="bitcoingreen-1.3.0-x86_64-linux-gnu.tar.gz"
WALLETDLFOLDER="bitcoingreen-1.3.0"

RED='\033[1;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
YELLOW='\033[1;33m'
BROWN='\033[0;34m'
NC='\033[0m' # No Color

cd ~
echo "*****************************************************************************"
echo "* Ubuntu 16.04 is the recommended operating system for this install.        *"
echo "*                                                                           *"
echo "* This script will install and configure your ${NAME} Coin masternodes.     *"
echo "*****************************************************************************"
echo && echo && echo
echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
echo "!                                                 !"
echo "! Make sure you double check before hitting enter !"
echo "!                                                 !"
echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
echo && echo && echo

if [[ $(lsb_release -d) != *16.04* ]]; then
  echo -e "${RED}The operating system is not Ubuntu 16.04. You must be running on Ubuntu 16.04.${NC}"
  exit 1
fi

## Setup conf
mkdir -p ~/bin
rm ~/bin/masternode_config.txt &>/dev/null &
IP=$(curl -s4 icanhazip.com)
COUNTER=1
CONF_DIR_ONE=""
CONF_DIR=""
MNCOUNT=""
REBOOTRESTART=""
STARTNUMBER=""
re='^[0-9]+$'

echo ""
echo -e "${YELLOW}Enter coin name:${NC}"
read NAME 

while ! [[ $MNCOUNT =~ $re ]] ; do
   echo ""
   echo -e "${YELLOW}How many nodes do you want to create on this server?, followed by [ENTER]:${NC}"
   read MNCOUNT 
done

while ! [[ $STARTNUMBER =~ $re ]] ; do
   echo ""
   echo -e "${YELLOW}Enter the starting number: (e.g. 1 -> nodes will start with alias mn1, mn2,...)${NC}"
   read STARTNUMBER  
done

while ! [[ $PORT =~ $re ]] ; do
   echo ""
   PORT=""
   echo "${YELLOW}Enter starting port:${NC}"
   read PORT
done

while ! [[ $RPCPORT =~ $re ]] ; do
   echo ""
   RPCPORT=""
   echo "${YELLOW}Enter starting RPC port:${NC}"
   read RPCPORT
done

echo ""
ALIASONE=""
echo "${YELLOW}Enter blockchain wallet alias for copying chain to new wallets (e.g. mn0 or mn1).${NC}"
read ALIASONE

# check ALIASONE
CONF_DIR_ONE=~/.${NAME}_$ALIASONE
CONF_DIR_ONE_TMP=~/${NAME}_$ALIASONE_tmp

if [ -d "$CONF_DIR_ONE" ]; then
   echo -e "${RED}$ALIASONE is already used. $CONF_DIR_ONE already exists!${NC}"
   return -1
fi	

PID=`ps -ef | grep -i $ALIASONE | grep -i ${NAME}d | grep -v grep | awk '{print $2}'`

if [ -z "$PID" ]; then
   echo ""
else
   # stop wallet
   sh ~/bin/${NAME}-cli_$ALIASONE.sh stop
   sleep 1
fi

# create temp folder for blockchain
mkdir -p $CONF_DIR_ONE_TMP
cp -R $CONF_DIR_ONE/ $CONF_DIR_ONE_TMP
rm -R ${NAME}.conf
rm -R debug.log
rm -R wallet.dat
rm -R backups

# start wallet
sh ~/bin/${NAME}d_$ALIASONE.sh
sleep 1

for I in {$STARTNUMBER..$MNCOUNT}
do 
   for (( ; ; ))
   do  
      echo "************************************************************"
      echo ""
      EXIT='NO'
      ALIAS="$MN$I"
      ALIAS=${ALIAS,,}  
      echo $ALIAS

      # check ALIAS
      if [[ "$ALIAS" =~ [^0-9A-Za-z]+ ]] ; then
         echo -e "${RED}$ALIAS has characters which are not alphanumeric. Please use only alphanumeric characters.${NC}"
         EXIT='YES'
	   elif [ -z "$ALIAS" ]; then
	      echo -e "${RED}$ALIAS in empty!${NC}"
         EXIT='YES'
      else
	      CONF_DIR=~/.${NAME}_$ALIAS
	  
         if [ -d "$CONF_DIR" ]; then
            echo -e "${RED}$ALIAS is already used. $CONF_DIR already exists!${NC}"
            EXIT='YES'
         else
            # OK !!!
            break
         fi	
      fi  
   done

   if [ $EXIT == 'YES' ]
   then
      return -1
   fi

   PORT1=""
   for (( ; ; ))
   do
      PORT1=$(netstat -peanut | grep -i $PORT)

      if [ -z "$PORT1" ]; then
         break
      else
         PORT=$[PORT + 1]
         RPCPORT=$[RPCPORT + 1]
      fi
   done  
   echo "PORT "$PORT 
   echo "RPCPORT "$RPCPORT

   PRIVKEY=""
   echo ""

   CONF_FILE=${NAME}.conf
  
   # Create scripts
   echo '#!/bin/bash' > ~/bin/${NAME}d_$ALIAS.sh
   echo "${NAME}d -daemon -conf=$CONF_DIR/${NAME}.conf -datadir=$CONF_DIR "'$*' >> ~/bin/${NAME}d_$ALIAS.sh
   echo "${NAME}-cli -conf=$CONF_DIR/${NAME}.conf -datadir=$CONF_DIR "'$*' > ~/bin/${NAME}-cli_$ALIAS.sh
   chmod 755 ~/bin/${NAME}*.sh

   mkdir -p $CONF_DIR
   echo "rpcuser=user"`shuf -i 100000-10000000 -n 1` >> ${NAME}.conf_TEMP
   echo "rpcpassword=pass"`shuf -i 100000-10000000 -n 1` >> ${NAME}.conf_TEMP
   echo "rpcallowip=127.0.0.1" >> ${NAME}.conf_TEMP
   echo "rpcport=$RPCPORT" >> ${NAME}.conf_TEMP
   echo "listen=1" >> ${NAME}.conf_TEMP
   echo "server=1" >> ${NAME}.conf_TEMP
   echo "daemon=1" >> ${NAME}.conf_TEMP
   echo "logtimestamps=1" >> ${NAME}.conf_TEMP
   echo "maxconnections=256" >> ${NAME}.conf_TEMP

#   echo "addnode=51.15.198.252" >> ${NAME}.conf_TEMP 
#   echo "addnode=51.15.206.123" >> ${NAME}.conf_TEMP 
#   echo "addnode=51.15.66.234" >> ${NAME}.conf_TEMP 
#   echo "addnode=51.15.86.224" >> ${NAME}.conf_TEMP 
#   echo "addnode=51.15.89.27" >> ${NAME}.conf_TEMP 
#   echo "addnode=51.15.57.193" >> ${NAME}.conf_TEMP 
#   echo "addnode=134.255.232.212" >> ${NAME}.conf_TEMP 
#   echo "addnode=185.239.238.237" >> ${NAME}.conf_TEMP 
#   echo "addnode=185.239.238.240" >> ${NAME}.conf_TEMP 
#   echo "addnode=134.255.232.212" >> ${NAME}.conf_TEMP 
#   echo "addnode=207.148.26.77" >> ${NAME}.conf_TEMP 
#   echo "addnode=207.148.19.239" >> ${NAME}.conf_TEMP 
#   echo "addnode=108.61.103.123" >> ${NAME}.conf_TEMP 
#   echo "addnode=185.239.238.89" >> ${NAME}.conf_TEMP 
#   echo "addnode=185.239.238.92" >> ${NAME}.conf_TEMP   

   echo "" >> ${NAME}.conf_TEMP
   echo "port=$PORT" >> ${NAME}.conf_TEMP
  
   if [ -z "$PRIVKEY" ]; then
      echo ""
   else
      echo "masternode=1" >> ${NAME}.conf_TEMP
      echo "masternodeprivkey=$PRIVKEY" >> ${NAME}.conf_TEMP
   fi

   sudo ufw allow $PORT/tcp
   mv ${NAME}.conf_TEMP $CONF_DIR/${NAME}.conf
 
   # generate private key for MN
   if [ -z "$PRIVKEY" ]; then
	   PID=`ps -ef | grep -i $ALIASONE | grep -i ${NAME}d | grep -v grep | awk '{print $2}'`
	
	   if [ -z "$PID" ]; then
         # start wallet
         sh ~/bin/${NAME}d_$ALIASONE.sh  
	      sleep 1
	   fi
  
	   for (( ; ; ))
	   do  
	      echo "Please wait ..."
         sleep 1 # wait second 
	      PRIVKEY=$(~/bin/${NAME}-cli_${ALIASONE}.sh masternode genkey)
	      echo "PRIVKEY=$PRIVKEY"
	      if [ -z "$PRIVKEY" ]; then
	         echo "PRIVKEY is null"
	      else
	         break
         fi
	   done
	
	   sleep 1
	
      # stop wallet and insert mastenode key
      for (( ; ; ))
      do
         PID=`ps -ef | grep -i $ALIAS | grep -i ${NAME}d | grep -v grep | awk '{print $2}'`
         if [ -z "$PID" ]; then
            echo ""
         else
            #STOP 
            ~/bin/${NAME}-cli_$ALIAS.sh stop
         fi

         echo "Please wait ..."
         sleep 1 # wait second 
         PID=`ps -ef | grep -i $ALIAS | grep -i ${NAME}d | grep -v grep | awk '{print $2}'`
         echo "PID="$PID	
         
         if [ -z "$PID" ]; then
            sleep 1 # wait a second
            echo "masternode=1" >> $CONF_DIR/${NAME}.conf
            echo "masternodeprivkey=$PRIVKEY" >> $CONF_DIR/${NAME}.conf
            break
         fi
      done
   fi
  
   sleep 1 # wait second 
   #check if wallet is running
   PID=`ps -ef | grep -i $ALIAS | grep -i ${NAME}d | grep -v grep | awk '{print $2}'`
   echo "PID="$PID
  
   # if running stop it
   for (( ; ; ))
   do   
      if [ -z "$PID" ]; then
         echo ""
      else
         ~/bin/${NAME}-cli_$ALIAS.sh stop
         sleep 1 # wait second 
         PID=`ps -ef | grep -i $ALIAS | grep -i ${NAME}d | grep -v grep | awk '{print $2}'`
         echo "PID="$PID           
      fi	 

      if [ -z "$PID" ]; then
         cd $CONF_DIR
         echo "Copy BLOCKCHAIN"
         cp -R $CONF_DIR_ONE_TMP/ $CONF_DIR

         echo "Start wallet back"
         sh ~/bin/${NAME}d_$ALIAS.sh		
         sleep 1 # wait second
         break
      fi	       
   done 

   MNCONFIG=$(echo $ALIAS $IP:$PORT $PRIVKEY "txhash" "outputidx")
   echo $MNCONFIG >> ~/bin/masternode_config.txt
    
   COUNTER=$[COUNTER + 1]
   PORT=$[PORT + 1]
   RPCPORT=$[RPCPORT + 1]  
   sleep 1 # wait second
done

echo ""
echo -e "${YELLOW}****************************************************************"
echo -e "**Copy/Paste lines below in Hot wallet masternode.conf file**"
echo -e "**and replace txhash and outputidx with data from masternode outputs command**"
echo -e "**in hot wallet console**"
echo -e "****************************************************************${NC}"
echo -e "${RED}"
cat ~/bin/masternode_config.txt
echo -e "${NC}"
echo "****************************************************************"
echo ""