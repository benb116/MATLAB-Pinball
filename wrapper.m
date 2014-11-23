close all
currentBS = [5 2 7 8];
X = currentBS(1);
Y = currentBS(2);
scatter(X,Y)
axis([0 10 0 10])
Walls = [0 0 0 10; ...
        0 0 10 0; ...
        10 0 10 10; ...
        0 10 10 10; ...
        2 2 7 5];
dt = 0.05;
g = -9.8;

for t = 0:dt:10
    
   X = currentBS(1);
   Y = currentBS(2);
   Vx = currentBS(3);
   Vy = currentBS(4);
   
   Vy = Vy + g * dt;
   currentBS = [X Y Vx Vy];
   
   currentBS = updateBallState(currentBS, dt,Walls, .8);
   scatter(currentBS(1),currentBS(2))
   axis([0 10 0 10])
   drawnow
end