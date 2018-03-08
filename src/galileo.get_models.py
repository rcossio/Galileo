import sys
longstring=''
model=int(sys.argv[2])
n=0
for line in open(sys.argv[1]):
    if line[0:5] == 'MODEL': 
        n += 1
    if n == model:
        if ((line[0:5] == 'MODEL') or 
            (line[0:6] == 'ENDMDL') or 
            (line[0:18] == 'REMARK VINA RESULT') or 
            (line[0:4] == 'ATOM')  or
            (line[0:4] == 'USER')):
            longstring += line
sys.stdout.write(longstring)

