function [t, collisionState] = ...
    findCollision(ballState, wall)

    cor = wall(5);
    x = ballState(1);
    y = ballState(2);
    vx = ballState(3);
    vy = ballState(4);
    x1 = wall(1);
    y1 = wall(2);
    x2 = wall(3);
    y2 = wall(4);
    % Initialize the outputs - assume ball will not collide with the
    % wall.
    t = Inf;
    collisionState = [NaN NaN NaN NaN];

    [xCol, yCol] = colPoint(wall,ballState);

    if ((yCol >= min(y1,y2)) && (yCol <= max(y1,y2)) && (xCol >= min(x1,x2)) && (xCol <= max(x1,x2)))        
        t = (xCol - x) / vx;
        if isnan(t)
            t = (yCol - y) / vy;
        end
        if t >= 0
            slopeW = (y2 - y1)/(x2 - x1);
            angleW = atand(slopeW);
            angleV = atand(vy/vx);
            
            if (sign(vx) == -1)
                angleV = angleV + 180;
            end
            
            [nvx, nvy] = bounceVel(angleW, angleV, vx, vy, cor);
            collisionState = [xCol, yCol, nvx, nvy];            
        end
    end
end

function [xCol, yCol] = colPoint(wall,BS)
    
    X1 = wall(1);
    Y1 = wall(2);
    X2 = wall(3);
    Y2 = wall(4);

    slopeW = (Y2 - Y1)/(X2 - X1);
    if slopeW == Inf
        slopeW = 10000000;
    end
    slopeV = BS(4)/BS(3);
    if slopeV == Inf
        slopeV = 10000000;
    end
    cMat = [1 -slopeW; 1 -slopeV;];

    rMat = [Y1 - slopeW * X1; BS(2) - slopeV * BS(1)];

    sol = cMat\rMat;

    xCol = sol(2);
    yCol = sol(1);
    
    xCol = round(1000*xCol)/1000;
    yCol = round(1000*yCol)/1000;
end

function [xVel, yVel] = bounceVel(angleW, angleV, vx, vy, cor)
    angleOut = 2 * angleW - angleV;

%     if angleOut == 180
%         angleOut = angleOut * sign(vx);
%         if angleOut == -180
%             angleOut = 0;
%         end
%     elseif abs(angleOut) == 90
%         angleOut = angleOut * sign(vy);
%     elseif (angleOut <= 0) || (angleV > angleW)
%         angleOut = angleOut + 180;
%     end
    hypot = sqrt(vx^2 + vy^2);
    xVel = cosd(angleOut)*hypot * cor;
    yVel = sind(angleOut)*hypot * cor;
    

end