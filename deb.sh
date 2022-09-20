#!/usr/bin/bash
dir="/etc/bind"
continue="Y"
index=0
#TTL="$TTL"
 mkdir $dir/zone;

read -p "delete previous data? Y/N " del
if [ $del == "Y" ] || [ $del == "y" ]
then
	 rm $dir/named.conf.local
	 rm -r $dir/zone
	 mkdir $dir/zone
	echo "deleted"
fi

addNS () {
while [ $continue == "Y" ] || [ $continue == "y" ];
do
	
	echo "$index - Name Server"
	read -p "input subdomain (ex. sub.  $domain<): " subdomain
	read -p "input host address 1st octet " oct1
	read -p "input host address 2nd octet " oct2
	hostRev="$oct2.$oct1"
	host="$oct1.$oct2"
	NS
	RNS
	read -p "continue? Y/N " continue
	index+=1
done
 systemctl restart bind9
 systemctl status bind9
echo "thanks, made with ❤ . Erik Pratama"
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
read -p "input 1st octet network prefix: " oct1;
read -p "input 2nd octet network prefix: " oct2;
#domain="de.ric.p"

#net="10.12"
net="$oct1.$oct2"
#netReverse="12.10"
netReverse="$oct2.$oct1"

zone

#d="/etc/bind/zones/db.$domain"
#db="/etc/bind/zones/reverse.db.$domain"
db "/etc/bind/zone/db.$domain"
db "/etc/bind/zone/reverse.db.$domain"
echo "success, continuing to next step..."
addNS
