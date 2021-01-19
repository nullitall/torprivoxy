#!/bin/bash
#need sudo privileges with current user
#need tor and privoxy installed on linux machine
#run this script like sh multitor.sh 10(replacing the number with as many tor instances as you want)

#removes old data folder and kills tor processes
sudo rm -rf data privoxy
sudo killall tor privoxy
set -e

base_socks_port=9050
base_http_port=8118

# Create data directory if it doesn't exist
if [ ! -d "data" ]; then
        mkdir "data"
        mkdir "privoxy"
fi

TOR_INSTANCES="$1"
#change to your ip address
ip_addr=192.168.1.15
for i in $(seq $TOR_INSTANCES)
do
        j=$((i+1))
        socks_port=$((base_socks_port+i))
        http_port=$((base_http_port+i))
        #INSERT YOUR DIRECTORY USERNAME IN ALL THE PLACES IT SAYS USERNAME
        if [ ! -d "/home/USERNAME/data/tor$i" ]; then
                echo "Creating directory data/tor$i"
                mkdir "/home/USERNAME/data/tor$i"
                echo "Creating directory privoxy/privoxy$i"
                mkdir "privoxy/privoxy$i"
                echo "listen-address $ip_addr:$http_port" >> privoxy/privoxy$i/config 
                echo "forward-socks5 / 		localhost:$socks_port	." >> privoxy/privoxy$i/config 
                echo "forward			192.168.*.*/	.">> privoxy/privoxy$i/config
                echo "forward			10.*.*.*/	.">> privoxy/privoxy$i/config 
                echo "forward			127.*.*.*/	.">> privoxy/privoxy$i/config 
        fi
        #runs tor instances based off sh multitor.sh 5 
        tor --RunAsDaemon 1 --CookieAuthentication 0 --PidFile /home/USERNAME/data/tor$i.pid --SocksPort $socks_port --DataDirectory /home/USERNAME/data/tor$i
	      #runs privoxy instances based on how many tor servers
        sudo privoxy --pidfile privoxy$i.pid privoxy/privoxy$i/config
	      
done
