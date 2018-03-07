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

