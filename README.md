VMRUN .1 beta

UNIDEF SOFTWARE

intro

** debian12 does not work just yet !! **
** if you want to stop a virtual machine, you need to issue a 'pids' command to the script and try to end the processes by process of elimination! **

these scripts were made for mac silion (m1/m2/m3/m4) devices with an external hard disk for virtualizing fedora server 42, ubuntu server 24, and freebsd 14, its intended to be left at a central spot (~/.vmrun/src), then copied to another bash script, such as runsolaris13.sparc.sh in ~/.vmrun/prod, and then requires modification of the script to work properly, ie inputting the right variables to create and install to virtual machine directories and download an installation iso. after the variables are set, you can download, install, and delete virtual machines as well as make a copy of the shell script and place it in the vm dir all within commands issued to the shell scripts included

** these virtual machines will output directly to the terminal, meaning there is no need for hardware accelerated stuff, or buggy display managers !! works well in mac, is awesome on bsd/linux !!**

the urls to isos i included in the script files are dvd images, and can be as about 4gb in size, so be careful. i found that network installs lead to more erratic results in vms

***
you can modify these to use kvm and typical unix file system heriarchies. also from my experience debian12 doesnt work as well as intended, but the server scripts work fine along with freebsd 14 on my mac book air
***

installation
extract the tarball and execute files with a shell interpreter, like bash or sh, or flag them as an executable using the chmod script included

usage:

	general usage: copy a vmrun script to its own filename, edit the script, and execute with the sh or bash command, or even zsh

	enviromental variables in scripts:
	
	DISTRO      holds the image name, iso name, and directory name suffix.
	VMPATH      this is the prefix to $DISTRO, and contains the root vm folder to use
	VMSPACE     default size for qemu disk images, defaults to 200G
	BOOTDISK    default boot disk for $DISTRO
	QEMU_BINARY default location of bootstrapped qemu
	LOCALPREFIX where to install qemu when fetched from script
	QEMU_SMP    sets the number of processors in the vm, default 8
	QEMU_MEM    sets the number of gigs to allocate to the vm, defaults to 1G
	QEMU_BIOS   sets the bios image for the qemu binary, can be an absolute path to a custom bios, there are a few bios' that come with qemu
	FASTHDDEV   3 options are commented out but the latter FASTHHDEV is good enough!
	SND	    intel hda sound interface
	NETDRIVER   ethernet driver, defaults to e1000
	QEMU_ACCEL  hardware acceleration for vms, defaults to hvf for macos, this should be kvm
		    for linux hosts
	QEMU_VNC    vnc server so you can use x11 if connected (needs work done)
	QEMU_CMD    main qemu command that launches virtualized environments
	TERM_OPEN   unfinished
	URL         URL is the url of the web address of the $DISTRO installation image

commands:

	download = download image specified in this script
	format = format an image for use with qemu
	install = install using iso specified in script
	copybash = copies script to vm dir
	dirs = create all required directories
	auto = automatically download an iso, format a 200G virtual drive, and, install the operating system (be sure to 	run this as root)
	kill = kills all qemu processes
	delIMAGES = deletes installation iso and disk images
	qemu = bootstraps qemu 10.0.0 in /Users/r_atkins/.qlocal
	run = runs the virtual machine and outputs its contents to the terminal
	boot = same thing as rundebian12.aarch64.sh run
	vars = show almost all enviormental variables used in script
	clean = deletes all files created by shell script
	deltemp = deletes temporary iso file
 	pids = shows all process ids 



for auto setup:

    the auto option creates directories, downloads the iso in question for the vm, formats a driver at VMPREFIX, and copies the script to its location, where you can run that script to boot the vm

additional notes:
made for macos silicon devices
dont forcefully terminate a vm or you might have trouble booting it next time

chmod_all_src.sh:
	this file reiterates over all files in the src/ directory and chmods them

todo:
add backup/archive options
