#!/bin/bash

##############################################################################
##  	Nftracker installer v0.1
##	by Javier S.A. (2014)
## 	jusafing@gmail.com
##############################################################################
##############################################################################

##############################################################################
## VARIABLES
INSTALLER_VERSION="0.1"
INSTALLER_WORKDIR="`pwd`"
INSTALLER_LOGFILE="/home/audit/paf-0.1/install.log"
INSTALLER_ID="9/20 NFTRACKER"
INSTALLER_USER=`whoami`
INSTALLER_NARG=$#
INSTALLER_ARG1=$1
INSTALLER_ARG2=$2
#----------------------------------------------------------------------------#
NFTRACKER_DIR="/paf/dem/pasm/nftracker"
NFTRACKER_WEB="https://github.com/gamelinux/nftracker.git"
NFTRACKER_SRCFILE="$INSTALLER_WORKDIR/build/nftracker.tar.gz"

##############################################################################
start()
{
    local fname="start"
    logMsg "$fname" "Installing Nftracker"
    userInstall
    checkArgs
    installNftracker
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
installAptPackages()
{
    local fname="installAptPackages"
    logMsg "$fname" "Installing APT packages"
    execCmd "aptitude install -y libpcap-dev libpcre3-dev python-docutils" 
}
##############################################################################
installNftracker()
{
    local fname="installNftracker"
    logMsg "$fname" "Installing Nftracker"
    logMsg "$fname" "Using Nftracker source file $NFTRACKER_SRCFILE"
    cleanDir "$NFTRACKER_DIR"
    execCmd "cd $INSTALLER_WORKDIR/build"
    cleanDir "nftracker"
    execCmd "tar -zxvf nftracker.tar.gz"
    execCmd "cd nftracker/src"
    execCmd "make"
    execCmd "cp -r ../../nftracker $NFTRACKER_DIR"
    execCmd "mkdir $NFTRACKER_DIR/bin/"
    execCmd "mv $NFTRACKER_DIR/src/nftracker $NFTRACKER_DIR/bin/" 
}
##############################################################################
start
