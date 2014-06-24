#!/bin/bash

##############################################################################
##  	Snort installer v0.1
##	by Javier S.A. (2014)
## 	jusafing@gmail.com
##############################################################################
##############################################################################

##############################################################################
## VARIABLES
INSTALLER_VERSION="0.1"
INSTALLER_WORKDIR="`pwd`"
INSTALLER_LOGFILE="/root/pnaf-0.1/install.log"
INSTALLER_ID="4/23 SNORT"
INSTALLER_USER=`whoami`
INSTALLER_NARG=$#
INSTALLER_ARG1=$1
INSTALLER_ARG2=$2
#----------------------------------------------------------------------------#
BUILD_VERSION_SNORT_STABLE="2.9.6.1"
BUILD_VERSION_SNORT_ALPHA="2.9.7.0"
BUILD_VERSION_VRT_RULES="2960"
BUILD_VERSION_SNORT_ODP="2014-02-22.187-0"
BUILD_VERSION_LIBDNET="1.11"
BUILD_VERSION_LUAJIT="2.0.2"
BUILD_VERSION_DAQ="2.0.2"
SNORT_DIR="/pnaf/modules/dpm/idse/snort"
SNORT_STABLE_DIR="$SNORT_DIR$BUILD_VERSION_SNORT_STABLE"
SNORT_ALPHA_DIR="$SNORT_DIR$BUILD_VERSION_SNORT_ALPHA"
SNORT_RULESDIR='/usr/local/snort'
SNORT_WEB="http://www.snort.org/downloads/2834"

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
start()
{
    local fname="start"
    logMsg "$fname" "Installing Snort IDS version $BUILD_VERSION_SNORT"
    userInstall
    checkArgs
    installLibdnet
    installLuajit
    installDaq
    installSnort "$BUILD_VERSION_SNORT_STABLE" "$SNORT_STABLE_DIR"
    installSnort "$BUILD_VERSION_SNORT_ALPHA"  "$SNORT_ALPHA_DIR" "openAppId"
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
    exeCmd "aptitude install -y build-essential flex bison libpcre3\
	    libpcre3-dev build-essential autoconf automake libtool libpcap-dev \
	    libnet1-dev libyaml-0-2 libyaml-dev zlib1g zlib1g-dev libmagic-dev \
	    libcap-ng-dev pkg-config libnetfilter-queue-dev\
	    libnetfilter-queue1 libnfnetlink-dev libnfnetlink0 libjansson4\
	    libjansson-dev openssl libssl-dev g++ autoconf libtool\
	    libpcap-dev libdumbnet-dev"
}
##############################################################################
installLibdnet()                                                               
{
    local fname="installLibdnet"
    logMsg "$fname" "Installing LIBDNET $BUILD_VERSION_LIBDNET..."
    execCmd "cd $INSTALLER_WORKDIR/build"
    cleanDir "libdnet-$BUILD_VERSION_LIBDNET"
    execCmd "tar -zxvf libdnet-$BUILD_VERSION_LIBDNET.tar.gz"
    execCmd "cd libdnet-$BUILD_VERSION_LIBDNET"
    if [ "$INSTALLER_ARG1" == "--debian" ]; then                                
	execCmd "./configure"
    elif [ "$INSTALLER_ARG1" == "--gentoo" ]; then                              
	execCmd "./configure \"CFLAGS=-fPIC -g -O2\" "
    fi
    execCmd "make"
    execCmd "make install"
    execCmd "ldconfig"
}
##############################################################################
installLuajit() 
{
    local fname="installLuajit"
    logMsg "$fname" "Installing LUAJIT $BUILD_VERSION_LUAJIT..."
    execCmd "cd $INSTALLER_WORKDIR/build"
    cleanDir "LuaJIT-$BUILD_VERSION_LUAJIT"
    execCmd "tar -zxvf LuaJIT-$BUILD_VERSION_LUAJIT.tar.gz"
    execCmd "cd LuaJIT-$BUILD_VERSION_LUAJIT"
    execCmd "make"
    execCmd "make install"
    execCmd "ldconfig"
}
##############################################################################
installDaq() 
{
    local fname="installDaq"
    logMsg "$fname" "Installing DAQ $BUILD_VERSION_DAQ..."
    execCmd "cd $INSTALLER_WORKDIR/build"
    cleanDir "daq-$BUILD_VERSION_DAQ"
    execCmd "tar -zxvf daq-$BUILD_VERSION_DAQ.tar.gz"
    execCmd "cd daq-$BUILD_VERSION_DAQ"
    execCmd "./configure"
    execCmd "make"
    execCmd "make install"
    execCmd "ldconfig"
}
##############################################################################
installSnort()
{
    local fname="installSnort"
    buildVersionSnort=$1   
    snortDir=$2
    addOpt="$3"
    srcFile="$INSTALLER_WORKDIR/build/snort--$buildVersionSnort.tar.gz"
    logMsg "$fname" "Installing Snort v$buildVersionSnort"
    logMsg "$fname" "Using Snort source file $srcFile"
    cleanDir "$snortDir"
    execCmd "cd $INSTALLER_WORKDIR/build"
    cleanDir "snort-$buildVersionSnort"
    execCmd "tar -zxvf snort-$buildVersionSnort.tar.gz"
    execCmd "cd snort-$buildVersionSnort"
    cmd="./configure --prefix=$snortDir --enable-sourcefire\
	 --enable-large-pcap --enable-file-inspect"
    if [ "$addOpt" == "openAppId" ]; then                                
	cmd="$cmd --enable-open-appid"
    fi
    execCmd "$cmd"
    execCmd "make"
    execCmd "make install"
    execCmd "mkdir $snortDir/lib/snort_dynamicrules"
    execCmd "mkdir $snortDir/etc"
    execCmd "cd etc"
    execCmd "cp attribute_table.dtd file_magic.conf snort.conf unicode.map\
	     classification.config gen-msg.map reference.config\
	     threshold.conf $snortDir/etc"
    logMsg "$fname" "Creating links on /usr/bin"
    execCmd "rm -rf /lib/libdnet.1"
    execCmd "ln -s /usr/local/lib/libdnet.1 /lib/"
    if [ "$addOpt" == "openAppId" ]; then                                
	execCmd "rm -rf /usr/bin/u2openappid"
	execCmd "ln -s $snortDir/bin/u2openappid /usr/bin"
	logMsg "$fname" "Installing OpenAppID"
        execCmd "cd $INSTALLER_WORKDIR/build"
        execCmd "tar zxvf snort-openappid-detectors.$BUILD_VERSION_SNORT_ODP.tgz"
	execCmd "mkdir $snortDir/openappid/"
        execCmd "mv odp $snortDir/openappid/"
	execCmd "mv $snortDir/bin/snort $snortDir/bin/snort$buildVersionSnort"
    fi

    logMsg  "$fname" "Installing VRT rules"
    execCmd "cd $INSTALLER_WORKDIR/build/snort-rules/vrt"
    execCmd "tar -zxvf snortrules-snapshot-$BUILD_VERSION_VRT_RULES.tar.gz"
    execCmd "mv rules/ $snortDir"
    execCmd "mv so_rules/ $snortDir"
    execCmd "mv preproc_rules/ $snortDir"
    execCmd "cp -r etc/* $snortDir/etc"
    logMsg  "$fname" "Installing ET rules"
    execCmd "cd $INSTALLER_WORKDIR/build/snort-rules/et"
    cleanDir "$INSTALLER_WORKDIR/build/snort-rules/et/rules"
    execCmd "tar -zxvf emerging.rules.tar.gz"
    execCmd "mv rules/* $snortDir/rules"
    execCmd "cat $snortDir/rules/sid-msg.map >> $snortDir/etc/sid-msg.map"
    execCmd "cat $snortDir/rules/gen-msg.map >> $snortDir/etc/gen-msg.map"
    execCmd "cat $snortDir/rules/classification.config >> \
	     $snortDir/etc/classification.config"
    execCmd "touch $snortDir/rules/white_list.rules"
    execCmd "touch $snortDir/rules/black_list.rules"
    logMsg "$fname" "Enabling ALL ruleset"
    for i in `ls nortDir/rules/*.rules`
    do
	execCmd "sed -i 's/^#alert/alert/g' $i"
	execCmd "sed -i 's/^##alert/alert/g' $i"
    done
    
    snortconf="$snortDir/etc/snort.conf"
    logMsg "$fname" "Configuring $snortconf"
    # Old variables
    orpath="var RULE_PATH"
    osrpath="var SO_RULE_PATH"
    oprpath="var PREPROC_RULE_PATH"
    owlpath="var WHITE_LIST_PATH"
    oblpath="var BLACK_LIST_PATH"
    olog="merged.log"
    class="classification.config"
    refer="reference.config"
    thres="threshold.conf"
    unico="unicode.map"
    outu2="output unified2: "
    rpath=`echo $snortDir/rules          | sed 's/\//\\\\\//g'`
    srpath=`echo $snortDir/so_rules      | sed 's/\//\\\\\//g'`
    prpath=`echo $snortDir/preproc_rules | sed 's/\//\\\\\//g'`
    epath=`echo $snortDir/etc/           | sed 's/\//\\\\\//g'`
    sdir=`echo $snortDir/lib/            | sed 's/\//\\\\\//g'`
    logMsg "$fname"  "Setting up snort.conf variables"
    execCmd "sed -i -r 's/($orpath) .*/\1 $rpath/'   $snortconf"
    execCmd "sed -i -r 's/($osrpath) .*/\1 $srpath/' $snortconf"
    execCmd "sed -i -r 's/($oprpath) .*/\1 $prpath/' $snortconf"
    execCmd "sed -i -r 's/($owlpath) .*/\1 $rpath/'  $snortconf"
    execCmd "sed -i -r 's/($oblpath) .*/\1 $rpath/'  $snortconf"
    execCmd "sed -i -r 's/($class)/ $epath\1/g'      $snortconf"
    execCmd "sed -i -r 's/($refer)/ $epath\1/g'      $snortconf"
    execCmd "sed -i -r 's/($thres)/ $epath\1/g'      $snortconf"
    execCmd "sed -i -r 's/ ($unico)/ $epath\1/g'      $snortconf"
    execCmd "sed -i -r 's/#.*($outu2.*)/\1/g'        $snortconf"
    execCmd "sed -i -r 's/\/usr\/local\/lib/$sdir/g' $snortconf"
    if [ "$addOpt" == "openAppId" ]; then                                
	lnumber=`grep -n "Step #6: Configure output" $snortconf\
		| awk -F ":" '{print $1 }'`
	inumber=`expr $lnumber - 2`
	logMsg "$fname" "Adding openappid preprocessor conf on line $inumber"
	pline=" preprocessor appid : app_stats_filename appstats-unified.log,\
		 app_stats_period 60, app_detector_dir $snortDir/openappid"
	execCmd "sed -i '$inumber i $pline'  $snortconf"
	nlogu2="snort_alpha_unified2.log"
	logcsv="output alert_csv: snort_alpha_csv.log"
	snortconf="$snortDir/etc/snort_alpha.conf"
	execCmd "mv $snortDir/etc/snort.conf $snortconf"
    else
	nlogu2="snortIds.log"
	logcsv="output alert_csv: snort_stable_csv.log"

    fi
    logMsg "$fname" "Configuring output pluggin configuration"
    execCmd "sed -i -r 's/$olog/$nlogu2/g' $snortconf"
    lnumber=`grep -n "$outu2" $snortconf | awk -F ":" '{print $1 }'`
    inumber=`expr $lnumber + 2`
    execCmd "sed -i '$inumber i $logcsv'  $snortconf"
}
##############################################################################
start
