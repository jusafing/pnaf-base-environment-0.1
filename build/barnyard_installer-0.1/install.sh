#!/bin/bash

##############################################################################
##  	Barnyard installer v0.1
##	by Javier S.A. (2014)
## 	jusafing@gmail.com
##############################################################################
##############################################################################

##############################################################################
## VARIABLES
INSTALLER_VERSION="0.1"
INSTALLER_WORKDIR="`pwd`"
INSTALLER_LOGFILE="/home/audit/paf-0.1/install.log"
INSTALLER_ID="4/20 BARNYARD"
INSTALLER_USER=`whoami`
INSTALLER_NARG=$#
INSTALLER_ARG1=$1
INSTALLER_ARG2=$2
#----------------------------------------------------------------------------#
BUILD_VERSION_BARNYARD="2"
BARNYARD_DIR="/paf/dem/nsmsm/barnyard"
BARNYARD_WEB="https://github.com/firnsy/barnyard2.git"
BARNYARD_SRCFILE="$INSTALLER_WORKDIR/build/barnyard-$BARNYARD_BUILD_VERSION.tar.gz"

##############################################################################
start()
{
    local fname="start"
    logMsg "$fname" "Installing Barnyard$BUILD_VERSION_BARNYARD"
    userInstall
    checkArgs
    installBarnyard
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
    cmd="aptitude install -y build-essential autoconf automake libtool libpcap-dev" 
    execCmd "$cmd"
}
##############################################################################
installBarnyard()
{
    local fname="installBarnyard"
    logMsg "$fname" "Installing Barnyard v$BUILD_VERSION_BARNYARD"
    logMsg "$fname" "Using Barnyard source file $BARNYARD_SRCFILE"
    cleanDir "$BARNYARD_DIR"
    execCmd "cd $INSTALLER_WORKDIR/build"
    cleanDir "barnyard-$BUILD_VERSION_BARNYARD"
    execCmd "tar -zxvf barnyard$BUILD_VERSION_BARNYARD.tar.gz"
    execCmd "cd barnyard$BUILD_VERSION_BARNYARD"
    execCmd "./autogen.sh"
    execCmd "./autogen.sh"
    execCmd "./configure --prefix=$BARNYARD_DIR "
    execCmd "make"
    execCmd "make install"
}
##############################################################################
start
