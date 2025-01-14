% General Parameters to set
num_robots = 3;
% Set superimposed field coordinate limits to 800x800
x_axis_sz = 1024;
y_axis_sz = 768;

% Start and configure cameras
imaqreset;
cam1 = videoinput('winvideo', 1);
triggerconfig(cam1, 'manual');
start(cam1);

% Create and open udp listeners for Arduino light level transmission
try
    fclose(instrfindall);
catch
end

% Create and open udp server to send commands to Arduinos
u = udp('10.10.10.255', 8080);
fopen(u);

udpr = {};
udpr{1} = udp('10.10.10.255', 'RemotePort', 8080, 'LocalPort', 8001, 'Timeout', 0.01);
udpr{2} = udp('10.10.10.255', 'RemotePort', 8080, 'LocalPort', 8002, 'Timeout', 0.01);
% udpr{3} = udp('10.10.10.255', 'RemotePort', 8080, 'LocalPort', 8003, 'Timeout', 0.01);
% udpr{4} = udp('10.10.10.255', 'RemotePort', 8080, 'LocalPort', 8004, 'Timeout', 0.01);
% udpr{5} = udp('10.10.10.255', 'RemotePort', 8080, 'LocalPort', 8005, 'Timeout', 0.01);

% setup - only need to open address once
for i = 1:size(udpr,2)
    fopen(udpr{i});
end

% initialize dummy counter variable for ID association
counter = 1;

% configure waypoint matrix manually, or call MakeWaypoints
waypoint_matrix = [100, 700, 90;
                            450, 700, 90;
                            700, 700, 90
                           ];
%                        
% waypoint_matrix(:, :, 3) = waypoint_matrix(:, :, 1);
% num_waypoints = 2;
% go_home = true;
% pose = false;
% waypoint_matrix = MakeWaypoints(num_waypoints, num_robots, x_axis_sz, y_axis_sz, go_home, pose);

% configure tolerances for convergence
dist_tolerance = 40;
theta_tolerance = 180; %180 nullifies directional "pose" checking, instead checking only positional convergence

% initalize plots
positions = [];
fig_graph = figure;
ax_graph = gca;
% pause(5);
tic;

% given 3D waypoint_matrix consisting of multiple 2D goto matrices,
% along with tolerances for achieving each waypoint, successively send
% commands until robots converge on each waypoint, then send next.
for i = 1:size(waypoint_matrix, 3)
    goto_matrix = waypoint_matrix(:, :, i);
    positions = Locate(cam1, x_axis_sz, y_axis_sz, counter, positions, num_robots);
    while ~IsPosed(goto_matrix, positions, dist_tolerance, theta_tolerance)
        % continue converging on this step of waypoint_matrix
        positions = Locate(cam1, x_axis_sz, y_axis_sz, counter, positions, num_robots);
        PlotLocations(positions, goto_matrix, x_axis_sz, y_axis_sz, ax_graph);
        SendCmd(goto_matrix, positions, u);
        counter = counter + 1;
        disp(counter);
        toc;
        tic;
        pause(0.5);
    end
end