#! /bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

# Make sure only root can run our script
function rootness(){
    if [[ $EUID -ne 0 ]]; then
       echo "Error:This script must be run as root,please run 'sudo su' first." 1>&2
       exit 1
    fi
}
 
 
function checkos(){
    if [ -f /etc/redhat-release ];then
        OS='centos'
    elif [ ! -z "`cat /etc/issue | grep bian`" ];then
        OS='debian'
    elif [ ! -z "`cat /etc/issue | grep Ubuntu`" ];then
        OS='ubuntu'
    else
        echo "Not support OS, Please change OS and retry!"
        exit 1
    fi
}


function checkenv(){
    if [[ $OS = "centos" ]]; then
        yum upgrade -y
        yum update -y
        yum install wget curl ntpdate -y
    else
        apt-get -y upgrade
        apt-get -y update
        apt-get -y install wget curl ntpdate
    fi
}


function install_v2ray(){
    rootness
    checkos
    checkenv
    ntpdate time.nist.gov
    bash <(curl https://raw.githubusercontent.com/1715173329/v2ray-easy-to-use/master/websocket-tls-website/install-release.sh)
    rm "/etc/v2ray/config.json" -rf 
    wget -qO /etc/v2ray/config.json "https://raw.githubusercontent.com/1715173329/v2ray-easy-to-use/master/websocket-tls-website/config.json" 
    service v2ray restart
    bash <(curl https://raw.githubusercontent.com/1715173329/v2ray-easy-to-use/master/websocket-tls-website/caddy-install.sh)
    rm -rf /usr/local/caddy/Caddyfile
    wget -qO /usr/local/caddy/Caddyfile "https://raw.githubusercontent.com/1715173329/v2ray-easy-to-use/master/websocket-tls-website/Caddyfile" 
    cd /root/
    mkdir /v2rayindexpage
    cd /v2rayindexpage
    wget https://raw.githubusercontent.com/1715173329/v2ray-easy-to-use/master/websocket-tls-website/webpage.zip
    unzip webpage.zip
    rm -rf webpage.zip
    clear
    echo -e "请输入您的域名："
    read url
    echo ""${url#*"://"}"" > /tmp/caddyaddress.txt
    sed -i "s#/##g" "/tmp/caddyaddress.txt"
    Address=$(cat "/tmp/caddyaddress.txt")
    rm -rf /tmp/caddyaddress.txt
    echo -e "您的域名为: ${Address}"
    let PORT=$RANDOM+10000
    UUID=$(cat /proc/sys/kernel/random/uuid)
    hostname=$(hostname)
    sed -i "s/PathUUID/${UUID2}/g" "/usr/local/caddy/Caddyfile"
    sed -i "s/PathUUID/${UUID2}/g" "/etc/v2ray/config.json"
    sed -i "s/V2RayListenPort/${PORT}/g" "/etc/v2ray/config.json"
    sed -i "s/UserUUID/${UUID}/g" "/etc/v2ray/config.json"
    sed -i "s/V2RayListenPort/${PORT}/g" "/usr/local/caddy/Caddyfile"
    sed -i "s#V2rayAddress#https://${Address}#g" "/usr/local/caddy/Caddyfile"
    service v2ray restart && service caddy restart
    cd /root/
    clear
    echo -e "\n这是您的连接信息："
	echo -e "别名(Remarks)：${hostname}"
	echo -e "地址(Address)：${Address}"
	echo -e "端口(Port):443"
	echo -e "用户ID(ID):${UUID}"
	echo -e "额外ID(AlterID):100"
	echo -e "加密方式(Security)：none"
	echo -e "传输协议(Network）：ws"
	echo -e "伪装类型(Type）：none"
	echo -e "伪装域名/其他项：/fuckgfw_gfwmotherfuckingboom/${UUID2}"
	echo -e "底层传输安全(TLS)：tls"
}
    install_v2ray
