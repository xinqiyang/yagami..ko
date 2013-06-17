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

# Check if user is root
if [ $(id -u) != "0" ]; then
    echo "Error: You must be root to run this script, use sudo sh $0"
    exit 1
fi

clear
echo "========================================================================="
echo "***** Starting DDoS-Defender version 2.1.0 Unstall: " `date`
echo "***** Unstalling pre-requisites"
echo "========================================================================="

#delete  main directory
if [ -d /usr/local/DDos ];then
echo "This folder exist,Will be rebuild..."
rm -rf /usr/local/DDos
fi

if [ `cat ~/.bash_profile|grep 'DDos'|wc -l` -ne 0 ];then
sed -i '/PATH=$PATH:\/usr\/local\/DDos\/sbin/d' /root/.bash_profile
fi

if [ `cat /etc/rc.local|grep 'DDos'|wc -l` -ne 0 ];then
sed -i '/\/usr\/local\/DDos\/sbin\/ddosDer start/d' /etc/rc.local
fi

echo "====================================================="
echo "Clean Done! ^_^"
echo "=====================================================" 
