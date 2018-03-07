#!/bin/bash

#$        Put
#$        Here
#PBS      Info
#PBS      For
#SBATCH   Cluster
#SBATCH   Run


# Prepare receptor pdbqt files
galileo rec2pdbqt -r rec.pdbqt

# Visual inspection to set the box
galileo box  -r rec.pdbqt

# Run vina calculations
galileo vina -i vina.in

# Prepare receptor files for ad4
galileo prepare_ad4 -i ad4.in 

# Run ad4 calculations
galileo ad4 -i ad4.in
  
