function [t, collisionState] = ...
    findCollision(ballState, wall)
% Determines collisions with circles

x = ballState(1);
y = ballState(2);
vx = ballState(3);
vy = ballState(4);
p = wall(1);
q = wall(2);
r = wall(3);
cor = wall(4);

t = [Inf,Inf];
collisionState = [NaN NaN NaN NaN];
% Get collision point
[xCol, yCol] = colPoint();

% Find the time to collision
t = (xCol - x) ./ vx;
if vx == 0 % If vx is 0, this won't work, so use the y velocity
    t = (yCol - y) ./ vy;
end
t = round(10000.*t)./10000;
t(t < 1e-5) = Inf;
[t,ind] = sort(t);
xCol = xCol(ind(1));
yCol = yCol(ind(1));
t = t(1);
slopeR = (yCol - q)/(xCol - p); % Slope of the radius
slopeW = -1 / slopeR; % opposite reciprocal
angleW = atand(slopeW); % Wall angle (respect to horizontal)
angleV = atand(vy/vx); % Velocity angle (respect to horizontal)
% If vx is negative, then angleV will be anti-parallel to the
% correct angle (respect to horizontal)
angleV = angleV + 180*(sign(vx) == -1); % Flip it 180 if vx < 0
% Determine the velocity components after collision
[nvx, nvy] = bounceVel();
collisionState = [xCol, yCol, nvx, nvy];


    function [xCol, yCol] = colPoint()
        m = vy/vx; % Slope
        if abs(m) == Inf % If velocity is vertical, make it really steep
            m = 10000000;
        end
        b = y - m * x; % Y int
        
        [xCol,yCol] = linecirc(m,b,p,q,r); % Thank god for built-in functions
        
    end

    function [xVel, yVel] = bounceVel()
        % The angle out (respect to horizontal) is:
        angleOut = 2 * angleW - angleV;
        % Magnitude of the velOut will be same as velIn
        % Using sin and cos with the angle
        % Include the coefficient of restitution
        hyp = hypot(vx,vy);
        corEf = cor;
        xVel = cosd(angleOut)*hyp * corEf;
        yVel = sind(angleOut)*hyp * corEf;
    end

end