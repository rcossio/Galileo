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
echo "Searching for BC"
BC=$(which bc| head -1)
echo "    Found $BC"
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

[ ! -d bin ] && mkdir bin
cat > bin/galileo <<EOF
#!/bin/bash

export GALILEOHOME=$GALILEOHOME
export PYTHON=$PYTHON
export VMD=$VMD
export VINA=$VINA
export AUTODOCK4=$AUTODOCK4
export AUTOGRID4=$AUTOGRID4
export BC=$BC
EOF

tail -n +2 src/galileo >> bin/galileo
chmod +x bin/galileo

echo "You should move move $GALILEOHOME/bin/galileo to an executable path"
