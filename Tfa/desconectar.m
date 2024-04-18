%% DESCONEXIÓN DE ROS
msg_vel.Linear.X= 0;
msg_vel.Angular.Z= 0;
send(pub,msg_vel);
clear;
rosshutdown;