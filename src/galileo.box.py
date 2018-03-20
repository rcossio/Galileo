import sys
import numpy as np

x0=float(sys.argv[1])
y0=float(sys.argv[2])
z0=float(sys.argv[3])

dx=float(sys.argv[4])/2.
dy=float(sys.argv[5])/2.
dz=float(sys.argv[6])/2.

for x in np.arange(x0-dx,x0+dx+0.1,1.0):
        for y in np.arange(y0-dy,y0+dy+0.1,1.0):
                for z in np.arange(z0-dz,z0+dz+0.1,1.0):    
                        sys.stdout.write('ATOM    000  XX  XXX     0    %8.3f%8.3f%8.3f  1.00  0.00           Ar\n' %(x,y,z))
sys.stdout.write('TER\n')
sys.stdout.write('END\n')

