#!/bin/bash

##############################################################################
##  	Prads installer v0.1
##	by Javier S.A. (2014)
## 	jusafing@gmail.com
##############################################################################
##############################################################################

##############################################################################
## VARIABLES
INSTALLER_VERSION="0.1"
INSTALLER_WORKDIR="`pwd`"
INSTALLER_LOGFILE="/root/paf-0.1/install.log"
INSTALLER_ID="6/21 PRADS"
INSTALLER_USER=`whoami`
INSTALLER_NARG=$#
INSTALLER_ARG1=$1
INSTALLER_ARG2=$2
#----------------------------------------------------------------------------#
PRADS_DIR="/paf/dem/pasm/prads"
PRADS_WEB="https://github.com/gamelinux/prads.git"
PRADS_SRCFILE="$INSTALLER_WORKDIR/build/prads.tar.gz"

##############################################################################
start()
{
    local fname="start"
    logMsg "$fname" "Installing Prads"
    userInstall
    checkArgs
    installPrads
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
installPrads()
{
    local fname="installPrads"
    logMsg "$fname" "Installing Prads"
    logMsg "$fname" "Using Prads source file $PRADS_SRCFILE"
    cleanDir "$PRADS_DIR"
    execCmd "cd $INSTALLER_WORKDIR/build"
    cleanDir "prads"
    execCmd "tar -zxvf prads.tar.gz"
    execCmd "cd prads"
    installDir=`echo $PRADS_DIR | sed 's/\//\\\\\//g'`              
    logMsg "$fname" "Installation dir $installDir on Makefile" 
    execCmd "sed -i -r 's/(PREFIX)=.*/\1=\"$installDir\"/' Makefile"
    execCmd "make"
    if [ "$INSTALLER_ARG1" == "--gentoo" ]; then
	execCmd "sed -i -e '/MAN/Id' Makefile"
        execCmd "sed -i -e '/DOC/Id' Makefile"
    fi
    execCmd "make install"
}
##############################################################################
start
