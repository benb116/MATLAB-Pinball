function [t, collisionState] = ...
    findCollision(ballState, wall)

    maxV = wall(5);
    x = ballState(1);
    y = ballState(2);
    vx = ballState(3);
    vy = ballState(4);
    x1 = wall(1);
    y1 = wall(2);
    x2 = wall(3);
    y2 = wall(4);
    % Initialize the outputs - assume ball will not collide with the wall.
    t = Inf;
    collisionState = [NaN NaN NaN NaN];
    % Get the position of the ball at collision
    [xCol, yCol] = colPoint();
    % If the coordinates fall in the range of the wall coordinates
    if ((yCol >= min(y1,y2)) && (yCol <= max(y1,y2))...
            && (xCol >= min(x1,x2)) && (xCol <= max(x1,x2)))        
        % Find the time to collision
        t = (xCol - x) / vx;
        if isnan(t) % If vx is 0, this won't work, so use the y velocity
            t = (yCol - y) / vy;
        end
        t = round(1000*t)/1000;
        if t >= 0 % If the ball is headed towards the wall (not away)
            slopeW = (y2 - y1)/(x2 - x1); % Slope wall
            angleW = atand(slopeW); % Wall angle (respect to horizontal)
            angleV = atand(vy/vx); % Velocity angle (respect to horizontal)
            % If vx is negative, then angleV will be anti-parallel to the
            % correct angle (respect to horizontal)
            angleV = angleV + 180*(sign(vx) == -1); % Flip it 180 if vx < 0
            % Determine the velocity components after collision
            [nvx, nvy] = bounceVel();
            collisionState = [xCol, yCol, nvx, nvy];
        end
    end
    
    function [xCol, yCol] = colPoint()
        slopeW = (y2 - y1)/(x2 - x1); % Slope wall
        if abs(slopeW) == Inf % If wall is vertical, make it really steep
            slopeW = 10000000;
        end
        slopeV = vy/vx;
        if abs(slopeV) == Inf % If velocity is vertical, make it really steep
            slopeV = 10000000;
        end
        % Take the two slopes and use point-slope form of the two lines
        % to find the intersection
        cMat = [1 -slopeW; 1 -slopeV;]; % Left side of equations
        rMat = [y1 - slopeW * x1; y - slopeV * x]; % Right side
        sol = cMat\rMat;
        xCol = sol(2);
        yCol = sol(1);
        % Round to account for computational errors
        xCol = round(1000*xCol)/1000;
        yCol = round(1000*yCol)/1000;
    end
   
    function [xVel, yVel] = bounceVel()
        % The angle out (respect to horizontal) is:
        angleOut = 2 * angleW - angleV;
        % Magnitude of the velOut will be same as velIn
        % Using sin and cos with the angle
        % Include the coefficient of restitution
        velmag = sqrt(vx^2 + vy^2);
        flipRad = hypot((x2 - x1),(y2 - y1));
        contDis = sqrt((xCol - x1)^2 + (yCol - y1)^2);
        % addVel is dependent on how far along the flipper the ball hits
        addVel = abs(maxV * (contDis / flipRad));

        xVel = cosd(angleOut)*velmag + sind(angleW)*addVel;
        yVel = sind(angleOut)*velmag + cosd(angleW)*addVel;
    end

end