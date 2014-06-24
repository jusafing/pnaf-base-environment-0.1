#!/bin/bash

##############################################################################
##  	Chaosreader installer v0.1
##	by Javier S.A. (2014)
## 	jusafing@gmail.com
##############################################################################
##############################################################################

##############################################################################
## VARIABLES
INSTALLER_VERSION="0.1"
INSTALLER_WORKDIR="`pwd`"
INSTALLER_LOGFILE="/root/pnaf-0.1/install.log"
INSTALLER_ID="12/23 CHAOSREADER"
INSTALLER_USER=`whoami`
INSTALLER_NARG=$#
INSTALLER_ARG1=$1
INSTALLER_ARG2=$2
#----------------------------------------------------------------------------#
BUILD_VERSION_CHAOSREADER="2"
CHAOSREADER_DIR="/pnaf/modules/dpm/dpie/chaosreader"
CHAOSREADER_WEB="https://github.com/firnsy/chaosreader2/archive/master.zip"
CHAOSREADER_SRCFILE="$INSTALLER_WORKDIR/chaosreader"

##############################################################################
start()
{
    local fname="start"
    logMsg "$fname" "Installing Chaosreader$BUILD_VERSION_CHAOSREADER"
    userInstall
    checkArgs
    installChaosreader
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
installChaosreader()
{
    local fname="installChaosreader"
    logMsg "$fname" "Installing Chaosreader v$BUILD_VERSION_CHAOSREADER"
    logMsg "$fname" "Using Chaosreader source file $CHAOSREADER_SRCFILE"
    execCmd "mkdir -p $CHAOSREADER_DIR"
    execCmd "mkdir -p $CHAOSREADER_DIR/bin"
    execCmd "cd $INSTALLER_WORKDIR"
    execCmd "cp $CHAOSREADER_SRCFILE $CHAOSREADER_DIR/bin"
    execCmd "chmod 755 $CHAOSREADER_DIR/bin/*"
    execCmd "cp README.md $CHAOSREADER_DIR"
}
##############################################################################
start
