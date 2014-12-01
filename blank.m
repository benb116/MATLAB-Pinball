wall = [0 0 2 2];
BS = [0 2 1 -1];

X1 = wall(1);
Y1 = wall(2);
X2 = wall(3);
Y2 = wall(4);

slopeW = (Y2 - Y1)/(X2 - X1);

slopeV = BS(4)/BS(3);

cMat = [1 -slopeW; 1 -slopeV;];

rMat = [Y1 - slopeW * X1; BS(2) - slopeV * BS(1)];

sol = cMat\rMat