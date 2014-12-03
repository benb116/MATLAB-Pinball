function newBallState = updateBallState(ballState, ...
    dt, walls)

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
    % Determine when the ball will hit the wall - if at all.
    [t(ctr), collision_state{ctr}] = ...
        findCollision(ballState, wall);
end
t(t<0) = Inf;
% Find the minimum collision time via sorting.
[t,ind] = sort(t);
collision_state = collision_state(ind);
% If the minimum collision time is less than the simulation time
% (+eps to account for numerical inaccuracies), account for the
% collision.
% disp(t(1))
while t(1) < .001
    t(1) = [];
    collision_state = collision_state(2:end);
end
if (t(1) <= dt+eps)
    newBallState = collision_state{1};
%     if t(1) < .01
%         disp(t(1))
%     end
    ttc = t(1);
    % Accounts for corner cases in which the time to
    % collision is the same for the first two collisions
    % that are to occur. This situation is related to eps so
    % that the numerical accuracy of the computation (very
    % very small results) do not lead to erroneous output.
    % If a corner case is found, x and y velocity chosen
    % from the two collision states such that both x and y
    % velocity are opposite in sign from the initial input
    % state.
    if abs(t(1)-t(2)) < eps
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
% Resimulate the trajectory of the ball if there is time
% left after the collision.
if (dt - ttc > eps)
    newBallState = updateBallState(newBallState, dt-ttc,walls);
end