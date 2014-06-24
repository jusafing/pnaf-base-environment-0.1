#!/bin/bash

##############################################################################
##  	Netsniff installer v0.1
##	by Javier S.A. (2014)
## 	jusafing@gmail.com
##############################################################################
##############################################################################

##############################################################################
## VARIABLES
INSTALLER_VERSION="0.1"
INSTALLER_WORKDIR="`pwd`"
INSTALLER_LOGFILE="/home/audit/paf-0.1/install.log"
INSTALLER_ID="8/20 NETSNIFF"
INSTALLER_USER=`whoami`
INSTALLER_NARG=$#
INSTALLER_ARG1=$1
INSTALLER_ARG2=$2
#----------------------------------------------------------------------------#
NETSNIFF_DIR="/paf/dem/pasm/netsniff"
NETSNIFF_WEB="https://github.com/netsniff-ng/netsniff-ng.git"
NETSNIFF_SRCFILE="$INSTALLER_WORKDIR/build/netsniff-ng.tar.gz"

##############################################################################
start()
{
    local fname="start"
    logMsg "$fname" "Installing Netsniff"
    userInstall
    checkArgs
    installNetsniff
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
    cmd="aptitude install -y ccache flex bison libnl-3-dev libnl-genl-3-dev libgeoip-dev libnetfilter-conntrack-dev libncurses5-dev liburcu-dev libnacl-dev libpcap-dev zlib1g-dev libcli-dev libnet1-dev" 
    execCmd "$cmd"
}
##############################################################################
installNetsniff()
{
    local fname="installNetsniff"
    logMsg "$fname" "Installing Netsniff"
    logMsg "$fname" "Using Netsniff source file $NETSNIFF_SRCFILE"
    cleanDir "$NETSNIFF_DIR"
    execCmd  "mkdir -p $NETSNIFF_DIR/sbin/"
    execCmd  "mkdir -p $NETSNIFF_DIR/share/man/man8/"
    execCmd "cd $INSTALLER_WORKDIR/build"
    cleanDir "netsniff-ng"
    execCmd "tar -zxvf netsniff-ng.tar.gz"
    execCmd "cd netsniff-ng"
    installDir=`echo $NETSNIFF_DIR | sed 's/\//\\\\\//g'`              
    logMsg "$fname" "Installation dir $installDir on Makefile" 
    execCmd "./configure"
    execCmd "sed -i -r 's/(PREFIX) \?=.*/\1 \?= $installDir/' Makefile"
    execCmd "make"
    execCmd "make install"
}
##############################################################################
start
