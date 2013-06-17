#!/bin/sh
##############################################################################
# DDoS-Defender version 2.1.0 Author: Sunshine Koo <350311204@qq.com>        #
# Modfiy: guzhiqiang, 2012-2-11 11:45:30                                     #
# Blog: http://www.hit008.com , http://www.ywjt.org                          #
##############################################################################
# This program is distributed under the "Artistic License" Agreement         #
# The LICENSE file is located in the same directory as this program. Please  #
# read the LICENSE file before you make copies or distribute this program    #
##############################################################################
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin:/usr/local/DDos/sbin
export PATH

# Check if user is root
if [ $(id -u) != "0" ]; then
    echo "Error: You must be root to run this script, use sudo sh $0"
    exit 1
fi

clear
echo "========================================================================="
echo "***** Starting DDoS-Defender version 2.1.0 Quick-Install: " `date`
echo "***** Installing pre-requisites"
echo "========================================================================="

# Update iptables. 
if [ `rpm -qa|grep iptables|wc -l` -ne 0 ];then
echo "Iptables already Install."
else
yum install -y iptables*
fi

if [ `rpm -qa|grep sendmail|wc -l` -ne 0 ];then
echo "Sendmail already Install."
else
yum install -y sendmail*
fi


chkconfig --add iptables
chkconfig iptables on
echo "========================================================================="

# Create main directory
if [ -d /usr/local/DDos ];then
echo "This folder exist,Will be rebuild..."
rm -rf /usr/local/DDos
fi
mkdir -p /usr/local/DDos
mkdir -p /usr/local/DDos/sbin
mkdir -p /usr/local/DDos/conf
mkdir -p /usr/local/DDos/logs
mkdir -p /usr/local/DDos/lib
echo "Rebuild Done."

# Copy file to main directory
echo -n "Create ddos_daemon..."
cp ./ddos_daemon /usr/local/DDos/sbin/
echo "Done."
echo -n "Create ddos_flush..."
cp ./ddos_flush /usr/local/DDos/sbin/
echo "Done."
cp ./ddosDer /usr/local/DDos/sbin/
cp ./LICENSE /usr/local/DDos/
cp ./readme.txt /usr/local/DDos/
cp -rf ./lib /usr/local/DDos/
cp -rf ./conf /usr/local/DDos/
chmod -R 775 /usr/local/DDos/


# Setting $PATH
echo -n "Setting Environment variables..."
if [ `cat ~/.bash_profile|grep 'DDos'|wc -l` -eq 0 ];then
echo "PATH=$PATH:/usr/local/DDos/sbin" >> ~/.bash_profile
export PATH=$PATH:/usr/local/DDos/sbin
fi
if [ `cat /etc/rc.local|grep 'DDos'|wc -l` -eq 0 ];then
echo "/usr/local/DDos/sbin/ddosDer start" >> /etc/rc.local
fi
echo "Done."

# Start The main program
echo
more ./readme.txt
echo 
echo "====================================================="
echo "All things is OK!"
echo "Main directory:/usr/local/DDos/"
echo "Press used '/usr/local/DDos/sbin/ddosDer start' to start the firewall."
echo "ddosDer {start|stop|restart|status}"
echo "Happy to use!"
echo "====================================================="
