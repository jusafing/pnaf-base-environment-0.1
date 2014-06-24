#!/bin/bash

##############################################################################
##  	Ssldump installer v0.1
##	by Javier S.A. (2014)
## 	jusafing@gmail.com
##############################################################################
##############################################################################

##############################################################################
## VARIABLES
INSTALLER_VERSION="0.1"
INSTALLER_WORKDIR="`pwd`"
INSTALLER_LOGFILE="/root/paf-0.1/install.log"
INSTALLER_ID="13/21 SSLDUMP"
INSTALLER_USER=`whoami`
INSTALLER_NARG=$#
INSTALLER_ARG1=$1
INSTALLER_ARG2=$2
#----------------------------------------------------------------------------#
LIBPCAP_VERSION="1.5.3"
SSLDUMP_VERSION="0.9b3"
SSLDUMP_DIR="/paf/dem/pasm/ssldump"
SSLDUMP_RULESDIR='/usr/local/ssldump'
SSLDUMP_WEB="http://www.rtfm.com/ssldump/ssldump-0.9b3.tar.gz"
SSLDUMP_SRCFILE="$INSTALLER_WORKDIR/build/ssldump-$SSLDUMP_VERSION.tar.gz"

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
    logMsg "$fname" "Installing Ssldump IDS version $SSLDUMP_VERSION"
    userInstall
    checkArgs
    installSsldump
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
    execCmd "aptitude install -y flex bison libpcre3 libpcre3-dbg libpcre3-dev \
	     build-essential autoconf automake libtool libpcap-dev libnet1-dev \
	     libyaml-0-2 libyaml-dev zlib1g zlib1g-dev libcap-ng-dev libssl-dev"
}

##############################################################################
installSsldump()
{
    local fname="installSsldump"
    logMsg "$fname" "Installing Ssldump v$SSLDUMP_VERSION"
    logMsg "$fname" "Using Ssldump source file $SSLDUMP_SRCFILE"
    execCmd "cd $INSTALLER_WORKDIR/build"
    cleanDir "libpcap-$LIBPCAP_VERSION"
    execCmd "tar -zxvf libpcap-$LIBPCAP_VERSION.tar.gz"
    execCmd "cd libpcap-$LIBPCAP_VERSION"
    execCmd "./configure --prefix=/usr/local/pcap"
    execCmd "make"
    execCmd "make install"
    execCmd "ldconfig"
    execCmd "cd $INSTALLER_WORKDIR/build"
    cleanDir "ssldump-$SSLDUMP_VERSION"
    if [ "$INSTALLER_ARG1" == "--debian" ]; then                                
	execCmd "tar -zxvf ssldump-$SSLDUMP_VERSION.tar.gz"
	execCmd "cd ssldump-$SSLDUMP_VERSION"
        execCmd "./configure --prefix=$SSLDUMP_DIR"
        if [ -L /usr/local/include/net ]; then
	    logMsg "$fname" "Deleting existing link /usr/local/include/net"
	    execCmd "rm /usr/local/include/net"
	fi
	execCmd "ln -s /usr/local/include/pcap /usr/local/include/net"
    elif [ "$INSTALLER_ARG1" == "--gentoo" ]; then                              
	# Info on ebuild file from emerge
	# * Applying ssldump-0.9-libpcap-header.patch ...
	# * Applying ssldump-0.9-configure-dylib.patch ...
	# * Applying ssldump-0.9-openssl-0.9.8.compile-fix.patch ...
	# * Applying ssldump-0.9-DLT_LINUX_SLL.patch ...
	# * Applying ssldump-0.9-prefix-fix.patch ... 
	execCmd "tar -zxvf ssldump-$SSLDUMP_VERSION-gentoo_patched.tar.gz"
	execCmd "cd ssldump-$SSLDUMP_VERSION"
        execCmd "./configure --prefix=$SSLDUMP_DIR\
		--with-pcap=/usr/local/pcap/ --build=x86_64-pc-linux-gnu\
		--host=x86_64-pc-linux-gnu"
    fi
    execCmd "make"
    execCmd "make install"
}
##############################################################################
##############################################################################
start
