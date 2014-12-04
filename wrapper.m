function wrapper()

close all
warning('off','MATLAB:singularMatrix')
f = figure;

dt = 0.05;
g = -9.8/4;
currentBS = [8 4];
currentBS(3) = -randi(5);
currentBS(4) = randi(5);

% [5 4 -2 0];
Walls = [...
        0 0 0 10 1; ... % Left
        0 10 10 10 1; ... % Top
        10 0 10 10 1; ... % Right
        0 5 3 1 .9; ...
        10 5 7 1 .9; ... 
        0 7 3 10 1; ...
        7 10 10 7 1;]; % Diag
hold on
for i = 1:length(Walls(:,1))
    thewall = Walls(i,:);
    xWall = [thewall(1), thewall(3)];
    yWall = [thewall(2), thewall(4)];
    wallfig = line(xWall, yWall);
end

axis([0 10 -1 10])
axis square
axis off

FlipLeft = [3 1 4.5 0 1;]; % Left
FlipRight = [5.5 0 7 1 1;]; % Right
% FlipLeft = [3 1 4.5 2 1.1;];
% FlipRight = [5.5 2 7 1 1.1;];

xFlip = [FlipLeft(1), FlipLeft(3)];
yFlip = [FlipLeft(2), FlipLeft(4)];
leftFlipFig = line(xFlip, yFlip);
xFlip = [FlipRight(1), FlipRight(3)];
yFlip = [FlipRight(2), FlipRight(4)];
rightFlipFig = line(xFlip, yFlip);

flipRad = hypot((FlipLeft(3)-FlipLeft(1)),(FlipLeft(4)-FlipLeft(2)));
% thetaMag = abs(atan((FlipLeft(4)-FlipLeft(2))/(FlipLeft(3)-FlipLeft(1))));
thetaDown = atan((FlipLeft(4)-FlipLeft(2))/(FlipLeft(3)-FlipLeft(1)));
thetaUp = -thetaDown;
thetaRange = linspace(thetaDown, thetaUp, 1000);
xRotL = flipRad .* cos(thetaRange) + FlipLeft(1);
xRotR = -flipRad .* cos(thetaRange) + FlipRight(3);
yRot = flipRad .* sin(thetaRange) + FlipLeft(2);

X = currentBS(1);
Y = currentBS(2);
ballScat = scatter(X,Y);
thefig = gcf;
set(thefig, 'KeyPressFcn', @KeyPress, 'KeyReleaseFcn', @KeyRelease);

while currentBS(2) > -0.001
   AllWalls = [Walls; FlipLeft; FlipRight;];
   
   set(leftFlipFig, 'XData', [FlipLeft(1), FlipLeft(3)], 'YData', [FlipLeft(2), FlipLeft(4)]);
   set(rightFlipFig, 'XData', [FlipRight(1), FlipRight(3)], 'YData', [FlipRight(2), FlipRight(4)]);
   currentBS(4) = currentBS(4) + g * dt;
   currentBS = updateBallState(currentBS, dt, AllWalls);
   set(ballScat, 'XData', currentBS(1), 'YData',currentBS(2))
   drawnow
end

    function KeyPress(~,eventdata)
        % Utilizes keypresses to move the x/y coordinates of the ball or
        % quits the simulation
        switch eventdata.Character
            case 'q'
                currentBS(2) = -Inf;
                close(gcf)
            case 'a'
                RotateLeft(1)
            case 'l'
                RotateRight(1)
            case 'r'
                wrapper()
        end
        
    end

    function KeyRelease(~,eventdata)
        switch eventdata.Character
            case 'a'
                RotateLeft(0)
            case 'l'
                RotateRight(0)
        end
    end

    function RotateLeft(dir)
        if ~dir
            xRotUse = fliplr(xRotL);
            yRotUse = fliplr(yRot);
        else
            xRotUse = xRotL;
            yRotUse = yRot;
        end
        for k = 1:1000
            FlipLeft = [3 1 xRotUse(k) yRotUse(k) 1];
        end
    end

    function RotateRight(dir)
        if ~dir
            xRotUse = fliplr(xRotR);
            yRotUse = fliplr(yRot);
        else
            xRotUse = xRotR;
            yRotUse = yRot;
        end
        for k = 1:1000
            FlipRight = [xRotUse(k) yRotUse(k) 7 1 1];
        end
    end

end