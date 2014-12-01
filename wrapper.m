close all
warning('off','MATLAB:singularMatrix')

% ss = get(0,'ScreenSize');
% fig = figure('Position',ss.*.5);
% movegui(fig,'center')
figure

dt = 0.05;
g = -9.8/4;
currentBS = [2 7 -5 4];

Walls = [...
        0 3 0 10 .8; ... % Left
        0 10 10 10 .8; ... % Top
        10 3 10 10 .8; ... % Right
        0 3 3 0 .5; ...
        10 3 7 0 1.5; ... 
       
        3 0 7 0 .8]; % Diag

    
for i = 1:length(Walls(:,1))
    thewall = Walls(i,:);
    xWall = linspace(thewall(1), thewall(3), 100);
    yWall = linspace(thewall(2), thewall(4), 100);
    plot(xWall, yWall)
    hold on
end
hold off
h_ax = gca;
axis([0 10 -1 10])
axis off

h_ax_line = axes('position', get(h_ax, 'position'));
X = currentBS(1);
Y = currentBS(2);
scatter(X,Y)
set(h_ax_line, 'color', 'none')
axis([0 10 -1 10])

while currentBS(2) > -0.0001
   currentBS(4) = currentBS(4) + g * dt;
   currentBS = updateBallState(currentBS, dt, Walls);
   scatter(currentBS(1),currentBS(2))
   set(h_ax_line, 'color', 'none')
   axis([0 10 -1 10])
   axis off
   drawnow
end