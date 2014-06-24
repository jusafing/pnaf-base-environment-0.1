#!/bin/bash

##############################################################################
##  	Silk installer v0.1
##	by Javier S.A. (2014)
## 	jusafing@gmail.com
##############################################################################
##############################################################################

##############################################################################
## VARIABLES
INSTALLER_VERSION="0.1"
INSTALLER_WORKDIR="`pwd`"
INSTALLER_LOGFILE="/home/audit/paf-0.1/install.log"
INSTALLER_ID="18/20 SILK"
INSTALLER_USER=`whoami`
INSTALLER_NARG=$#
INSTALLER_ARG1=$1
INSTALLER_ARG2=$2
#----------------------------------------------------------------------------#
SILK_VERSION="3.8.1"
SILK_DIR="/paf/dem/pasm/silk"
SILK_WEB="http://tools.netsa.cert.org/silk/download.html#"
SILK_SRCFILE="$INSTALLER_WORKDIR/build/silk-$SILK_VERSION.tar.gz"

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
    logMsg "$fname" "Installing Silk IDS version $SILK_VERSION"
    userInstall
    checkArgs
    installSilk
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
	     libglib2.0-dev libglib2.0-cil-dev liblzo2-dev liblzo2-2 libmysql++3\
	     libmysql++-dev libmysqlclient-dev"
}

##############################################################################
installSilk()
{
    local fname="installSilk"
    logMsg "$fname" "Installing Silk v$SILK_VERSION"
    logMsg "$fname" "Using Silk source file $SILK_SRCFILE"
    execCmd "cd $INSTALLER_WORKDIR/build"
    cleanDir "silk-$SILK_VERSION"
    execCmd "tar -zxvf $SILK_SRCFILE"
    execCmd "cd silk-$SILK_VERSION"
    execCmd "./configure --prefix=$SILK_DIR"
    execCmd "make"
    execCmd "make install"
    execCmd "ldconfig"
}
##############################################################################
start
