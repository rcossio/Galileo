
#bash box.sh thing.pdbqt

PREFIX=_TEMP_

if [ "$1" == "--receptor" ]
then 
    shift
    INPUT=$1
    shift
fi
if [ "$1" == "--center" ]
then 
    shift
    x=$1
    shift
    y=$1
    shift
    z=$1
    shift
fi

if [ "$1" == "--size" ]
then
    shift
    dx=$1
    shift
    dy=$1
    shift
    dz=$1
    shift
fi

VMDTEMPLATE=/home/rodrigo/galileo2018/src/box.vmd
VMDEXE=vmd
PYTHONEXE=python

cat $INPUT > $PREFIX.pdb

echo "
import sys
import numpy as np

x0=float($x)
y0=float($y)
z0=float($z)

dx=float($dx)/2.
dy=float($dy)/2.
dz=float($dz)/2.

for x in np.arange(x0-dx,x0+dx+0.1,1.0):
	for y in np.arange(y0-dy,y0+dy+0.1,1.0):
	        for z in np.arange(z0-dz,z0+dz+0.1,1.0):    
			print 'ATOM    000  XX  XXX     0    %8.3f%8.3f%8.3f  1.00  0.00           Ar' %(x,y,z)
print 'TER'
print 'END'

" > $PREFIX.py
$PYTHONEXE $PREFIX.py >> $PREFIX.pdb
/bin/rm $PREFIX.py

sed -e "s/TEMPLATE/$PREFIX/g" $VMDTEMPLATE > $PREFIX.vmd

$VMDEXE -e $PREFIX.vmd
/bin/rm $PREFIX.vmd
/bin/rm $PREFIX.pdb
