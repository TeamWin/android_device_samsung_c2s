#!/sbin/bash

echo " - Postrecoveryboot script : Start"

if [[ `getprop|grep sys.mount.ro|awk '{print $2}'|tr -d '[]'` == "0" ]] ; then
  echo " - Postrecoveryboot script : Logical partition sanitizer"
  for i in system_root vendor product odm ; do
    mount -w /$i
    blk=`df -k|grep $i|awk '{print $1}'`
    blk_used=`df -k|grep $i|awk '{print $3}'`
    blk_full=`df -k|grep $i|awk '{print $2}'`
    umount /$i
    if [ $(($blk_full-$blk_used)) -le 1024 ] ; then
      echo " - Postrecoveryboot script : Resizing $i partition (+10MB)"
      e2fsck -fp $blk
      resize2fs $blk $(($blk_full+1024))K
    fi
    echo " - Postrecoveryboot script : Forcing $i partition to be R/W"
    e2fsck -p -E unshare_blocks $blk
    e2fsck -fp $blk
  done
else
  echo " - Postrecoveryboot script : Mounting system readonly"
  echo " - Postrecoveryboot script : Doing nothing!"
fi

echo " - Postrecoveryboot script : Done!"
