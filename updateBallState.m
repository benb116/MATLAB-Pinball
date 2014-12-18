function [newBallState, points] = updateBallState(ballState, ...
    dt, walls, circles, flippers, points)
% Checks each boundary for collisions, reports back the expected ballstate
% after dt
ttc = dt;
% Assume, initially, that the ball does not collide with the
% wall.
newBallState = [(ballState(1)+ballState(3)*dt),...
    (ballState(2)+ballState(4)*dt),...
    ballState(3) ballState(4)];
% Compute the time to collision between the ball at its
% current ball state and each of the walls.
ctr = 0;

for wall = walls'
    ctr = ctr+1;
    % Determine when the ball will hit the wall
    [t(ctr), collision_state{ctr}] = ...
        findCollWall(ballState, wall);
end

for circle = circles'
    ctr = ctr+1;
    % Determine when the ball will hit the circle
    [t(ctr), collision_state{ctr}] = ...
        findCollCirc(ballState, circle);
end

for flipper = flippers'
    ctr = ctr+1;
    % Determine when the ball will hit the flipper
    [t(ctr), collision_state{ctr}] = ...
        findCollFlip(ballState, flipper);
end

t(t<0) = Inf;
% Sort collision times
[t,ind] = sort(t);
collision_state = collision_state(ind);
% Throw out any that are negative
while t(1) <= 0.0001
    t(1) = [];
    collision_state = collision_state(2:end);
end
% t(1)
if (t(1) <= dt+eps)
    newBallState = collision_state{1};
    ttc = t(1);
    % If the collision is with a circle, add a point
    if (ind(1) > length(walls)) && (ind(1) <= length(walls)+length(circles))
        points = points + 1;
    end
    
    % Accounts for corner cases
    if abs(t(1)-t(2)) < .0001
        if sign(ballState(3)) ~= sign(collision_state{1}(3))
            newBallState(3) = collision_state{1}(3);
        else
            newBallState(3) = collision_state{2}(3);
        end
        if sign(ballState(4)) ~= sign(collision_state{1}(4))
            newBallState(4) = collision_state{1}(4);
        else
            newBallState(4) = collision_state{2}(4);
        end
    end
end
% If there's time left over, go again
if (dt - ttc > eps)
    [newBallState, points] = updateBallState(newBallState, ...
        dt-ttc, walls, circles, flippers, points);
end