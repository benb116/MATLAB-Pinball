function wrapper()
% Make figure
close all
f = figure;

% Initial conditions
g = -9.8/4;
dt = 0.05;
currentBS = [4 3.5];
currentBS(3) = 4;
currentBS(4) = 8;

% Define Walls
Walls = [...
        0 5 0 7 1; ... % Left
        3 10 7 10 1; ... % Top
        10 5 10 7 1; ... % Right
        0 5 3 1 .9; ... % Bottom left
        10 5 7 1 .9; ... % Bottom right
        0 7 3 10 1; ... Top left
        7 10 10 7 1;]; % Top right
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
FlipLeft = [3 1 4.5 0 .9;]; % Left
FlipRight = [7 1 5.5 0 .9;]; % Right
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
% Get angles when it's down and when it's up
thetaDown = atan((FlipLeft(4)-FlipLeft(2))/(FlipLeft(3)-FlipLeft(1)));
thetaUp = -thetaDown;
thetaRange = linspace(thetaDown, thetaUp, 5);
% Get endpoint values based on the range, length, and offset from origin
xRotL = flipRad .* cos(thetaRange) + FlipLeft(1);
xRotR = FlipRight(1) - flipRad .* cos(thetaRange);
yRot = flipRad .* sin(thetaRange) + FlipLeft(2);
% Get max linear velocity of flipper endpoint
vRotL = diff(xRotL);
vRoty = diff(yRot);
newV = hypot(vRotL, vRoty) / dt; % Vector addition
maxV = newV(1);

% Initial ball plot
X = currentBS(1);
Y = currentBS(2);
ballScat = scatter(X,Y);
thefig = gcf;
set(thefig, 'KeyPressFcn', @KeyPress, 'KeyReleaseFcn', @KeyRelease);

lfCount = 0;
rfCount = 0;
leftPos = 0;
rightPos = 0;

while currentBS(2) > -0.1 % While the ball is above y = 0 (the bottom)
    % not >= 0 because of small inaccuracies
    
    if abs(FlipLeft(4) - leftPos) > 1e-5 % If the flipper is not where it's 
    % supposed to be ... 
        lfCount = lfCount + 1*sign(leftPos - FlipLeft(4)); % Increment the stepper
        if (lfCount > 0) && (lfCount <= length(xRotL))
            FlipLeft = [3 1 xRotL(lfCount) yRot(lfCount) maxV]; % Change the pos
        end
    else
        FlipLeft(5) = 0;
    end
    
    if abs(FlipRight(4) - rightPos) > 1e-5
        rfCount = rfCount + 1*sign(rightPos - FlipRight(4));
        if (rfCount > 0) && (rfCount <= length(xRotL))
            FlipRight = [7 1 xRotR(rfCount) yRot(rfCount) maxV];
        end
    else
        FlipRight(5) = 0;
    end
    
    % Update Plots
    set(leftFlipFig, 'XData', [FlipLeft(1), FlipLeft(3)], 'YData', [FlipLeft(2), FlipLeft(4)]);
    set(rightFlipFig, 'XData', [FlipRight(1), FlipRight(3)], 'YData', [FlipRight(2), FlipRight(4)]);

    Flippers = [FlipLeft; FlipRight];
    
    % Apply gravity
    currentBS(4) = currentBS(4) + g * dt;
    currentBS = updateBallState(currentBS, dt, Walls, Flippers);
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
                leftPos = 2;
            case 'l'
                rightPos = 2;
            case 'r'
                wrapper()
        end
        
    end

    function KeyRelease(~,eventdata)
        switch eventdata.Character
            case 'a'
                leftPos = 0;
            case 'l'
                rightPos = 0;
        end
    end

end