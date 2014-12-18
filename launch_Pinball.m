function launch_Pinball(varargin)

% Main launcher function. Sets up the boundaries and graphs. Use the
% plunger, has the main while loop that steps dt and checks updateballState

warning('off','MATLAB:singularMatrix')
close all
% Make figure
f = figure;
axis([0 10 -1 10])
axis square
axis off
hold on

% Initial conditions
g = -9.8/4;
dt = 0.05;
FlipInc = 10; % Number of increments the flippers move to
currentBS = [9.75 0.25]; % X and Y
currentBS(3) = -.1; % X vel
currentBS(4) = 0; % Y vel
plunger = 0; % Plunger depth
plungeRel = 0; % Has plunger been released yet?
% If we are resetting with some points
if length(varargin) == 1
    Points = varargin(1);
    Points = Points{1};
else
    Points = 0;
end

if ~exist('highscores.mat', 'file') % If there's no highscore file
    highScore = 0;
    highName = 'None';
    save('highscores', 'highScore', 'highName') % Make a new one
end
load('highscores', 'highScore', 'highName')

% Display the high score in the top left corner
highText = ['High Score: ',num2str(highScore), ' - ', highName];
hst = text(-3,10,highText);
hst.FontSize = 14;
% Display points
t = title(['Points: ', num2str(Points)]);

% Define Walls
Walls = [...
    % X1 Y1 X2 Y2 CoR
    0 4.5 0 6 .9; ... % Left
    2 10 7 10 .6; ... % Top
    10 0 10 7 .9; ... % Right out
    9.5 0 9.5 4.75 1; ... % Right in
    0.5 4.75 3 1 .9; ... % Bottom left upper
    0 4.5 3 0 .6; ... % Bottom left lower
    9.5 4.75 7 1 .9; ... % Bottom right
    0 6 2 10 .7; ... Top left
    7 10 10 7 .7; ... % Top right
    %         9.5 6.5 10 6 .9; ...
    %         9.5 6.5 10 7 .9; ...
    ];
% Plot Walls
for i = 1:length(Walls(:,1))
    thewall = Walls(i,:);
    xWall = [thewall(1), thewall(3)];
    yWall = [thewall(2), thewall(4)];
    wallfig = line(xWall, yWall, 'Color', 'k');
end

% Define Circles
Circles = [...
    % origin x, origin y, radius, CoR
    4 6 .5 1.1; ...
    6 6 .5 1.1; ...
    5 8 .5 1.1; ...
    %         5 4 .5 1.1; ...
    ];
% Plot the Circles
ang=0:0.01:2*pi;
colors = ['g','r','b'];
for i = 1:length(Circles(:,1))
    thecirc = Circles(i,:);
    xCirc=thecirc(3)*cos(ang)+thecirc(1);
    yCirc=thecirc(3)*sin(ang)+thecirc(2);
    col = colors(i);
    wallfig = plot(xCirc,yCirc, 'Color', col);
end

% Define Flippers (same format as walls)
FlipLeft = [3 1 4.5 0 .9;]; % Left
FlipRight = [7 1 5.5 0 .9;]; % Right
% Plot FLippers
xFlipL = [FlipLeft(1), FlipLeft(3)];
yFlipL = [FlipLeft(2), FlipLeft(4)];
leftFlipFig = line(xFlipL, yFlipL, 'Color', 'b');
xFlipR = [FlipRight(3), FlipRight(1)];
yFlipR = [FlipRight(4), FlipRight(2)];
rightFlipFig = line(xFlipR, yFlipR, 'Color', 'b');

% Predetermine values for the endpoints when the flipper rotates
% Get flipper length (using hypot of dX and dY)
flipRad = hypot((FlipLeft(3)-FlipLeft(1)),(FlipLeft(4)-FlipLeft(2)));
% Get angles when it's down and when it's up (arctan of slope)
thetaDown = atan((FlipLeft(4)-FlipLeft(2))/(FlipLeft(3)-FlipLeft(1)));
thetaUp = -thetaDown;
thetaRange = linspace(thetaDown, thetaUp, FlipInc);
% Get endpoint values based on the range, length, and offset from origin
xRotL = flipRad .* cos(thetaRange) + FlipLeft(1);
xRotR = -flipRad .* cos(thetaRange) + FlipRight(1);
yRot = flipRad .* sin(thetaRange) + FlipLeft(2);
% Get flipper speed
vRotL = diff(xRotL);
vRoty = diff(yRot);
newV = hypot(vRotL, vRoty) / dt; % vector add vx and vy
maxV = newV(1);

% Initial plot
X = currentBS(1);
Y = currentBS(2);
ballScat = scatter(X,Y,60, [.8 .8 .8], 'filled');
thefig = gcf;
% Define key press functions
set(thefig, 'KeyPressFcn', @KeyPress, 'KeyReleaseFcn', @KeyRelease);
% Instructions
bottext = text(5,-1,'Hold and release the spacebar to plunge',...
    'HorizontalAlignment', 'center');
bottext.FontSize = 15;

% Plot plunger
plunge = rectangle('Position',[9.6,-1,.3,1]);
while ~plungeRel % While the plunger has not been released
    pause(.5)
    currentBS(4) = currentBS(4) + min([plunger,15]) / 3; % Set new initial Vy
    plungeHeight = 1 - (min([plunger,15]) / 16);
    try
        set(plunge, 'Position', [9.6,-1,.3,plungeHeight]); % Change the plunger look
    end
    drawnow
end
% Reset plunger image and change instructions
set(plunge, 'Position', [9.6,-1,.3,.95]);
set(bottext, 'string', 'Use the ''A'' and ''L'' keys to activate the flippers')
drawnow

lfCount = 0; % The index of the specific endpoint in the array of flipper endpts
rfCount = 0;
leftPos = 0; % Where should the flipper be (0 = down, 2 = up)
rightPos = 0;

% currentBS = [5 1.5 -1 .5];

% MAIN WHILE LOOP --------------------
while currentBS(2) > -0.1 % While the ball is above y = 0 (the bottom)
    % not >= 0 because of small inaccuracies
%     disp('loop')

    Flippers = [FlipLeft; FlipRight];
    % Apply gravity
    currentBS(4) = currentBS(4) + g * dt;
%     currentBS(3:4) = currentBS(3:4) .* .999;
    % Check ballstate before moving the flipper
    [possibleBS1, Points1] = updateBallState(currentBS, dt, Walls, Circles, Flippers, Points);
    
    if abs(FlipLeft(4) - leftPos) > 1e-5 % If the flipper is not where it's supposed to be
        lfCount = lfCount + 1*sign(leftPos - FlipLeft(4)); % Increment the index (up or down)
        if (lfCount > 0) && (lfCount <= length(xRotL))
            % Change the flipper endpt
            % Also set the max addVel to the maxV
            FlipLeft = [3 1 xRotL(lfCount) yRot(lfCount) maxV*sign(leftPos - FlipLeft(4))];
        end
    else
        FlipLeft(5) = 0; % Reset addVel
    end
    
    % Same as the left
    if abs(FlipRight(4) - rightPos) > 1e-5
        rfCount = rfCount + 1*sign(rightPos - FlipRight(4));
        if (rfCount > 0) && (rfCount <= length(xRotR))
            FlipRight = [7 1 xRotR(rfCount) yRot(rfCount) maxV*sign(rightPos - FlipRight(4))];
        end
    else
        FlipRight(5) = 0;
    end
    
    % Update Plots
    try
        set(leftFlipFig, 'XData', [FlipLeft(1), FlipLeft(3)], 'YData', [FlipLeft(2), FlipLeft(4)]);
        set(rightFlipFig, 'XData', [FlipRight(1), FlipRight(3)], 'YData', [FlipRight(2), FlipRight(4)]);
    end
    
    Flippers = [FlipLeft; FlipRight];
    % Check ballstate after moving flipper
    [possibleBS2, Points2] = updateBallState(currentBS, dt, Walls, Circles, Flippers, Points);
    
    if currentBS(1) < 5
        useFlip = Flippers(1,:);
    else
        useFlip = Flippers(2,:);
    end
    slopeB = (useFlip(2) - currentBS(2))/(useFlip(1) - currentBS(1)); % Slope ball
    slopeW = (useFlip(4) - useFlip(2))/(useFlip(3) - useFlip(1)); % Slope wall
    if useFlip == Flippers(2,:)
        slopeB = -slopeB;
        slopeW = -slopeW;
    end
    
    % If the velocities before == velocities after (for pBS1), the ball did
    % not contact the wall. Use pBS2.
    if (possibleBS1(3) == currentBS(3)) && (possibleBS1(4) == currentBS(4)) ...
            && (sign(currentBS(4)) ~= sign(rightPos - FlipRight(4))) ...
            && (slopeB > slopeW)
        currentBS = possibleBS2;
        Points = Points2;
    else
        currentBS = possibleBS1;
        Points = Points1;
    end
    
    % Update graph
    try
        set(ballScat, 'XData', currentBS(1), 'YData',currentBS(2))
    end
    t = title(['Points: ', num2str(Points)]);
    drawnow
end
% If the ball ended in the plunger, reset with the number of points
if abs(currentBS(1) - 9.75) <= .5
    launch_Pinball(Points)
else
    % When the game ends
    if Points > highScore % If new high score
        highScore = Points;
        % Get name
        highNameCell = inputdlg('Please enter your name', 'New high score!');
        if length(highNameCell) >= 1
            highName = highNameCell{1};
        else
            highName = 'Anon';
        end
        % Update file and plot
        save('highscores', 'highScore', 'highName')
        highText = ['High Score: ',num2str(highScore), ' - ', highName];
        set(hst, 'string', highText);
        drawnow
    end
    % New instructions
    try
        set(bottext, 'string', 'Gee Dangit. Press ''R'' to restart or ''Q'' to quit')
    end
end

    function KeyPress(~,eventdata)
        % Utilizes keypresses to move the x/y coordinates of the ball or
        % quits the simulation
        switch eventdata.Character
            case 'q'
                currentBS(2) = -Inf;
                close(gcf)
                return
            case 'a'
                leftPos = 2;
            case 'l'
                rightPos = 2;
            case 'r'
                launch_Pinball() % recurse
            case ' '
                plunger = plunger + .5; % Add plunger depth
        end
        
    end

    function KeyRelease(~,eventdata)
        switch eventdata.Character
            case 'a'
                leftPos = 0;
            case 'l'
                rightPos = 0;
            case ' '
                plungeRel = 1; % RELEASE THE KRAKEN!!!!
        end
    end
end