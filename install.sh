#!/bin/bash
##############################################################################
##############################################################################
## Passive Network Audit Framework installer				    ##
## By Javier Santillan [jusafing@gmail.com] (2014)			    ##
## -------------------------------------------------------------------------##
## Requirements:							    ##
##	- Debian GNU/Linux 7.0.x					    ##
##	- Gentoo GNU/Linux stage3-x					    ##
## Summary :                                                                ##
## 	Installation script of Passive Network Audit Framework v0.1         ##
##	It compiles and installs a set of traffic analysis tools.           ##
## 	See README file for more info.					    ##
##############################################################################

##############################################################################
########################  VARIABLES CONFIGURATION    #########################
##############################################################################
    INSTALLER_DIR=`pwd`
    INSTALLER_LOGFILE="$INSTALLER_DIR/install.log"
    INSTALLER_USER=`whoami`
    INSTALLER_ID="PNAF_MAIN"
    INSTALLER_ARGS=$#
    OPT_OS=$1
    INSTALLER_TOTAL_PKG="23"
    #------------------------------------------------------------------------#
    PNAF_DIR="/pnaf"
    PNAF_SENSORNAME="Test"
    PNAF_USER="pnaf"
##############################################################################
##############################################################################
##############################################################################
start()
{
    userInstall
    checkArgs
    bannerLog
    makeDirs
    installPkg "$OPT_OS"
    runInstaller "1"  "MODULES/DPM/NPEE"  "PRADS" 	"$OPT_OS"
    runInstaller "2"  "MODULES/DPM/NPEE"  "P0F" 	"$OPT_OS"

    runInstaller "3"  "MODULES/DPM/IDSE"  "SURICATA"    "$OPT_OS"
    runInstaller "4"  "MODULES/DPM/IDSE"  "SNORT" 	"$OPT_OS"
    runInstaller "5"  "MODULES/DPM/IDSE"  "BRO" 	"$OPT_OS"
    runInstaller "6"  "MODULES/DPM/IDSE"  "BARNYARD"    "$OPT_OS"

    runInstaller "7"  "MODULES/DPM/NFAE"  "CXTRACKER"   "$OPT_OS"
    runInstaller "8"  "MODULES/DPM/NFAE"  "ARGUS" 	"$OPT_OS"
    runInstaller "9"  "MODULES/DPM/NFAE"  "YAF" 	"$OPT_OS"
    runInstaller "10" "MODULES/DPM/NFAE"  "SILK" 	"$OPT_OS"
    runInstaller "11" "MODULES/DPM/NFAE"  "TCPDSTAT"    "$OPT_OS"
    runInstaller "12" "MODULES/DPM/NFAE"  "TCPFLOW"     "$OPT_OS"
 
    runInstaller "13" "MODULES/DPM/DPIE"  "CHAOSREADER" "$OPT_OS"
    runInstaller "14" "MODULES/DPM/DPIE"  "NFTRACKER"   "$OPT_OS"
    runInstaller "15" "MODULES/DPM/DPIE"  "XPLICO" 	"$OPT_OS"
    runInstaller "16" "MODULES/DPM/DPIE"  "HTTPRY" 	"$OPT_OS"
    runInstaller "17" "MODULES/DPM/DPIE"  "SSLDUMP"     "$OPT_OS"
    runInstaller "18" "MODULES/DPM/DPIE"  "DNSDUMP"     "$OPT_OS"
    runInstaller "19" "MODULES/DPM/DPIE"  "PASSIVEDNS"  "$OPT_OS"
    runInstaller "20" "MODULES/DPM/DPIE"  "DNSCAP" 	"$OPT_OS"
    runInstaller "21" "MODULES/DPM/DPIE"  "IPFORENSICS" "$OPT_OS"
    runInstaller "22" "MODULES/DPM/DPIE"  "TCPXTRACT"   "$OPT_OS"
    runInstaller "23" "MODULES/DPM/DPIE"  "TCPDUMP"     "$OPT_OS"
    runInstaller "24" "MODULES/DVM/WDVE"  "HTTPD"     "$OPT_OS"

    if [ "$OPT_OS" == "--debian" ]; then
	# TODO: Problems with NACL library, so skipping netsniff on gentoo.
	runInstaller "25"  "MODULES/DPM/DPIE"  "NETSNIFF" "$OPT_OS"
    fi
    installPnaf
    finalBanner
}
##############################################################################
logMsg()
{
    msg="[`date \"+%Y%m%d-%H:%M:%S\"`] $INSTALLER_ID [$1] - $2"
    echo $msg
    echo $msg >> $INSTALLER_LOGFILE 
}
##############################################################################
execCmd()
{
    local fname="execCmd"
    cmd="$1"
    eval $cmd
    if [ $? -ne 0 ]; then
        logMsg "$fname" "ERROR: Execution of ($1)"
        exitInstall
    else
        logMsg "$fname" " OK ... $1"
    fi
}
##############################################################################
exitInstall()
{
    local fname="exitInstall"
    echo
    echo
    echo "The installation script has been terminated with errors"
    echo
    echo
    logMsg "$fname" ""
    logMsg "$fname" ""
    logMsg "$fname" "The installation script has been terminated with errors"
    logMsg "$fname" ""
    logMsg "$fname" ""
    exit 1
}
##############################################################################
checkArgs()
{
    local fname="checkArgs"
    if [ "$OPT_OS" == "--debian" ] || [ "$OPT_OS" == "--gentoo" ]; then
	logMsg "$fname" "Starting installation on $OPT_OS environment"
    else
	echo
	echo "Passive Audit Framework v0.1"
	echo "----------------------------"
	echo "Syntax Error"
	echo
	echo "USAGE"
	echo "    ./install.sh OPTIONS"
	echo
	echo "OPTIONS"
	echo "    --debian	Installs PNAF on Debian GNU/Linux environment"
	echo "    --gentoo	Installs PNAF on Gentoo GNU/Linux environment"
	echo
	exit 1
    fi
}
##############################################################################
userInstall()
{
    if [ "$INSTALLER_USER" != "root" ]; then
    	echo ""
    	echo ""
    	echo "#####################################################"
	echo "# You must be root to exec this installation script #"
	echo "#####################################################"
	echo ""
	echo ""
	exit 1
    fi
}
##############################################################################
bannerLog()
{
    local fname="bannerLog"
    logMsg "$fname" "##############################################"
    logMsg "$fname" "PASSIVE AUDIT FRAMEWORK INSTALLATION"
    logMsg "$fname" "##############################################"
    logMsg "$fname" "______________________________________________"
    logMsg "$fname" "Started @ [`date`]"                    
}
##############################################################################
cleanDir()
{
    local fname="cleanDir"
    if [ -d $1 ]; then
	logMsg "$fname" "Cleaning existing $1 directory"
        execCmd "rm -rf $1" 
#        execCmd "mkdir -p $1"
    fi
}
##############################################################################
makeDirs()
{
    local fname="makeDirs"
    cleanDir "$PNAF_DIR"
    logMsg "$fname" "#####################################"
    logMsg "$fname" "Creating PNAF directories sensor $PNAF_SENSORNAME"
    execCmd "mkdir -p $PNAF_DIR/modules/dcm/ntce"
    execCmd "mkdir -p $PNAF_DIR/modules/dcm/ncpe"
    execCmd "mkdir -p $PNAF_DIR/modules/dpm/npee"
    execCmd "mkdir -p $PNAF_DIR/modules/dpm/idse"
    execCmd "mkdir -p $PNAF_DIR/modules/dpm/nfae"
    execCmd "mkdir -p $PNAF_DIR/modules/dpm/dpie"
    execCmd "mkdir -p $PNAF_DIR/modules/dpm/nsae"
    execCmd "mkdir -p $PNAF_DIR/modules/dvm/gsve"
    execCmd "mkdir -p $PNAF_DIR/modules/dvm/sare"
    execCmd "mkdir -p $PNAF_DIR/modules/dvm/diee"
    execCmd "mkdir -p $PNAF_DIR/modules/mcm/fece"
    execCmd "mkdir -p $PNAF_DIR/modules/mcm/fapi"
    execCmd "mkdir -p $PNAF_DIR/modules/mcm/free"
    execCmd "mkdir -p $PNAF_DIR/modules/mcm/foee"
    execCmd "mkdir -p $PNAF_DIR/bin"
    execCmd "mkdir -p $PNAF_DIR/log"
    execCmd "mkdir -p $PNAF_DIR/reports"
}
##############################################################################
installPnaf()
{
    local fname="installPnaf"
    logMsg "$fname" "#####################################"
    logMsg "$fname" "Installing PNAF modules"
    logMsg "$fname" "Installing required CPAN modules"
    execCmd "cpan -i Config::Auto"
    execCmd "cpan -i Pod::Usage"
    execCmd "cpan -i Proc::Daemon"
    execCmd "cpan -i IO::CaptureOutput"
    execCmd "cpan -i JSON:XS"
    execCmd "cpan -i Cwd"
    execCmd "cpan -i JSON::Parse"
    execCmd "cpan -i Time::Piece"
    execCmd "cpan -i HTTP::BrowserDetect"
    execCmd "cpan -i Getopt::Long"
    execCmd "cpan -i String::Tokenizer"
    execCmd "cpan -i URI::Encode"
    execCmd "cpan -i Devel::Hexdump"
    execCmd "cpan -i Digest::MD5"
    execCmd "cpan -i Data::Dumper"
    execCmd "cpan -i NetPacket::Ethernet"
    execCmd "cpan -i YAML"
    logMsg "$fname" "Installing prerequisite SnortUnified handler "
    execCmd "cd $INSTALLER_DIR/build/SnortUnified"
    execCmd "perl Makefile.PL"
    execCmd "make"
    execCmd "make install"
    cleanDir "$PNAF_DIR/build"
    cleanDir "$PNAF_DIR/etc"
    execCmd "mkdir -p $PNAF_DIR/build"
    execCmd "cp -r $INSTALLER_DIR/build/pnaf/* $PNAF_DIR/build"
    execCmd "mv $PNAF_DIR/build/etc $PNAF_DIR/etc"
    execCmd "touch  $PNAF_DIR/log/pool.capture"
    execCmd "touch  $PNAF_DIR/log/pool.audit"
    execCmd "rm -f $PNAF_DIR/log/capture.fifo"
    execCmd "mkfifo $PNAF_DIR/log/capture.fifo"
    execCmd "rm -f $PNAF_DIR/log/audit.fifo"
    execCmd "mkfifo $PNAF_DIR/log/audit.fifo"
    execCmd "mkdir -p $PNAF_DIR/log/capture"
    ########################## Template fixes ################################
    execCmd "mv $PNAF_DIR/etc/template_emerging-dns.rules \
	     $PNAF_DIR/modules/dpm/idse/snort2.9.6.1/rules/emerging-dns.rules"
    execCmd "mv $PNAF_DIR/etc/template_emerging-policy.rules \
	$PNAF_DIR/modules/dpm/idse/snort2.9.6.1/rules/emerging-policy.rules"
    execCmd "mv $PNAF_DIR/etc/template_emerging-current_events.rules \
	$PNAF_DIR/modules/dpm/idse/snort2.9.6.1/rules/emerging-emerging-current_events.rules"
    makeLinks
}
##############################################################################
installPkg()
{
    local fname="installPkg"
    perl -MCPAN -e 'my $c = "CPAN::HandleConfig"; $c->load(doit => 1, \
    autoconfig => 1); $c->edit(prerequisites_policy => "follow"); \
    $c->edit(build_requires_install_policy => "yes"); $c->commit'
    
    logMsg "$fname" "Installing dependencies using (emerge/apt)"
    if [ "$1" == "--debian" ]; then
        execCmd "aptitude update"
	execCmd "aptitude install -y autoconf automake binutils-dev bison \
	     build-essential byacc ccache cmake dsniff flex g++ gawk gcc\
	     libcap-ng-dev libcli-dev libdatetime-perl libdumbnet-dev\
	     libfixposix0 libfixposix-dev libgeoip-dev zlib1g zlib1g-dev\
	     libgetopt-long-descriptive-perl libglib2.0-cil-dev \
	     libjansson4 libjansson-dev libldns-dev liblzo2-2 libnet1-dev\
	     libmagic-dev libmysql++3 libmysqlclient-dev libmysql++-dev\
	     libnacl-dev libncurses5-dev libldns1 libnetfilter-conntrack-dev\
	     libnetfilter-queue1 libnetfilter-queue-dev libnet-pcap-perl\
	     libnfnetlink0 libnfnetlink-dev libnl-3-dev libnl-genl-3-dev\
	     libpcap-dev libpcre3 libpcre3-dbg libpcre3-dev libsqlite3-dev\
	     libssl-dev liburcu-dev libyaml-0-2 libyaml-dev liblzo2-dev\
	     openssl pkg-config python-dev python-docutils sqlite3 swig\
	     git-core libglib2.0-dev libtool tcpslice tcpick tshark\
	     tcpflow ethtool"
    elif [ "$1" == "--gentoo" ]; then
        execCmd "emerge-webrsync"
        # Base packages    
	cmd="emerge --noreplace autoconf automake binutils bison libtool byacc\
	     ccache cmake flex gawk gcc dev-util/cmake sys-libs/libcap-ng\
	     dev-perl/glib-perl dev-libs/jansson dev-libs/lzo net-libs/libnet\
	     dev-libs/libnl virtual/perl-libnet dev-libs/geoip\
	     net-libs/libnetfilter_queue net-libs/libnetfilter_conntrack\
	     perl-core/libnet dev-perl/Net-PcapUtils dev-perl/Net-Pcap\
	     net-libs/libnfnetlink dev-db/sqlite dev-libs/libyaml\
	     dev-lang/swig net-analyzer/tcpflow dev-libs/libcli\
	     net-analyzer/dsniff dev-perl/DateTime ethtool"
        logMsg "$fname" "Executing: $cmd"
	logMsg "$fname" "See install.log.exec for detailed log ... (working)"
        eval "$cmd" &>> $INSTALLER_LOGFILE.exec
	if [ $? -ne 0 ]; then
	    logMsg "$fname" "ERROR: Execution of ($cmd)"
            exitInstall
	else
	    logMsg "$fname" " OK ... $cmd"
	fi   
    fi    
}
##############################################################################
runInstaller()
{
    local fname="runInstaller-$1"
    prefix=`echo $2 | tr '[:upper:]' '[:lower:]'`
    sdir=`echo $3 | tr '[:upper:]' '[:lower:]'`
    dir="$INSTALLER_DIR/build/$sdir""_installer-0.1"    
    logMsg "$fname" "############################"
    logMsg "$fname" "INSTALLING ($2) $3 "
    execCmd "cd $dir"
    log=`echo $INSTALLER_LOGFILE | sed 's/\//\\\\\//g'`
    installDir=`echo $PNAF_DIR/$prefix/$sdir | sed 's/\//\\\\\//g'`
    id=`echo "$1/$INSTALLER_TOTAL_PKG $3"| sed 's/\//\\\\\//g'`
    logMsg "$fname" "Setting conf parameters on $3 installer script"
    logMsg "$fname" "LOGFILE $log"    
    logMsg "$fname" "INSTALLATION DIR $installDir"    
    execCmd "sed -i -r 's/(INSTALLER_ID)=.*/\1=\"$id\"/' $dir/install.sh"
    execCmd "sed -i -r 's/(INSTALLER_LOGFILE)=.*/\1=\"$log\"/' $dir/install.sh"
    execCmd "sed -i -r 's/($3_DIR)=.*/\1=\"$installDir\"/' $dir/install.sh"
    logMsg "$fname" "Running $3 Installer (Build log: install.log.exec)"
    if [ "$4" == "--debian" ]; then
	execCmd "./install.sh --debian"    
    elif [ "$4" == "--gentoo" ]; then
        execCmd "./install.sh --gentoo"
    fi
}
##############################################################################
makeLinks()
{
    local fname='makeLinks'
    logMsg "$fname" "Installing binaries"
    cleanDir "$PNAF_DIR/bin"
    execCmd "mkdir -p $PNAF_DIR/bin"
    for i in `find $PNAF_DIR -name "*bin" ! -path $PNAF_DIR/bin`
    do
	local bins="`ls $i`"
#	logMsg "$fname" "Binaries from $i: $bins"
	for j in `ls $i`
	do
	    if [ -e $PNAF_DIR/bin/$j ]; then
		execCmd "rm -f $PNAF_DIR/bin/$j"
	    elif [ -L $PNAF_DIR/bin/$j ]; then
		execCmd "rm -f $PNAF_DIR/bin/$j"
	    fi
	    execCmd "ln -s $i/$j $PNAF_DIR/bin/$j"
	done
    done

    logMsg "$fname" "Installing configuration files"
    for j in `find $PNAF_DIR/modules -name "*.conf"`
    do
	local name=`echo $j | awk -F "/" '{print $NF}'`
	execCmd "rm -f $PNAF_DIR/etc/$name"
	execCmd "ln -s $j $PNAF_DIR/etc/$name"
    done

    logMsg "$fname" "Creating configuration files links for PRADS"
    pradsconf="$PNAF_DIR/modules/dpm/npee/prads/etc/prads"
    for j in `ls $pradsconf| grep -v init.d`
    do
	execCmd "rm -f $PNAF_DIR/etc/$j"
	execCmd "ln -s $pradsconf/$j $PNAF_DIR/etc/$j"
    done
    
    logMsg "$fname" "Creating configuration files links for p0f"
    execCmd "rm -f $PNAF_DIR/etc/p0f.fp"
    execCmd "ln -s $PNAF_DIR/modules/dpm/npee/p0f/p0f.fp $PNAF_DIR/etc/p0f.fp"

    logMsg "$fname" "Creating configuration files links for Suricata"
    suriconf="$PNAF_DIR/modules/dpm/idse/suricata/etc/suricata/suricata.yaml"
    execCmd "rm -f $PNAF_DIR/etc/suricata.yaml"
    execCmd "ln -s $suriconf $PNAF_DIR/etc/suricata.yaml"

    logMsg "$fname" "Creating configuration files links for Snort"
    execCmd "rm -f $PNAF_DIR/etc/classification.config"
    execCmd "ln -s $PNAF_DIR/modules/dpm/idse/snort2.9.6.1/etc/classification.config\
	      $PNAF_DIR/etc/"
    execCmd "rm -f $PNAF_DIR/etc/gen-msg.map"
    execCmd "ln -s $PNAF_DIR/modules/dpm/idse/snort2.9.6.1/etc/gen-msg.map\
	      $PNAF_DIR/etc/"
    execCmd "rm -f $PNAF_DIR/etc/sid-msg.map"
    execCmd "ln -s $PNAF_DIR/modules/dpm/idse/snort2.9.6.1/etc/sid-msg.map\
	      $PNAF_DIR/etc/"

    logMsg "$fname" "Updating environment vars"
    export PATH=$PNAF_DIR:$PATH
    installDir=`echo $PNAF_DIR/bin | sed 's/\//\\\\\//g'`
    execCmd "sed -i -r 's/:$installDir//g' /etc/profile"
    execCmd "sed -i -r 's/PATH=\"(.*)\"/PATH=\"\1:$installDir\"/' /etc/profile"
    execCmd "export PATH=$PNAF_DIR/bin:\$PATH"
    execCmd "source /etc/profile"
    execCmd "echo \"source /etc/profile\" >> ~/.bashrc"
}
##############################################################################
finalBanner()
{
    local fname="finalBanner"
    logMsg "$fname" 
    logMsg "$fname" "#####################################"
    logMsg "$fname" " Passive Network Audit Framework v0.1"
    logMsg "$fname" " has been installed successfully    "
    logMsg "$fname" "#####################################"
}
##############################################################################
##############################################################################
##############################################################################
start

