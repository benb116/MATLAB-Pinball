function wrapper()
% Make figure
close all
warning('off','MATLAB:singularMatrix')
f = figure;
hold on

% Initial conditions
g = -9.8/6;
dt = 0.05;
FlipInc = 5;
currentBS = [9.75 0.25];
currentBS(3) = -rand/10;
currentBS(4) = 0;
plunger = 0;
plungeRel = 0;
Points = 0;

t = title(num2str(Points));
% Define Walls
Walls = [...
        0 4.5 0 7 .9; ... % Left
        3 10 7 10 .9; ... % Top
        10 0 10 7 .9; ... % Right out
        9.5 0 9.5 4.75 1; ... % Right in
        0.5 4.75 3 1 .9; ... % Bottom left upper
        0 4.5 3 0 .9; ... % Bottom left lower
        9.5 4.75 7 1 .9; ... % Bottom right
        0 7 3 10 .9; ... Top left
        7 10 10 7 .9;]; % Top right
Circles = [...
        4 6 .5 1.1; ... % origin x, origin y, radius
        6 6 .5 1.1; ...
        5 8 .5 1.1;
    ];
% Plot Walls
for i = 1:length(Walls(:,1))
    thewall = Walls(i,:);
    xWall = [thewall(1), thewall(3)];
    yWall = [thewall(2), thewall(4)];
    wallfig = line(xWall, yWall);
end

ang=0:0.01:2*pi;
for i = 1:length(Circles(:,1))
    thecirc = Circles(i,:);
    xCirc=thecirc(3)*cos(ang)+thecirc(1);
    yCirc=thecirc(3)*sin(ang)+thecirc(2);
    wallfig = plot(xCirc,yCirc);
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
thetaRange = linspace(thetaDown, thetaUp, FlipInc);
% Get endpoint values based on the range, length, and offset from origin
xRotL = flipRad .* cos(thetaRange) + FlipLeft(1);
xRotR = -flipRad .* cos(thetaRange) + FlipRight(1);
yRot = flipRad .* sin(thetaRange) + FlipLeft(2);

vRotL = diff(xRotL);
vRoty = diff(yRot);
newV = hypot(vRotL, vRoty) / dt;
maxV = newV(1);

% Initial plot
X = currentBS(1);
Y = currentBS(2);
ballScat = scatter(X,Y);
thefig = gcf;
set(thefig, 'KeyPressFcn', @KeyPress, 'KeyReleaseFcn', @KeyRelease);
bottext = text(5,-1,'Hold and release the spacebar to plunge',...
    'HorizontalAlignment', 'center');
bottext.FontSize = 15;

plunge = rectangle('Position',[9.6,-1,.3,1]);
while ~plungeRel
    pause(.5)
    currentBS(4) = currentBS(4) + min([plunger,20]) / 5;
    plungeHeight = 1 - (min([plunger,20]) / 21);
    set(plunge, 'Position', [9.6,-1,.3,plungeHeight]);
    drawnow
end
set(plunge, 'Position', [9.6,-1,.3,.95]);
set(bottext, 'string', 'Use the ''a'' and ''l'' keys to activate the flippers')

lfCount = 0;
rfCount = 0;
leftPos = 0;
rightPos = 0;

while currentBS(2) > -0.1 % While the ball is above y = 0 (the bottom)
    % not >= 0 because of small inaccuracies
    if abs(FlipLeft(4) - leftPos) > 1e-5
        lfCount = lfCount + 1*sign(leftPos - FlipLeft(4));
        if (lfCount > 0) && (lfCount <= length(xRotL))
            FlipLeft = [3 1 xRotL(lfCount) yRot(lfCount) maxV*sign(leftPos - FlipLeft(4))];
        end
    else
        FlipLeft(5) = 0;
    end
    
    if abs(FlipRight(4) - rightPos) > 1e-5
        rfCount = rfCount + 1*sign(rightPos - FlipRight(4));
        if (rfCount > 0) && (rfCount <= length(xRotL))
            FlipRight = [7 1 xRotR(rfCount) yRot(rfCount) maxV*sign(rightPos - FlipRight(4))];
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
    [currentBS, Points] = updateBallState(currentBS, dt, Walls, Circles, Flippers, Points);
    set(ballScat, 'XData', currentBS(1), 'YData',currentBS(2))
    t = title(num2str(Points));

    drawnow
end
% if (currentBS(1) > 9.5) && (currentBS(1) < 10) 
%     currentBS
%     plungeRel = 0;
%     currentBS(1) = 9.75;
%     currentBS(2) = 0.25;
% else
    set(bottext, 'string', 'Press ''r'' to restart or ''q'' to quit')
% end

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
            case ' '
                plunger = plunger + .5;
        end
        
    end

    function KeyRelease(~,eventdata)
        switch eventdata.Character
            case 'a'
                leftPos = 0;
            case 'l'
                rightPos = 0;
            case ' '
                plungeRel = 1;
        end
    end
end