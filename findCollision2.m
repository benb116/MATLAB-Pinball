function [t, collisionState] = ...
    findCollision(ballState, wall, ...
    coefficient_of_restitution)

cor = coefficient_of_restitution;
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
% Vertical wall.
if (x1 == x2)
    % Check if the ball is heading towards the vertical
    % wall and calculate the intersction time.
    if ((x1 - x)*vx > 0)
        t1 = (x1 - x) / vx;
        newY = y + vy*t1;
        % Check if the y-intersection is within the range of
        % the wall.
        if ((newY >= min(y1,y2)) && (newY <= max(y1,y2)))
            t = t1;
            collisionState(1) = x1;
            collisionState(2) = newY;
            collisionState(3) = cor*(-vx);
            collisionState(4) = vy;
        end 
    end
end
% Horizonatal wall.
if (y1 == y2)
    % Check if the ball is heading towards the horizontal
    % wall and calculate the intersction time.
    if ((y1 - y)*vy > 0)
        t1 = (y1 - y) / vy;
        newX = x + vx*t1;
        % Check if the x-intersection is within the range of
        % the wall.
        if ((newX >= min(x1,x2)) && (newX <= max(x1,x2)))
            t = t1;
            collisionState(1) = newX;
            collisionState(2) = y1;
            collisionState(3) = vx;
            collisionState(4) = cor*(-vy);
        end 
    end
end