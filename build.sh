#! /bin/bash -x
VMDK="alpine37-docker-cisco.vmdk"
APP_NAME="alpine37-docker.v1.0"

if [ ! -f $APP_NAME.qcow2 ]; then
   qemu-img convert -c -O qcow2 $VMDK $APP_NAME.qcow2
fi

if [ ! -d output ]; then
	mkdir -p output
else
	rm -rf output/*
fi

if [ $? == 0 ]; then
   cp package.yaml output/
   cp $APP_NAME.qcow2 output/
   ioxclient package --name $APP_NAME output
else
   echo "$APP_NAME KVM build not successful"
fi
