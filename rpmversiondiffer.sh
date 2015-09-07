#!/bin/sh

set -e

if [ "$#" -lt 3 ] || [ "$#" -gt 4 ]; then
	echo "Usage: rpmversiondiffer <REPO> <RPM1> <RPM2> [<EXCLUDE>]"
	exit 1
fi

REPO="$1"
RPM_1="$2"
RPM_2="$3"
EXCLUDE="$4"

echo "REPO = $REPO"
echo "RPM 1 = $RPM_1"
echo "RPM 2 = $RPM_2"
if [ -n "$4" ]; then 
	echo "Excluding files containing \"$EXCLUDE\""
fi

echo "Removing any previously filled folders..."
rm -fr tmp $RPM_1 $RPM_2
mkdir tmp
cd tmp
pwd

yumdownloader --disablerepo=* --enablerepo="$REPO" "$RPM_1"

yumdownloader --disablerepo=* --enablerepo="$REPO" "$RPM_2"

cd ../
mkdir "$RPM_1"
mkdir "$RPM_2"

cd "$RPM_1"
rpm2cpio "../tmp/$RPM_1.rpm" | cpio -idmv --quiet

cd "../$RPM_2"
rpm2cpio "../tmp/$RPM_2.rpm" | cpio -idmv --quiet

cd ../
ls

if [ -n "$4" ]; then 
	echo "Exlcuding files containing \"$EXCLUDE\""
	find $RPM_1 -name "*$EXCLUDE*" -type f -delete
	find $RPM_2 -name "*$EXCLUDE*" -type f -delete
fi

diff -r $RPM_1 $RPM_2 > rpmversiondiff.diff || :

rm -rf tmp/
rm -rf "$RPM_1"
rm -rf "$RPM_2"

