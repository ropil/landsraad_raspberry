#!/bin/bash
#
# Write ArchlinuxARM images from upstream URL to flash device
# Copyright (C) 2019  Robert Pilstål
#
#   This program is free software: you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation, either version 3 of the License, or
#   (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this program. If not, see <http://www.gnu.org/licenses/>.
set -e;

# Number of settings options
NUMSETTINGS=1;
# If you require a target list, of minimum 1, otherwise NUMSETTINGS
let NUMREQUIRED=${NUMSETTINGS};
# Start of list
let LISTSTART=${NUMSETTINGS}+1;

# Set default values
if [ -z ${ARCHARM} ]; then
  ARCHARM="http://os.archlinuxarm.org/os/ArchLinuxARM-rpi-3-latest.tar.gz";
fi

# I/O-check and help text
if [ $# -lt ${NUMREQUIRED} ]; then
  echo "USAGE: [ARCHARM=${ARCHARM}] $0 <device>";
  echo "";
  echo " OPTIONS:";
  echo "  device - target device to flash";
  echo "";
  echo " ENVIRONMENT:";
  echo "  ARCHARM - Upstream URL to ArchARM tarball";
  echo "";
  echo " EXAMPLES:";
  echo "  # Run on sdc, with default tarball";
  echo "  ARCHARM=${ARCHARM} $0 /dev/sdc";
  echo "";
  echo "$(basename $0 .sh)  Copyright (C) 2019  Robert Pilstål;"
  echo "This program comes with ABSOLUTELY NO WARRANTY.";
  echo "This is free software, and you are welcome to redistribute it";
  echo "under certain conditions; see supplied General Public License.";
  exit 0;
fi;

# Parse settings
device=$1;
tarball_url=${ARCHARM};
md5sum_url=${ARCHARM}.md5;
tarball_file=`awk -F / '{print $NF}' <<< ${tarball_url}`;
md5sum_file=`awk -F / '{print $NF}' <<< ${md5sum_url}`;
old_md5sum_file=${md5sum_file}.current;

# Turn on echoing
set -ev;

wget ${md5sum_url} -O ${md5sum_file};
if [ -e ${old_md5sum_file} ]; then
  if [ `diff ${md5sum_file} ${old_md5sum_file} | wc -l` -gt 0 ]; then
    # We've got an older version, slate for download of new one
    rm ${old_md5sum_file};
    if [ -e ${tarball_file} ]; then
      rm ${tarball_file};
    fi;
  fi;
fi;

if [ ! -e ${tarball_file} ]; then
  # Download new tarball
  wget ${tarball_url};
fi;

if [ ! "`md5sum -c ${md5sum_file} | awk '{print $NF}'`" = "OK" ]; then
  # Partial or corrupted tarball, remove and exit
  echo "Tarball did not verify, removing! Please rerun script"
  rm ${tarball_file};
  exit 1;
fi;

# Save checksum of current tarball
mv ${md5sum_file} ${old_md5sum_file};

# Unmount device
for mnt in `mount |grep ${device}| awk '{print $1}'`; do
  umount $mnt;
done

# Partition device here, using sfdisk

# Create filesystems on the first two partitions on the device
mkfs.vfat ${device}1;
mkfs.ext4 ${device}2;

# Create mountpoints and mount
mkdir -p ./root ./boot
mount ${device}1 boot;
mount ${device}2 root;

# Populate filesystem
bsdtar -xpf ${tarball_file} --chroot -C ./root;
sync;
mv ./root/boot/* ./boot;
sync;
umount root boot;
