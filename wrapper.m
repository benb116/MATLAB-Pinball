function wrapper()
% Make figure
close all
warning('off','MATLAB:singularMatrix')
f = figure;
% Initial conditions
g = -9.8/4;
currentBS = [4 4];
currentBS(3) = randi(7);
currentBS(4) = randi(7);

% Define Walls
Walls = [...
        0 0 0 10 1 1; ... % Left
        0 10 10 10 1 1; ... % Top
        10 0 10 10 1 1; ... % Right
        0 5 3 1 .7 .7; ...
        10 5 7 1 .7 .7; ... 
        0 7 3 10 1 1; ...
        7 10 10 7 1 1;]; % Diag
% Plot Walls
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

% Define Flippers
FlipLeft = [3 1 4.5 0 .9 .9;]; % Left
FlipRight = [7 1 5.5 0 .9 .9;]; % Right
% Plot FLippers
xFlip = [FlipLeft(1), FlipLeft(3)];
yFlip = [FlipLeft(2), FlipLeft(4)];
leftFlipFig = line(xFlip, yFlip);
xFlip = [FlipRight(3), FlipRight(1)];
yFlip = [FlipRight(4), FlipRight(2)];
rightFlipFig = line(xFlip, yFlip);

% Predetermine values for the endpoints when the flipper rotates
% Get flipper length
flipRad = hypot((FlipLeft(3)-FlipLeft(1)),(FlipLeft(4)-FlipLeft(2)));
% Get angles when it's down and when it's upp
thetaDown = atan((FlipLeft(4)-FlipLeft(2))/(FlipLeft(3)-FlipLeft(1)));
thetaUp = -thetaDown;
thetaRange = linspace(thetaDown, thetaUp, 100);
% Get endpoint values based on the range, length, and offset from origin
xRotL = flipRad .* cos(thetaRange) + FlipLeft(1);
xRotR = -flipRad .* cos(thetaRange) + FlipRight(1);
yRot = flipRad .* sin(thetaRange) + FlipLeft(2);

% Initial plot
X = currentBS(1);
Y = currentBS(2);
ballScat = scatter(X,Y);
thefig = gcf;
set(thefig, 'KeyPressFcn', @KeyPress, 'KeyReleaseFcn', @KeyRelease);

while currentBS(2) > -0.1 % While the ball is above y = 0 (the bottom)
   % not >= 0 because of small inaccuracies
   dt = 0.05;
   AllWalls = [Walls; FlipLeft; FlipRight;];

   % Update Plots
   set(leftFlipFig, 'XData', [FlipLeft(1), FlipLeft(3)], 'YData', [FlipLeft(2), FlipLeft(4)]);
   set(rightFlipFig, 'XData', [FlipRight(1), FlipRight(3)], 'YData', [FlipRight(2), FlipRight(4)]);
      
   % Apply gravity
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
        % Moves the endpoint of the left flipper up (if dir == 1) or down
        % (if dir == 0)
        
        % Determine whether to flip the values
        if ~dir
            xRotUse = fliplr(xRotL);
            yRotUse = fliplr(yRot);
        else
            xRotUse = xRotL;
            yRotUse = yRot;
        end
        % Iterate through the endpoints
        for k = 1:100
            FlipLeft = [3 1 xRotUse(k) yRotUse(k) .9 2.5];
            [tCol, newColState] = findCollision(currentBS, FlipLeft);
            if (tCol <= dt+eps) && (tCol >= 0.005)
                currentBS = newColState;
                set(ballScat, 'XData', currentBS(1), 'YData',currentBS(2))
%                 currentBS = updateBallState(currentBS, dt-tCol, Walls);
                dt = 0;
                return
            end
        end
        dt = 0.05;
        FlipLeft(6) = 1;
    end

    function RotateRight(dir)
        if ~dir
            xRotUse = fliplr(xRotR);
            yRotUse = fliplr(yRot);
        else
            xRotUse = xRotR;
            yRotUse = yRot;
        end
        for k = 1:100
            FlipRight = [7 1 xRotUse(k) yRotUse(k) .9 2.5];
            [tCol, newColState] = findCollision(currentBS, FlipRight);
            if (tCol <= dt+eps) && (tCol >= 0)
                currentBS = newColState;
                set(ballScat, 'XData', currentBS(1), 'YData',currentBS(2))
%                 currentBS = updateBallState(currentBS, dt-tCol, AllWalls);
                dt = 0;
                return
            end
        end
        dt = 0.05;
        FlipRight(6) = 1;
    end

end