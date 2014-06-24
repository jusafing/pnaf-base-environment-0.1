#!/bin/bash

##############################################################################
##  	Suricata installer v0.1
##	by Javier S.A. (2014)
## 	jusafing@gmail.com
##############################################################################
##############################################################################

##############################################################################
## VARIABLES
INSTALLER_VERSION="0.1"
INSTALLER_WORKDIR="`pwd`"
INSTALLER_LOGFILE="/root/pnaf-0.1/install.log"
INSTALLER_ID="3/23 SURICATA"
INSTALLER_USER=`whoami`
INSTALLER_NARG=$#
INSTALLER_ARG1=$1
INSTALLER_ARG2=$2
#----------------------------------------------------------------------------#
LIBPCAP_VERSION="1.5.3"
SURICATA_VERSION="2.0.1"
SURICATA_DIR="/pnaf/modules/dpm/idse/suricata"
SURICATA_RULESDIR='/usr/local/suricata'
SURICATA_LOGDIR='/usr/local/suricata'
SURICATA_LIBJANSSON_LIB="/usr/lib/i386-linux-gnu/"
SURICATA_LIBJANSSON_INC="/usr/include/"
SURICATA_WEB="http://www.openinfosecfoundation.org/download/suricata-2.0.tar.gz"
SURICATA_SRCFILE="$INSTALLER_WORKDIR/build/suricata-$SURICATA_VERSION.tar.gz"

##############################################################################
##############################################################################
logMsg()
{
    msg="[`date \"+%Y%m%d-%H:%M:%S\"`] $INSTALLER_ID [$1] - $2"                 
    echo $msg                                              
    echo $msg >> $INSTALLER_LOGFILE 
}
##############################################################################
exitInstall()
{
    local fname="exitInstall"
    logMsg "$fname" 
    logMsg "$fname" "The installation script has been terminated with errors"
    echo
    echo   "$fname" "The installation script has been terminated with errors"
    exit 1
}

##############################################################################
execCmd()                                                                       
{                                                                               
    local fname="execCmd" 
    eval $1 &>> $INSTALLER_LOGFILE.exec
    if [ $? -ne 0 ]; then                                                       
        logMsg "$fname" "ERROR: Execution of ($1)"                              
        exitInstall                                                             
    else                                                                        
        logMsg "$fname" " OK ... $1"
    fi                                                                          
}   
##############################################################################
userInstall()
{
    if [ $INSTALLER_USER != "root" ]; then
	echo
	echo "##############################################"
	echo "ERROR: You must be root to execute this script"
	echo "##############################################"
	echo 
	exitInstall
    fi
}
##############################################################################  
cleanDir()                                                                      
{                                                                               
    local fname="cleanDir"
    if [ -d $1 ]; then                                                          
        logMsg "$fname" "Cleaning existing directory $1"                        
        execCmd "rm -rf $1"
    fi                                                                          
} 
##############################################################################
start()
{
    local fname="start"
    logMsg "$fname" "Installing Suricata IDS version $SURICATA_VERSION"
    userInstall
    checkArgs
    installSuricata
}
##############################################################################
checkArgs()                                                                     
{                                                                               
    local fname="checkArgs"                                                     
    if [ "$INSTALLER_ARG1" == "--debian" ]; then                                
        installAptPackages                                                      
    elif [ "$INSTALLER_ARG1" == "--gentoo" ]; then                              
        logMsg "$fname" "Skipping dependencies installation."                   
        # This should be changed on independent installations.                  
        # Skipping due to all dependencies were already installed by            
        # PAF main installer. Reinstall deps would take a lot of time           
    else                                                                        
        echo "ERROR: Invalid syntax"                                            
        echo "Syntax:  # ./install.sh [--debian|--gentoo]"
        exitInstall
    fi
}     
##############################################################################
installAptPackages()
{
    local fname="installAptPackages"
    logMsg "$fname" "Installing APT packages"
    execCmd "aptitude install -y build-essential flex bison libpcre3 
	     libpcre3-dbg libpcre3-dev libyaml-dev autoconf automake libtool\
	     libpcap-dev libnet1-dev libyaml-0-2 libyaml-dev zlib1g zlib1g-dev\
	     libmagic-dev libcap-ng-dev pkg-config libnetfilter-queue-dev\
	     libnetfilter-queue1 libnfnetlink-dev libnfnetlink0 libjansson4\
	     libjansson-dev"
}

##############################################################################
installSuricata()
{
    local fname="installSuricata"
    logMsg "$fname" "Installing Suricata v$SURICATA_VERSION"
    logMsg "$fname" "Using Suricata source file $SURICATA_SRCFILE"
    cleanDir "$SURICATA_DIR"
    execCmd "cd $INSTALLER_WORKDIR/build"
    cleanDir "libpcap-$LIBPCAP_VERSION"
    execCmd "tar -zxvf libpcap-$LIBPCAP_VERSION.tar.gz"
    execCmd "cd libpcap-$LIBPCAP_VERSION"
    execCmd "./configure"
    execCmd "make"
    execCmd "make install"
    execCmd "ldconfig"
    cleanDir "suricata-$SURICATA_VERSION"
    execCmd "tar -zxvf $SURICATA_SRCFILE"
    execCmd "cd suricata-$SURICATA_VERSION"
    if [ "$INSTALLER_ARG1" == "--debian" ]; then                                
	execCmd "./configure --prefix=$SURICATA_DIR\
	     --with-libjansson-includes=$SURICATA_LIBJANSSON_LIB\
	     --with-libjansson-libraries=$SURICATA_LIBJANSSON_LIB\
	     --enable-geoip"
    elif [ "$INSTALLER_ARG1" == "--gentoo" ]; then                              
	# Fix found on http://bit.ly/PKjojc
        execCmd "CPPFLAGS=-D_FORTIFY_SOURCE=2 ./configure\
		--prefix=$SURICATA_DIR --enable-geoip \
		--with-libjansson-includes=$SURICATA_LIBJANSSON_LIB\
		--with-libjansson-libraries=$SURICATA_LIBJANSSON_LIB"
    fi
    execCmd "make"
    execCmd "make install"
    execCmd "make install-conf"
    execCmd "make install-rules"
    execCmd "cp $SURICATA_DIR/etc/suricata/rules/*map\
	     $SURICATA_DIR/etc/suricata"
}
##############################################################################

##############################################################################
start
