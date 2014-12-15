function [t, collisionState] = ...
    findCollision(ballState, wall)

    x = ballState(1);
    y = ballState(2);
    vx = ballState(3);
    vy = ballState(4);
    p = wall(1);
    q = wall(2);
    r = wall(3);
    cor = wall(4);
    % Initialize the outputs - assume ball will not collide with the wall.
    t = [Inf,Inf];
    collisionState = [NaN NaN NaN NaN];
    % Get the position of the ball at collision
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
    slopeR = (yCol - q)/(xCol - p); % Slope rad
    slopeW = -1 / slopeR;
    angleW = atand(slopeW); % Wall angle (respect to horizontal)
    angleV = atand(vy/vx); % Velocity angle (respect to horizontal)
    % If vx is negative, then angleV will be anti-parallel to the
    % correct angle (respect to horizontal)
    angleV = angleV + 180*(sign(vx) == -1); % Flip it 180 if vx < 0
    % Determine the velocity components after collision
    [nvx, nvy] = bounceVel();
    collisionState = [xCol, yCol, nvx, nvy];            

    
    function [xCol, yCol] = colPoint()
        m = vy/vx;
        if abs(m) == Inf % If velocity is vertical, make it really steep
            m = 10000000;
        end
        b = y - m * x;
%         qCoef = [(m^2+1) 2*(m*b-m*q-p) (q^2-r^2+p^2-2*b*q+b^2)];
%         xCol = roots(qCoef)
%         yCol = m.*xCol + b

        [xCol,yCol] = linecirc(m,b,p,q,r);
%         xCol(isnan(xCol)) = [];
%         yCol(isnan(yCol)) = [];

    end
   
    function [xVel, yVel] = bounceVel()
        % The angle out (respect to horizontal) is:
        angleOut = 2 * angleW - angleV;
        % Magnitude of the velOut will be same as velIn
        % Using sin and cos with the angle
        % Include the coefficient of restitution
        hypot = sqrt(vx^2 + vy^2);        
        corEf = cor;
        xVel = cosd(angleOut)*hypot * corEf;
        yVel = sind(angleOut)*hypot * corEf;
    end

end