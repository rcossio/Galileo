#!/bin/bash

echo ""
echo "Galileo "
echo "A scientific workflow to address inhibitor search and design"
echo ""

GALILEOHOME=$(pwd)
echo "Current dyrectory: $GALILEOHOME"
echo ""
echo "Searching for python"
PYTHON=$(which python python2 python2.7| head -1)
echo "    Found $PYTHON"
echo ""
echo "Searching for VMD"
VMD=$(which vmd| head -1)
echo "    Found $VMD"
echo ""
echo "Searching for AutodockVina"
VINA=$(which vina| head -1)
echo "    Found $VINA"
echo ""
echo "Searching for Autodock4"
AUTODOCK4=$(which autodock4| head -1)
echo "    Found $AUTODOCK4"
echo "    $($AUTODOCK4 --version| head -1)"
AUTOGRID4=$(which autogrid4| head -1)
echo "    Found $AUTOGRID4"
echo ""

[ -d bin ] && /bin/rm -r bin
mkdir bin
for file in box.sh galileo rec2pdbqt.sh run.vina.sh prepare.ad4.sh run.ad4.sh
do
cat > bin/$file <<EOF
#!/bin/bash
GALILEOHOME=$GALILEOHOME
PYTHON=$PYTHON
VMD=$VMD
VINA=$VINA
AUTODOCK4=$AUTODOCK4
AUTOGRID4=$AUTOGRID4

EOF
tail -n +1 src/$file >> bin/$file
chmod +x bin/$file
done

echo "You should move move $GALILEOHOME/bin/galileo to an executable path"
