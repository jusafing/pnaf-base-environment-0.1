#!/bin/bash

##############################################################################
##  	Xplico installer v0.1
##	by Javier S.A. (2014)
## 	jusafing@gmail.com
##############################################################################
##############################################################################

##############################################################################
## VARIABLES
INSTALLER_VERSION="0.1"
INSTALLER_WORKDIR="`pwd`"
INSTALLER_LOGFILE="/root/pnaf-0.1/install.log"
INSTALLER_ID="10/21 XPLICO"
INSTALLER_USER=`whoami`
INSTALLER_NARG=$#
INSTALLER_ARG1=$1
INSTALLER_ARG2=$2
#----------------------------------------------------------------------------#
XPLICO_VERSION="1.1.0"
XPLICO_DIR="/pnaf/dem/pasm/xplico"
XPLICO_WEB=""
XPLICO_SRCFILE="$INSTALLER_WORKDIR/build/xplico-$XPLICO_VERSION.tar.gz"

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
    local local fname="exitInstall"
    logMsg "$fname" 
    logMsg "$fname" "The installation script has been terminated with errors"
    echo
    echo   "$fname" "The installation script has been terminated with errors"
    exit 1
}

##############################################################################
execCmd()                                                                       
{                                                                               
    local local fname="execCmd"                                                             
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
    local local fname="cleanDir"                                                            
    if [ -d $1 ]; then                                                          
        logMsg "$fname" "Cleaning existing directory $1"                        
        execCmd "rm -rf $1"
    fi                                                                          
} 
##############################################################################
start()
{
    local local fname="start"
    logMsg "$fname" "Installing Xplico IDS version $XPLICO_VERSION"
    userInstall
    checkArgs
    installXplico
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
    local local fname="installAptPackages"
    logMsg "$fname" "Installing APT packages"
    execCmd "aptitude install -y build-essential flex bison libpcre3 sqlite3 \
	     libpcre3-dbg libpcre3-dev autoconf automake libsqlite3-dev libtool\
	     libpcap-dev libnet1-dev libyaml-0-2 libyaml-dev zlib1g zlib1g-dev \
	     libmagic-dev libcap-ng-dev pkg-config"
}

##############################################################################
installXplico()
{
    local local fname="installXplico"
    logMsg "$fname" "Installing Xplico v$XPLICO_VERSION"
    logMsg "$fname" "Using Xplico source file $XPLICO_SRCFILE"
    execCmd "cd $INSTALLER_WORKDIR/build"
    cleanDir "nDPI"
    execCmd "tar -zxvf nDPI.tar.gz"
    execCmd "cd nDPI"
    execCmd "./configure"
    execCmd "make"
    execCmd "cd $INSTALLER_WORKDIR/build"
    cleanDir "xplico-$XPLICO_VERSION"
    execCmd "tar -zxvf $XPLICO_SRCFILE"
    execCmd "cd xplico-$XPLICO_VERSION"
    installDir=`echo $XPLICO_DIR | sed 's/\//\\\\\//g'`                       
    logMsg "$fname" "Installation dir $installDir on Makefile"                  
    execCmd "sed -i -r 's/(DEFAULT_DIR) =.*/\1 = $installDir/' Makefile" 
    execCmd "make install"
    if [ -e /opt/xplico ]; then
	execCmd "rm /opt/xplico"
    elif [ -L /opt/xplico ]; then
	execCmd "rm /opt/xplico"
    fi
    execCmd "ln -s $XPLICO_DIR /opt/xplico"
}
##############################################################################

##############################################################################
start
