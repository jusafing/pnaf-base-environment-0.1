#!/bin/bash

##############################################################################
##  	Tcpxtract installer v0.1
##	by Javier S.A. (2014)
## 	jusafing@gmail.com
##############################################################################
##############################################################################

##############################################################################
## VARIABLES
INSTALLER_VERSION="0.1"
INSTALLER_WORKDIR="`pwd`"
INSTALLER_LOGFILE="/root/pnaf-0.1/install.log"
INSTALLER_ID="22/21 TCPXTRACT"
INSTALLER_USER=`whoami`
INSTALLER_NARG=$#
INSTALLER_ARG1=$1
INSTALLER_ARG2=$2
#----------------------------------------------------------------------------#
TCPXTRACT_VERSION="1.0.1"
TCPXTRACT_DIR="/pnaf/dem/pasm/tcpxtract"
TCPXTRACT_WEB="https://github.com/gamelinux/tcpxtract.git"
TCPXTRACT_SRCFILE="$INSTALLER_WORKDIR/build/tcpxtract.tar.gz"

##############################################################################
start()
{
    local fname="start"
    logMsg "$fname" "Installing Tcpxtract"
    userInstall
    checkArgs
    installTcpxtract
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
    else                                                                        
        echo "ERROR: Invalid syntax"                                            
        echo "Syntax:  # ./install.sh [--debian|--gentoo]"                         
        exitInstall                                                               
    fi                                                                            
}     
##############################################################################
installTcpxtract()
{
    local fname="installTcpxtract"
    logMsg "$fname" "Installing Tcpxtract"
    logMsg "$fname" "Using Tcpxtract source file $TCPXTRACT_SRCFILE"
    cleanDir "$TCPXTRACT_DIR"
    execCmd "cd $INSTALLER_WORKDIR/build"
    cleanDir "tcpxtract-$TCPXTRACT_VERSION"
    execCmd "tar -zxvf tcpxtract-$TCPXTRACT_VERSION.tar.gz"
    execCmd "cd tcpxtract-$TCPXTRACT_VERSION"
    execCmd "./configure --prefix=$TCPXTRACT_DIR"
    execCmd "make"
    execCmd "make install"
}
##############################################################################
start
