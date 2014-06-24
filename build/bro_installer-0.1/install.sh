#!/bin/bash

##############################################################################
##  	Bro installer v0.1
##	by Javier S.A. (2014)
## 	jusafing@gmail.com
##############################################################################
##############################################################################

##############################################################################
## VARIABLES
INSTALLER_VERSION="0.1"
INSTALLER_WORKDIR="`pwd`"
INSTALLER_LOGFILE="/root/paf-0.1/install.log"
INSTALLER_ID="3/21 BRO"
INSTALLER_USER=`whoami`
INSTALLER_NARG=$#
INSTALLER_ARG1=$1
INSTALLER_ARG2=$2
#----------------------------------------------------------------------------#
BUILD_VERSION_BRO="2.2"
BRO_DIR="/paf/dem/nsmsm/bro"
BRO_WEB="http://www.bro.org/downloads/release/bro-2.2.tar.gz"
BRO_SRCFILE="$INSTALLER_WORKDIR/build/bro-$BRO_BUILD_VERSION.tar.gz"

##############################################################################
start()
{
    local fname="start"
    logMsg "$fname" "Installing Bro IDS version $BUILD_VERSION_BRO"
    userInstall
    checkArgs
    installBro
}
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
    logMsg "$fname" "The installation process has been terminated with errors"
    echo
    echo   "$fname" "The installation process has been terminated with errors"
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
    # execCmd "emerge dev-util/cmake"
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
    execCmd "aptitude install -y cmake make gcc g++ flex bison libpcap-dev \
	     libssl-dev python-dev swig zlib1g-dev libmagic-dev gawk" 
}
##############################################################################
installBro()
{
    local fname="installBro"
    logMsg "$fname" "Installing Bro v$BUILD_VERSION_BRO"
    logMsg "$fname" "Using Bro source file $BRO_SRCFILE"
    cleanDir "$BRO_DIR"
    execCmd "cd $INSTALLER_WORKDIR/build"
    cleanDir "bro-$BUILD_VERSION_BRO"
    execCmd "tar -zxvf bro-$BUILD_VERSION_BRO.tar.gz"
    execCmd "cd bro-$BUILD_VERSION_BRO"
    execCmd "./configure --prefix=$BRO_DIR "
    execCmd "make"
    execCmd "make install"
}
##############################################################################
start
