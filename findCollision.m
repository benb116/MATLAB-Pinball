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
        if t > eps
            slopeW = (y2 - y1)/(x2 - x1);
            angleW = atand(slopeW);
            if (angleW < 45)
                vy = -cor*vy;
            elseif (angleW > 45)
                vx = -cor*vx;
            end
            collisionState = [xCol, yCol, vx, vy];
        elseif abs(t) < eps
            
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
%     sol(abs(sol) < .0001) = 0;
    xCol = sol(2);
    yCol = sol(1);
    
    xCol = round(1000*xCol)/1000;
    yCol = round(1000*yCol)/1000;
end