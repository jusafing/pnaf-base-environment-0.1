#!/bin/bash

##############################################################################
##  	Yaf installer v0.1
##	by Javier S.A. (2014)
## 	jusafing@gmail.com
##############################################################################
##############################################################################

##############################################################################
## VARIABLES
INSTALLER_VERSION="0.1"
INSTALLER_WORKDIR="`pwd`"
INSTALLER_LOGFILE="/root/paf-0.1/install.log"
INSTALLER_ID="16/21 YAF"
INSTALLER_USER=`whoami`
INSTALLER_NARG=$#
INSTALLER_ARG1=$1
INSTALLER_ARG2=$2
#----------------------------------------------------------------------------#
YAF_VERSION="2.5.0"
LIBFIXBUF_VERSION="1.4.0"
YAFMEDIATOR_VERSION="1.4.1"
MYSQL_VERSION="6.1.3-linux-glibc2.5-x86_64"
YAF_DIR="/paf/dem/pasm/yaf"
YAF_WEB="http://tools.netsa.cert.org/yaf/download.html#"
YAF_SRCFILE="$INSTALLER_WORKDIR/build/yaf-$YAF_VERSION.tar.gz"

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
    logMsg "$fname" "Installing Yaf IDS version $YAF_VERSION"
    userInstall
    checkArgs
    installYaf
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
    execCmd "aptitude install -y build-essential flex bison libpcre3 libpcre3-dbg\
	     libpcre3-dev build-essential autoconf automake libtool libpcap-dev\
	     libnet1-dev libyaml-0-2 libyaml-dev zlib1g zlib1g-dev libmagic-dev\
	     libcap-ng-dev pkg-config libnetfilter-queue-dev libnetfilter-queue1\
	     libnfnetlink-dev libnfnetlink0 libfixposix-dev libfixposix0\
	     libglib2.0-dev  libglib2.0-cil-dev liblzo2-dev liblzo2-2 libmysql++3\
	     libmysql++-dev libmysqlclient-dev"
}

##############################################################################
installYaf()
{
    local fname="installYaf"
    logMsg "$fname" "Installing Yaf v$YAF_VERSION"
    logMsg "$fname" "Using Yaf source file $YAF_SRCFILE"
    execCmd "cd $INSTALLER_WORKDIR/build"
    cleanDir "libfixbuf-$LIBFIXBUF_VERSION"
    execCmd "tar -zxvf libfixbuf-$LIBFIXBUF_VERSION.tar.gz"
    execCmd "cd libfixbuf-$LIBFIXBUF_VERSION"
    execCmd "./configure"
    execCmd "make"
    execCmd "make install"
    execCmd "ldconfig"
    execCmd "cd $INSTALLER_WORKDIR/build"
    cleanDir "yaf-$YAF_VERSION"
    execCmd "tar -zxvf $YAF_SRCFILE"
    execCmd "cd yaf-$YAF_VERSION"
    execCmd "export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig/"
    cfgopt="--with-libpcap --enable-applabel --enable-plugins"
    execCmd "./configure --prefix=$YAF_DIR $cfgopt"
    execCmd "make"
    execCmd "make install"
    execCmd "ldconfig"
    execCmd "cd $INSTALLER_WORKDIR/build"
    cleanDir "/usr/local/mysql"
    cleanDir "mysql-connector-c-$MYSQL_VERSION"
    execCmd "tar -zxvf mysql-connector-c-$MYSQL_VERSION.tar.gz"
    execCmd "mv mysql-connector-c-$MYSQL_VERSION /usr/local/mysql"
    execCmd "cd $INSTALLER_WORKDIR/build"
    cleanDir "yaf_silk_mysql_mediator-$YAFMEDIATOR_VERSION"
    execCmd "tar -zxvf yaf_silk_mysql_mediator-$YAFMEDIATOR_VERSION.tar.gz"
    execCmd "cd yaf_silk_mysql_mediator-$YAFMEDIATOR_VERSION"
    execCmd "export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig/"
    execCmd "./configure --prefix=$YAF_DIR\
	    --with-mysql=/usr/local/mysql/bin/mysql_config"
    execCmd "make"
    execCmd "make install"
    execCmd "ldconfig"
}
##############################################################################

##############################################################################
start
