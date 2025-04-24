#!/bin/bash


DISTRO=ubuntu-server-24
VMPATH=/Volumes/M2/virt
VMPREFIX=$VMPATH/$DISTRO

INSTALL_ISO_PATH=$VMPREFIX/iso
INSTALL_ISO=$INSTALL_ISO_PATH/$DISTRO.iso
INSTALL_ISO_TEMP=$INSTALL_ISO.temp
BOOTDISK=$VMPREFIX/$DISTRO.hd0.img
VMSPACE=200G


LOCALPREFIX=~/.qlocal

QEMU_BINARY=$LOCALPREFIX/bin/qemu-system-aarch64
QEMU_SOURCES="https://download.qemu.org/qemu-10.0.0.tar.xz"
QEMU_SMP=12
QEMU_MEM=8G
NETWORKDEV=en0
QEMU_BIOS="edk2-aarch64-code.fd"
FASTHDDEV="-device virtio-blk-pci,drive=hd0,id=hd0pci -drive file=$BOOTDISK,if=none,id=hd0"
#FASTHDDEV="-drive if=virtio,file=$BOOTDISK,format=qcow2"
SND="-device intel-hda"
NETDRIVER="e1000"
QEMU_ACCEL="hvf"
QEMU_VNC="-vnc 127.0.0.1:0"
QEMU_CMD="$QEMU_BINARY -smp $QEMU_SMP -device $NETDRIVER,netdev=eth0 -netdev vmnet-bridged,ifname=eth0,id=eth0,ifname=$NETWORKDEV -M virt -cpu host -accel $QEMU_ACCEL -bios $QEMU_BIOS -m $QEMU_MEM -nographic $FASTHDDEV $SND $QEMU_VNC"

TERM_OPEN="osascript -e 'tell app "Terminal" to do script "$QEMU_CMD"'"

URL="https://cdimage.ubuntu.com/releases/24.04/release/ubuntu-24.04.2-live-server-arm64.iso"

JOBS=80


function Vars(){
    echo "DISTRO $DISTRO"
    echo "VMPREFIX $VMPREFIX"
    echo "INSTALL_ISO $INSTALL_ISO"
    echo "BOOTDISK $BOOTDISK"
    echo "VMSPACE $VMSPACE"
    echo "------------"
    echo "QEMU_SOURCE $QEMU_SOURCES"
    echo "QEMU_BINARY $QEMU_BINARY"
    echo "QEMU_SMP $QEMU_SMP"
    echo "QEMU_MEM $QEMU_MEM"
    echo "URL $URL"
    echo "JOBS (COMPILE THREAD COUNT FOR COMPILING QEMU) $JOBS"
}

function intro(){
echo ""
echo ""
echo ""
echo "!-- using qemu-system-aarch64"
echo "!-- the DISTRO variable is a prefix for all disk and installer isos, the value of DISTRO now is $DISTRO, meaning the hard drive image will be $BOOTDISK and the disk image in question will be located at $INSTALL_ISO"
echo "!-- be sure to modify the INSTALL_ISO and BOOTDISK variables in this script"
echo "!-- the variable for INSTALL_ISO is $URL"
echo "!-- the variable  for BOOTDISK is $BOOTDISK"
echo "!-- the prefix set for VMPREFIX is $VMPREFIX"
echo "!-- the variable for VMSPACE is $VMSPACE"
echo "!-- be sure to run as root!"
echo "!-- this program should be able to download a distributions iso, format a drive on a local device, install, and be able to run a vm without much hassle"
echo ""
echo ""
echo ""
}

intro


function help(){
    echo ""
    echo ""
    echo ""
    echo "--- vmrun 0.1 beta"
    echo "--- $0 download = download image specified in this script"
    echo "--- $0 format = format an image for use with qemu"
    echo "--- $0 install = install using iso specified in script"
    echo "--- $0 copybash = copies $0 to $VMPREFIX"
    echo "--- $0 dirs = create all required directories"
    echo "--- $0 auto = automatically download an iso, format a 200G virtual drive, and, install the operating system (be sure to run this as root)"
    echo "--- $0 kill = kills all qemu processes"
    echo "--- $0 delIMAGES = deletes installation iso and disk images"
    echo "--- $0 qemu = bootstraps qemu 10.0.0 in $LOCALPREFIX"
    echo "--- $0 run = runs the virtual machine and outputs its contents to the terminal"
    echo "--- $0 boot = same thing as $0 run"
    echo "--- $0 vars = show almost all enviormental variables used in script"
    echo "--- $0 clean = deletes all files created by $0"
    echo "--- $0 deltemp = deletes temporary iso file"
    echo "-------"
    echo "typical usage is '$0 qemu' then '$0 auto', then '$0 run', but you can also do '$0 qemu' to get qemu10, '$0 download' to download $URL, '$0 format' to create a disk image at $BOOTDISK, '$0 install' to install the os and then '$0 boot'"
    echo "a copy of this script will be copied to the vm directory, so you can cd $VMPREFIX and execute $0 boot"
    echo "-------"
    echo ""
    echo ""
    echo ""
}

help

function create_local(){
    mkdir -p $INSTALL_ISO_PATH
    mkdir $VMPREFIX
    mkdir $LOCALPREFIX
    mkdir $LOCALPREFIX/src
}

function fetchqemu(){
    echo "creating local dirs"
    create_local
    echo "fetching git sources for qemu"
    mkdir $LOCALPREFIX/src
    curl $QEMU_SOURCES -o $LOCALPREFIX/src/dl.qemu.tar.xz
    cd $LOCALPREFIX/src
    tar xfv $LOCALPREFIX/src/dl.qemu.tar.xz
    cd qemu-10.0.0
    ./configure --prefix=$LOCALPREFIX
    make -j$JOBS
    make install
}


function downloadvm(){
    if [ -f $INSTALL_ISO ]; then
	echo "existing iso found, hopefully its not corrupt!"
	else
	echo "!--- downloading iso from $URL and saving it to $INSTALL_ISO_TEMP"
	curl $URL -o $INSTALL_ISO_TEMP && COMPLETE=1
	if [ $COMPLETE = 1 ]; then
	    echo "complete install detected, copying $INSTALL_ISO_TEMP to $INSTALL_ISO"
	    cp -v $INSTALL_ISO_TEMP $INSTALL_ISO
	    echo "deleting temp file"
	    delisotemp
	fi
	
    fi

    echo "if your downloaded iso doesnt work as intended, try running $0 deltemp!"
}
function delisotemp(){
    echo "deleting $INSTALL_ISO_TEMP"
    rm -rf $INSTALL_ISO_TEMP
    echo "done"
    }
    
function delimages(){
    echo "REMOVING HARD DRIVE IMAGES AND INSTALLATION IMAGE!"
    rm -rf $BOOTDISK
    rm -rf $INSTALL_ISO
    echo "done"
}

function clean(){
    delimages
    echo "deleting $VMPREFIX"
    rm -rf $VMPREFIX
    echo "done"
    }


function formatvm(){
    echo "creating $BOOTDISK"
    qemu-img create -f qcow2 $BOOTDISK $VMSPACE
}

function installvm() {
exec sudo $QEMU_CMD -cdrom $INSTALL_ISO
copybash
}

function runvm() {
    exec sudo $QEMU_CMD
}



function vmlistpids(){
    ps -ax | grep qemu-system-aarch64 |  awk {'print NR " pid: " $1 " program: " $4'}
    echo "if you want to kill a specific process and gain access back to your disk image, use 'kill -9'"
}

function killall_vms(){
    echo "killing all qemu aarch64 proccesess"
    sudo killall qemu-system-aarch64
}

function copybash(){
    echo "copying bash script to $VMPREFIX"
    cd .
    cp $0 $VMPREFIX
    echo "done"
}

function auto(){
    echo "creating local directories"
    create_local
    echo "downloading iso"
    downloadvm
    echo "formatting qemu img"
    formatvm
    echo "copying script to $VMPREFIX"
    copybash
    echo "installing vm. good luck!"
    installvm
    copybash
}

if [[ "$@" == "vars" ]]; then
    Vars
fi

if [[ "$@" == "clean" ]]; then
    clean
fi


if [[ "$@" == "boot" ]]; then
    runvm
fi

if [[ "$@" == "run" ]]; then
    runvm
fi

if [[ "$@" == "deltemp" ]]; then
    delisotemp
fi


if [[ "$@" == "install" ]]; then
    installvm
fi

if [[ "$@" == "kill" ]]; then
    killall_vms
fi

if [[ "$@" == "format" ]]; then
    formatvm
fi

if [[ "$@" == "download" ]]; then
    echo $URL
    echo $BOOT_DISK
    downloadvm
fi

if [[ "$@" == "copybash" ]]; then
    copybash
fi


if [[ "$@" == "auto" ]]; then
    auto
fi

if [[ "$@" == "" ]]; then
    exit
fi

if [[ "$@" == "help" ]]; then
    help
fi

if [[ "$@" == "pids" ]]; then
    vmlistpids
fi

if [[ $@ = "qemu" ]]; then
    fetchqemu
fi

if [[ $@ = "delIMAGES" ]]; then
    delimages
fi

if [[ $@ = "dir" ]]; then
	create_local
fi
