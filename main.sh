#!/usr/bin/bash
dir="/etc/bind"
continue="Y"
index=0
#TTL="$TTL"
 mkdir $dir/zone;

TEST () {
	if [[ $? ]]; then
		exit 1
	fi
}

resolv () {
	read -p "Input your server's IP Address : " ip
	cat <<EOF>>/etc/resolv.conf
	nameserver $ip
EOF
	/etc/init.d/networking restart
}

clear
figlet -d ./mono12.tlf -f mono12.tlf AutoDNS
#figlet -f letter github.com/rck27/autodns

read -p "delete previous data? Y/N " del
if [ $del == "Y" ] || [ $del == "y" ]
then
	 rm $dir/named.conf.local
	#TEST
	 rm -r $dir/zone
	 mkdir $dir/zone
	echo "deleted"
fi
read -p "Setup your DNS nameserver? Y/N " set
if [ $set == "Y" ] || [ $set == "y" ]; then
	resolv
fi


addNS () {
while [ $continue == "Y" ] || [ $continue == "y" ];
do
	
	echo "$index - Name Server"
	if [[ $index == 0 ]]; then
		subdomain="ns1"
		echo "the first subdomain is ns1."
	elif [[ $index != 0 ]]; then
		read -p "input subdomain (ex. web.$domain<): " subdomain

	fi
	# read -p "input subdomain (ex. sub.  $domain<): " subdomain
	read -p "input host address 1st octet (ex. xxx.xxx.1.xxx) " oct1
	read -p "input host address 2nd octet (ex. xxx.xxx.xxx.1) " oct2
	hostRev="$oct2.$oct1"
	host="$oct1.$oct2"
	NS
	RNS
	read -p "continue? Y/N " continue
	#TEST
	index+=1
done
 systemctl restart bind9
 systemctl status bind9
echo "----------------------------------"
echo "thanks, made with ❤ . Erik Pratama"
echo "https://github.com/rck27/AutoDNS"
}


RNS () {
 cat <<EOF>>/etc/bind/zone/reverse.db.$domain
$hostRev	IN	PTR	$subdomain.$domain.
EOF
}

NS () {
 cat <<EOF>>/etc/bind/zone/db.$domain
$subdomain	IN	A	$net.$host
EOF
}



zone () {
 cat <<EOF>>/etc/bind/named.conf.local
zone "$domain" {
	type master;
	file "$dir/zone/db.$domain";
};
zone "$netReverse.in-addr.arpa" {
	type master;
	file "$dir/zone/reverse.db.$domain";
};
EOF
}

db () {
 touch $1
 cat <<EOF>>$1
\$TTL    604800
@       IN      SOA     ns1.$domain. root.$domain. (
                              2         ; Serial
                         604800         ; Refresh
                          86400         ; Retry
                        2419200         ; Expire
                         604800 )       ; Negative Cache TTL
;
@       IN      NS      ns1.$domain.
EOF

}

rem() {

rm -r $dir/zone;
}



read -p "input domain (ex. deric.com): " domain;
read -p "input 1st octet network prefix: (ex. 192.xxx.xxx.xxx)  " oct1;
read -p "input 2nd octet network prefix: (ex. xxx.168.xxx.xxx) " oct2;
#domain="de.ric.p"

#net="10.12"
net="$oct1.$oct2"
#netReverse="12.10"
netReverse="$oct2.$oct1"

zone
db "/etc/bind/zone/db.$domain" A
db "/etc/bind/zone/reverse.db.$domain"

//////////////////////////////////////////////////////////////////////////////////////////////



#d="/etc/bind/zones/db.$domain"
#db="/etc/bind/zones/reverse.db.$domain"
# if [[ db "/etc/bind/zone/db.$domain" == 1 ]]; then
# 	echo "failed";
# 	exit
# fi

#TEST
echo "success, continuing to next step..."
addNS
# db "/etc/bind/zone/db.$domain"
# db "/etc/bind/zone/reverse.db.$domain"

