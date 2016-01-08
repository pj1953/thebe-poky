#!/bin/sh
#11Nov14 by O'Neil - Pack up RFS and toolchain in one archive
#
#I pack up the toolchain into a single archive. Pathes are applied
# and permissions are set correctly before re-packing.

SYSROOTS=/opt/poky/1.7/sysroots
TARGETROOT=armv7a-vfp-neon-poky-linux-gnueabi
BAKEDRFS=../build/tmp/deploy/images/qemuarm/core-image-minimal-dev-qemuarm.tar.bz2
TOOLSPLUS=thebe-toolchain-and-rfs.tar.bz2

#Remove old ones
test -e $TOOLSPLUS && rm -rf $TOOLSPLUS
test -e sysroots && rm -rf sysroots

echo Copy toolchain...
cp -r $SYSROOTS .
echo ...toolchain copied

echo Overlay with bitbake output...
tar -C sysroots/$TARGETROOT -xf $BAKEDRFS
echo ...bitbake output overlaid

echo Add patches...
cd sysroots/$TARGETROOT
patch -p1 <../../thebe_oe.patch
cd ../..
echo ...patches added

#pcre has a funny configuration file that has been adjusted for
# our peculiar circumstances
cp pcre-config sysroots/$TARGETROOT/usr/bin

#These are only half-baked. They got built, but not included in the RFS.
GLIBC=../build/tmp/work/armv7a-vfp-poky-linux-gnueabi/glibc/2.20-r0/package
cp $GLIBC/usr/bin/getent sysroots/$TARGETROOT/usr/bin

OPENSSH=../build/./tmp/work/armv7a-vfp-poky-linux-gnueabi/openssh/6.6p1-r0/package
mkdir -p sysroots/$TARGETROOT/usr/lib/openssh
cp $OPENSSH/usr/lib/openssh/sftp-server sysroots/$TARGETROOT/usr/lib/openssh

echo Fix protections...
find sysroots -type d | xargs chmod go+rx
find sysroots -type f | xargs chmod go+r
echo ...protections fixed

echo Re-pack...
tar -cjf $TOOLSPLUS sysroots
rm -rf sysroots
echo ...repack complete
