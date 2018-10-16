*******************************************************************************
DISCLAIMER: This sample application contains publicly available third party
software under open source license(s) and is provided for convenience purposes
only, with no warranty or support of any kind. Licensing information and source
code can be found in the application's source code directory.
*******************************************************************************


[TOC]

# Alpine 3.7 Docker Daemon IOX Application Description
Cisco is providing a reference KVM Docker daemon application that uses an Alpine linux distro as the guest-os. Customer can quickly deploy their native docker app within the current standard IOx KVM infra to verify the docker application's basic features.
If the reference IOx KVM Docker app is not compatible with the customer's docker container, the customer will have to provide their own working version of the KVM Docker guest-os.
Cisco support is limited to only the IOx KVM infrastructure and not to the customer implementation of Docker KVM, which requires the customer to maintain both guest-os and docker updates.

The reference IOx Docker KVM application is a standard IOx KVM app using an Alpine 3.7 distro and standard Docker support.

For more information on Cisco IOx Application Development, refer to wiki:  

https://developer.cisco.com/docs/iox/#introduction-to-iox/introduction-to-iox


# Alpine37-docker IOX KVM Application Download Links
## IOX KVM Application:   
Application image:  

https://devhub.cisco.com/artifactory/webapp/#/artifacts/browse/tree/General/iox-packages/apps/alpine-docker-vm/x86/

Content:  
* README.md                : This README file
* alpine37-docker.v1.0.tar : IOX KVM Application

Login:
user: root
password: cisco

Alpine Open-Source Source Code used for the KVM guest-os:
https://devhub.cisco.com/artifactory/iox-packages/sources/alpine-3.7-src.tar


## IOX KVM Application Build Script Reference:
Github repository:  

https://github.com/CiscoIOx/alpine37-docker-kvm

Content:  
* README.md                : This README file
* build.sh                 : Sample IOX build script used to create the Alpine-docker KVM IOX app  
* package.yaml             : IOX package file
(NOTE: vmdk, qcow2 binaries to be provided later)


# IOx Reference Alpine-Docker KVM Build Steps
Build steps to create Cisco IOx KVM Application based on Alpine 3.7 and Alpine supported docker daemon.

## References
### Alpine 3.7
Alpine metadata(sdk) source tree used:   
https://git.alpinelinux.org/cgit/aports   

Rev: 78198f391b0fafeafdedced4494605ef4d103785

* Linux version 4.9.65-1-hardened (buildozer@build-3-7-x86_64) (gcc version 6.4.0 (Alpine 6.4.0) ) #2-Alpine SMP Mon Nov 27 15:36:10 GMT 2017
* Apache 2.0 License (as indicated by https://github.com/pires/alpine-linux-build/blob/master/LICENSE)


### Docker
https://wiki.alpinelinux.org/wiki/Docker

* Docker version 18.02.0-ce, build 019873ef47

### Cisco IOx Application Development:  
https://developer.cisco.com/docs/iox/#!iox-architecture

IOX reference Docker KVM app installation requirements:
* Single eth0 interface network connection
* 2 VCPUs
* 7000 CPU Units
* 1G system memory
* 8G rootfs disk space

These requirements can be adjusted by changing the provided package.yaml file attributes.
For more details on this topic, refer to:

https://developer.cisco.com/docs/iox/#!package-descriptor


## Build Steps
1. Using a VMWare based KVM Hypervisor development setup (eg: VirtualBox, VMware Workstation Player, VMware Fusion), create the Alpine O/S VM. 
In VMWare Player, create VM with Alpine-iso x86_64 "standard" from download site: https://alpinelinux.org/downloads/
For more details on KVM hypervisor tools, refer to:
https://developer.cisco.com/docs/iox/#!tutorial-build-sample-vm-type-iox-app/tutorial-build-sample-vm-type-iox-app
2. Alpine setup
The following configuration choices where used when isntalling the Alpine 3.7 iso in the VM:
```

    login "root"

    install "setup-alpine"

    configs:

    * keyboard: us/us

    * iox-docker

    * eth0

    * dhcp

    * no - manual network

    * root password : cisco

    * UTC

    * none - no http proxy

    * f - fastest mirror

    * openssh

    * openntpd

    * sda

    * lvmsys

    * y - erase disk

    > reboot

     

    Once running, configure busybox system services:

    1)  /etc/ssh/sshd_config

        PermitRootLogin yes

    2)  /etc/securetty

        ttyS0


    3)  /etc/inittab : add getty support:

        # Put a getty on the serial port for IOX Console

        ttyS0::respawn:/sbin/getty -L ttyS0 115200 vt100

    4)  /etc/network/interfaces

        // STATIC-IP Configs

        auto eth0

        #iface eth0 inet manual

        #        hwaddress ether 12:34:56:78:9A:BC

        iface eth0 inet static

                hwaddress ether 12:34:56:78:9A:BC

                hostname alpinedoc

                address 172.19.198.83

                netmask 255.255.255.0

                gateway 172.19.198.1

         

        // Restart networking w/ changes

        /etc/init.d/networking restart

        ----

        // DHCP IP Configs

        auto eth0

        iface eth0 inet dhcp

                hwaddress ether 12:34:56:78:9A:BC

                hostname alpinedoc

    5)  apk add qemu-guest-agent        // required for FD QEMU app stats
    6)  Edit bootup banner DISCLAIMER:
        /etc/motd

    7)  Change permission of /sys for Ubuntu compatibility of Docker container read access:

        chmod -R 755 /sys/*

    8)  To maximize vmdk disk compression, all unused diskspace allocated in the VM should be cleared to all zero's using the following steps done within the running Alpine VM as the last step before IOX application packaging:
        * From a Linux guest, fill all free space with zeroes by creating a file consisting of all zeroes.

            dd if=/dev/zero of=~/mytempfile

        * Delete the zero-filled file to restore the unused disk space.

            rm -f ~/mytempfile

```
3. Installing Docker in Alpine
Refer to https://wiki.alpinelinux.org/wiki/Docker for details.  
Summarized installation steps:
```
    1)  vim /etc/apk/repositories
            uncomment all respositories
            http://dl-6.alpinelinux.org/alpine/edge/community // docker recommended site does not work!
    2)  apk update
    3)  apk add docker
    4)  rc-update add docker boot
    5)  service docker start
    6)  verify:
            i)  docker ps
            ii) docker images
```

4. IOx Application Packaging
Once the Docker VM application has been created and verified, it is ready for IOx application packaging.
Refer to the Cisco DevNet site for details on this step:  

https://developer.cisco.com/docs/iox/#!vm-applications-overview


5. Sample Build Script
A Cisco provided build script used to create the alpine37-docker.tar application can be found in the build directory. The following files are provided:
```
alpine37-docker-cisco.vmdk      : Original VMWare VM consisting of Alpine 3.7 guest-os and Docker daemon
README.md                       : This README
alpine37-docker.v1.0.qcow2      : Converted qcow2 file from the original alpine37-docker-cisco.vmdk
build.sh                        : IOx packaging build script
package.yaml                    : IOx packaging file
```

To build the app, on a Ubuntu linux build machine (ubuntu1~14.04.3 or later):
1. Copy "build" dir to linux build machine
2. Install "ioxclient" packaging tool.  
Refer to below DevNet link for details:
https://developer.cisco.com/docs/iox/#!what-is-ioxclient
3. Run "build.sh" to generate the IOx app under the "output" dir as "alpine37-docker.v1.0.tar".

# Installing Cisco IOx Alpine-docker Application
## cat9300/9500 USB 3.0 Flash Drive Front Panel Requirement

Before app-hosting can be enabled on cat9k, a USB2.0/3.0 Flash Drive must be installed on the cat9k front-panel USB port. App-hosting only works on the external USB Flash Drive for 16.8 release and will "not" install on bootflash. 16.9 supports the back-panel USB3.0 Flash Drive port using only Cisco certified hardware. 

IOx does not auto-sense the insertion or removal of the front USB Flash.   
One of the below steps needs to be done after the insertion of a new USB Flash:
1) switch "reload"
Or
2) 
```
conf t>
   no iox

   !!! You may have to wait up to a minute to issue "iox" below
   iox 
end
```

NOTE: Though any USB Flash Drive can correctly operate using the cat9k front-panel USB port, the fastest USB3.0 Flash Drive is recommended since the install and start times for an IOx App directly correlate to the fast performance of the flash drive used.

Additionally, vfat and any FAT formats are "not" supported. For best compatibility and performance, EXT2 or EXT4 formats should be used.

## Application Installation Steps:
Refer to the below Cisco.com documents for configuration details:
Overview:  
https://www.cisco.com/c/en/us/td/docs/ios-xml/ios/prog/configuration/169/b_169_programmability_cg/application_hosting.html

CLIs:  
https://www.cisco.com/c/en/us/td/docs/ios-xml/ios/prog/command/169/b_169_programmability_cr/b_169_programmability_cr_chapter_00.html



IOx Alpine-docker application eth0 i/f can either be connected to the Management i/f (eg: cat9k GigabitEthernet0/0) or front panel data-ports (eg: GigabitEthernet1/0/1).
Follow the required setup instructions based upon which external interface is chosen.

1. Load Cisco switch/router Polaris 16.8.1 or later image.
2. Switch/Router configurations:
   - Enable IOX infrastructure services

```
conf t>
!!! Enable IOx
iox

end

```

You must wait until the IOX infra is ready by checking using the "show app-hosting list" until 
the below output is seen.


```
CAT9K#sh app-hosting list
No App found

```

   - Management I/F configurations (Use "only" if Management port is used for the Alpine-docker data port)

Configs requires Management I/F and Alpine-docker I/F to be on the same subnet.
```
For the example configs, shared subent is 172.26.200.0/24:
Mgmt-if IP:         172.26.200.131	(Public IP)
Alpine-docker IP:   172.26.200.134	(Public IP)
Gateway IP:         172.26.200.1	(Public or Private IP)
DNS IP:             172.19.198.82
```

```
conf t>
!!! Management I/F
interface GigabitEthernet0/0
 vrf forwarding Mgmt-vrf
 ip address 172.26.200.131 255.255.255.0
 speed 1000
 negotiation auto

!
!!! IOx Alpine-docker App configs
app-hosting appid alpine_docker
 vnic management guest-interface 0 guest-ipaddress 172.26.200.134 netmask 255.255.255.0 gateway 172.26.200.1 name-server 172.19.198.82 default
 
end

```


   - Front Data Panel data-port I/F configurations (Use "only" if front data-port is used for the Alpine-docker data port)

Configs requires data-port I/F and Alpine-docker I/F to be on the different, routable "public" subnets.
Alpine-docker eth0 connects to a Virtual Port Group (VPG) subnet which is routed to a front panel data-port.
For 16.8, only L3 routable front-panel data port mode is supported for container connections via VPG. 16.9 introduces support of L3 routing to an SVI. Currently, no L2 switching features are directly supported on the VPG. Use a routable SVI for the data-port VLAN to allow Apps to route through the VPG to the SVI VLAN.

```
For the example configs:
Data-Port IP:       201.201.201.1 	(Public or Private IP)
VPG IP:     :       30.30.30.1    	(Public IP)
Alpine-docker IP:   30.30.30.10  	(Public IP)
Gateway IP:         201.201.201.10      (Public or Private IP)
DNS IP:             172.19.198.82
```

```
conf t>
!!! Data Port I/F must be L3 mode
!
!!! Must enable ip routing for L3 Data Ports 
ip routing
!
interface GigabitEthernet1/0/1
 no switchport
 ip address 201.201.201.1 255.255.255.0
 speed 1000

!
!!! Virtual Port Group (VPG) configs
interface VirtualPortGroup0
 ip address 30.30.30.1 255.255.255.0

!
!!! IOx Alpine-docker App configs
app-hosting appid alpine_docker
 vnic gateway1 virtualportgroup 0 guest-interface 0 guest-ipaddress 30.30.30.10 netmask 255.255.255.0 gateway 30.30.30.1 name-server 172.19.198.82 default

end

```

3. CPP policer "must" be disabled for best RX through-put. Default policer limits Container RX to 100 pps.

```
conf t>
policy-map system-cpp-policy
 class system-cpp-police-sys-data
 no police rate 100 pps
end


// show CPP Policer Drops and to check if policer is enabled

CAT9K#show platform hardware fed switch active qos queue stats internal cpu policer

                         CPU Queue Statistics
============================================================================================
                                              (default) (set)     Queue        Queue
QId PlcIdx  Queue Name                Enabled   Rate     Rate      Drop(Bytes)  Drop(Frames)
--------------------------------------------------------------------------------------------
0    11     DOT1X Auth                  Yes     1000      1000     0            0
1    1      L2 Control                  Yes     2000      400      0            0
2    14     Forus traffic               Yes     4000      1000     0            0
3    0      ICMP GEN                    Yes     600       200      0            0
...
23   10     Crypto Control              No      100       200      0            0    <<< "No" indicates policer is disabled.
...


```


4. Install and Start App via IOS exec commands which "must" be followed in the given order:
   -  app-hosting install appid alpine_docker package flash:alpine37-docker.v1.0.tar

   -  app-hosting activate appid alpine_docker

   -  app-hosting start appid alpine_docker

      NOTE: the above commands might take several minutes to complete depending upon various factors:

      - Speed of the USB Flash Disk

      - Switch/Router activity load

      - Boot-up time of the application

5. Check Application Status

   - show app-hosting list
     * This command shows the application operational state.

6. Check Application Resources

   - show app-hosting detail appid \<APPID-NAME\>
     * This command shows the resources allocated to the given appid.
       The Alpine-docker LXC resources such as system memory, vcpus, cpu resources, etc are shown below.


_Example:_

```
AppHosting#app-hosting install appid alpine_docker package flash:alpine37-docker.v1.0.tar
alpine_docker installed successfully
Current state is: DEPLOYED
  
AppHosting#app-hosting activate appid alpine_docker
alpine_docker activated successfully
Current state is: ACTIVATED
  
AppHosting#app-hosting start appid alpine_docker
alpine_docker started successfully
Current state is: RUNNING


AppHosting#show app-hosting list
App id                           State
------------------------------------------------------
alpine_docker                    RUNNING


AppHosting#show app-hosting detail appid alpine_docker
State                  : RUNNING
Author                 : Cisco
Application
  Type                 : vm
  App id               : alpine_docker
  Name                 : Cisco IOx KVM Alpine Docker Application
  Version              : 1.0
Activated profile name : custom
  Description          : KVM Alpine Docker Daemon Application
Resource reservation
  Memory               : 1024 MB
  Disk                 : 10 MB
  CPU                  : 7000 units
  VCPU                 : 2
Attached devices
  Type              Name        Alias
  ---------------------------------------------
  Serial/shell			serial0
  Serial/aux
  Serial/Syslog                 
  Serial/Trace                  

Network interfaces
   ---------------------------------------
eth0:
   MAC address         : 52:54:dd:be:a5:7f
   IPv4 address        : 172.19.198.83


```


7. To Connect to IOx Alpine-docker console: (login/password: root/cisco)
```
> app-hosting connect appid alpine_docker console
```

NOTE: to exit Alpine-docker's console mode, use "^c^c^c".

Output Example:_

```
CAT9K#app-hosting connect appid alpine_docker console
Connected to appliance. Exit using ^c^c^c

CentOS Linux 7 (Core)
Kernel 4.4.86 on an x86_64

CAT9K_1_RP_0 login: root
Password: cisco
Last login: Tue Oct 31 23:29:44 on ttyS0
[root@CAT9K_1_RP_0 ~]#

```


8. To Delete a Running App, the following sequence order must be followed:
   - app-hosting stop appid <MY-APP>      
     * App in "shutdown" state, but cpu/memory/disk resources still allocated and rootfs files and changes remain persistent
   - app-hosting deactivate appid <MY-APP>    
     * App removed with cpu/memory/disk resources all released, but rootfs files and changes remain persistent
   - app-hosting uninstall appid <MY-APP>     
     * App completely removed from IOx and all rootfs files and changes are lost

