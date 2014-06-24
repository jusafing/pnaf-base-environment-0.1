#!/bin/bash

##############################################################################
##  	p0f installer v0.1
##	by Javier S.A. (2014)
## 	jusafing@gmail.com
##############################################################################
##############################################################################

##############################################################################
## VARIABLES
INSTALLER_VERSION="0.1"
INSTALLER_WORKDIR="`pwd`"
INSTALLER_LOGFILE="/home/audit/paf-0.1/install.log"
INSTALLER_ID="10/20 P0F"
INSTALLER_USER=`whoami`
INSTALLER_NARG=$#
INSTALLER_ARG1=$1
INSTALLER_ARG2=$2
#----------------------------------------------------------------------------#
BUILD_VERSION_P0F="3.06b"
P0F_DIR="/paf/dem/pasm/p0f"
P0F_WEB="http://lcamtuf.coredump.cx/p0f3/releases/p0f-3.06b.tgz"
# Github https://github.com/p0f/p0f.git
P0F_SRCFILE="$INSTALLER_WORKDIR/build/p0f-$P0F_BUILD_VERSION.tar.gz"

##############################################################################
start()
{
    local fname="start"
    logMsg "$fname" "Installing p0f IDS version $BUILD_VERSION_P0F"
    userInstall
    checkArgs
    installp0f
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
    execCmd "aptitude install -y cmake make gcc g++ flex bison libpcap-dev\
	     libssl-dev python-dev swig zlib1g-dev libmagic-dev gawk"
}
##############################################################################
installp0f()
{
    local fname="installp0f"
    logMsg "$fname" "Installing p0f v$BUILD_VERSION_P0F"
    logMsg "$fname" "Compiling with SSL support"
    logMsg "$fname" "Reference: http://bit.ly/1hkSmFM"
    logMsg "$fname" "Using p0f source file $P0F_SRCFILE"
    cleanDir "$P0F_DIR"
    execCmd "cd $INSTALLER_WORKDIR/build"
    cleanDir "p0f-$BUILD_VERSION_P0F"
    execCmd "tar -zxvf p0f-$BUILD_VERSION_P0F.tar.gz"
    execCmd "cd p0f-$BUILD_VERSION_P0F"
    execCmd "make"
    execCmd "mkdir -p $P0F_DIR/bin"
    execCmd "mkdir -p $P0F_DIR/src"
    execCmd "cp -r * $P0F_DIR/src"    
    execCmd "cp $P0F_DIR/src/p0f $P0F_DIR/bin"
    execCmd "cp $P0F_DIR/src/p0f.fp $P0F_DIR/"
}
##############################################################################
start
