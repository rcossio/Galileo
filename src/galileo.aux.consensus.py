import numpy as np
import sys

def atom_type(x):
    if x == "C"  : return " C "
    if x == "A"  : return " C "
    if x == "N"  : return " N "
    if x == "O"  : return " O "
    if x == "P"  : return " P "
    if x == "S"  : return " S "
    if x == "H"  : return " H "
    if x == "F"  : return " F "
    if x == "I"  : return " I "
    if x == "NA" : return " N "
    if x == "OA" : return " O "
    if x == "SA" : return " S "
    if x == "HD" : return " H "
    if x == "Mg" : return " Mg"
    if x == "Mn" : return " Mn"
    if x == "Zn" : return " Zn"
    if x == "Ca" : return " Ca"
    if x == "Fe" : return " Fe"
    if x == "Cl" : return " Cl"
    if x == "Br" : return " Br"

def rmsd_lb_asimetric(A,B):
    sum = 0
    for i in range(len(A)):
        r2 = 10000000.0
        for j in range(len(A)):
            if A[i][3] == B[j][3]: 

                this_r2 = ( float(A[i][0]) - float(B[j][0]) )**2 + \
                          ( float(A[i][1]) - float(B[j][1]) )**2 + \
                          ( float(A[i][2]) - float(B[j][2]) )**2

                if this_r2 < r2 : r2 = this_r2;

        sum += r2;
    rmsd = np.sqrt( sum / float( len(A) ) )
    return rmsd

def rmsd_lb(arrayA,arrayB):
    rmsd1 = rmsd_lb_asimetric(arrayA,arrayB)
    rmsd2 = rmsd_lb_asimetric(arrayB,arrayA)
    return max( [rmsd1, rmsd2] )

class model:
    def __init__(self):
        self.vinascore = 'NaN'
        self.ad4score  = 'NaN'
        self.globalscore  = 'NaN'
        self.atoms = []
        self.accepted = False
        self.lines = []
    def write(self,filename):
        filename.write('MODEL\n')
        filename.write('REMARK VINA RESULT:    %6.1f '%(self.vinascore)+'   \n')
        filename.write('REMARK AD4  RESULT:    %7.2f'%(self.ad4score)+'   \n')
        filename.write('REMARK FIN. RESULT:    %7.2f'%(self.globalscore)+'   \n')
        for line in self.lines: 
            filename.write(line)
        filename.write('ENDMDL\n')
#-----------------------------------------------------------------------------------------

VinaModelsFile = sys.argv[1]
AD4ModelsFile = sys.argv[2]
RMSDtreshold  = float(sys.argv[3])
OutputFile    = sys.argv[4]


VinaModels=[]

for line in open(VinaModelsFile):
    if line[0:5] == 'MODEL':
        ThisModel = model()

    elif line[0:6] == 'ENDMDL':
        VinaModels.append(ThisModel)

    elif line[0:18] == 'REMARK VINA RESULT':
        ThisModel.vinascore = float( line.split()[3])

    else:
        ThisModel.atoms.append( [line[30:38], line[38:46], line[46:54], line[77:78]]) 
        ThisModel.lines.append(line)

AD4Models=[]

for line in open(AD4ModelsFile):
    if line[0:5] == 'MODEL':
        ThisModel = model()
    elif line[0:6] == 'ENDMDL':
        AD4Models.append(ThisModel)
    elif line[0:40] == 'USER    Estimated Free Energy of Binding':
        ThisModel.ad4score = float( line.split()[7])
    elif line[0:4] == 'ATOM':
        ThisModel.atoms.append( [line[30:38], line[38:46], line[46:54], line[77:78]])
        ThisModel.lines.append(line)
    else:
	ThisModel.lines.append(line)


NVinaModels = len(VinaModels)
NAD4Models  = len(AD4Models)


for i in range(NVinaModels):
    ModelA = VinaModels[i]
    for j in range(NAD4Models):
        ModelB = AD4Models[j]
        rmsd = rmsd_lb(ModelA.atoms,ModelB.atoms)
        if rmsd <= RMSDtreshold:
            ModelA.accepted = True
            if ModelA.ad4score == 'NaN':
                ModelA.ad4score = ModelB.ad4score
            elif ModelB.ad4score < ModelA.ad4score:
                ModelA.ad4score = ModelB.ad4score

for i in range(NVinaModels):
    if VinaModels[i].accepted:
        VinaModels[i].globalscore = -np.sqrt( VinaModels[i].vinascore * VinaModels[i].ad4score)
    else:
        VinaModels[i].globalscore = 0.0

VinaModels = sorted(VinaModels, key=lambda model: model.globalscore)

filename = open(OutputFile,'w')
for i in range(NVinaModels):
    if VinaModels[i].accepted:
        VinaModels[i].write(filename)
filename.close()

