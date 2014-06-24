#!/bin/bash

##############################################################################
##  	Dnsdump installer v0.1
##	by Javier S.A. (2014)
## 	jusafing@gmail.com
##############################################################################
##############################################################################

##############################################################################
## VARIABLES
INSTALLER_VERSION="0.1"
INSTALLER_WORKDIR="`pwd`"
INSTALLER_LOGFILE="/home/sensor/paf-0.1/install.log"
INSTALLER_ID="DNSDUMP"
INSTALLER_USER=`whoami`
INSTALLER_NARG=$#
INSTALLER_ARG1=$1
INSTALLER_ARG2=$2
#----------------------------------------------------------------------------#
LIBPCAP_VERSION="1.5.3"
DNSDUMP_VERSION="1.11"
DNSDUMP_DIR="/paf/dem/pasm/dnsdump"
DNSDUMP_RULESDIR='/usr/local/dnsdump'
DNSDUMP_WEB="http://www.rtfm.com/dnsdump/dnsdump-0.9b3.tar.gz"
DNSDUMP_SRCFILE="$INSTALLER_WORKDIR/build/dnsdump-$DNSDUMP_VERSION.tar.gz"

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
    logMsg "$fname" "Installing Dnsdump IDS version $DNSDUMP_VERSION"
    userInstall
    checkArgs
    installDnsdump
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
    execCmd "aptitude install -y flex bison libpcre3 libpcre3-dbg libpcre3-dev\
	     build-essential autoconf automake libtool libpcap-dev libnet1-dev\
	     libyaml-0-2 libyaml-dev zlib1g zlib1g-dev libcap-ng-dev libssl-dev\
	     libnet-pcap-perl"
}

##############################################################################
installDnsdump()
{
    local fname="installDnsdump"
    logMsg "$fname" "Installing Dnsdump v$DNSDUMP_VERSION"
    logMsg "$fname" "Using Dnsdump source file $DNSDUMP_SRCFILE"
    cleanDir "$DNSDUMP_DIR"
    execCmd "mkdir -p $DNSDUMP_DIR/bin"
    execCmd "cd $INSTALLER_WORKDIR/build"
    cleanDir "dnsdump-$DNSDUMP_VERSION"
    execCmd "tar -zxvf $DNSDUMP_SRCFILE"
    execCmd "cp dnsdump-$DNSDUMP_VERSION $DNSDUMP_DIR/bin"
    logMsg  "$fname" "Installing CPAN modules dependencies..."
    execCmd "perl -MCPAN -e 'install Net::Packet'"
    execCmd "perl -MCPAN -e 'install Net::DNS'"
}
##############################################################################
##############################################################################
start
