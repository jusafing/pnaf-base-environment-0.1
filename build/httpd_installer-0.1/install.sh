#!/bin/bash

##############################################################################
##  	Httpd installer v0.1
##	by Javier S.A. (2014)
## 	jusafing@gmail.com
##############################################################################
##############################################################################

##############################################################################
## VARIABLES
INSTALLER_VERSION="0.1"
INSTALLER_WORKDIR="`pwd`"
INSTALLER_LOGFILE="/root/pnaf-0.1/install.log"
INSTALLER_ID="23/23 HTTPD"
INSTALLER_USER=`whoami`
INSTALLER_NARG=$#
INSTALLER_ARG1=$1
INSTALLER_ARG2=$2
#----------------------------------------------------------------------------#
HTTPD_VERSION="2.2.27"
HTTPD_DIR="/pnaf/modules/dvm/wdve/httpd"
HTTPD_WEB="http://apache.mirror.1000mbps.com//httpd/httpd-2.2.27.tar.gz"
HTTPD_SRCFILE="$INSTALLER_WORKDIR/build/httpd-$HTTPD_VERSION.tar.gz"

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
    logMsg "$fname" "Installing Httpd version $HTTPD_VERSION"
    userInstall
    checkArgs
    installHttpd
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
    execCmd "aptitude install -y build-essential flex bison l-dev zlib1g\
	     zlib1g-dev libmagic-dev"
}

##############################################################################
installHttpd()
{
    local fname="installHttpd"
    logMsg "$fname" "Installing Httpd v$HTTPD_VERSION"
    logMsg "$fname" "Using Httpd source file $HTTPD_SRCFILE"
    execCmd "cd $INSTALLER_WORKDIR/build"
    cleanDir "httpd-$HTTPD_VERSION"
    execCmd "tar -zxvf $HTTPD_SRCFILE"
    execCmd "cd httpd-$HTTPD_VERSION"
    execCmd "./configure --prefix=$HTTPD_DIR"
    execCmd "make"
    execCmd "make install"
    execCmd "ln -s $HTTPD_DIR/bin/apachectl /etc/init.d/apache2"
}
##############################################################################
start
