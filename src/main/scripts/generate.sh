#!/bin/sh

IFS_BAK=$IFS
IFS="
"

for f in `find src/main/data/ -type f -name '*2012*.xml' `; do
  out=`echo "$f" | sed s/.xml/.csv/ | sed s/data/parsed/`
  echo "* $f   => $out"
  perl src/main/perl/convert_iof_xml.pl "$f" >  "$out"
done

IFS=$IFS_BAK