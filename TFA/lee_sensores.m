msg_sonar0 = receive(sub_sonar0, 10);
msg_sonar1 = receive(sub_sonar1, 10);
msg_sonar2 = receive(sub_sonar2, 10);
msg_sonar3 = receive(sub_sonar3, 10);
msg_sonar4 = receive(sub_sonar4, 10);
msg_sonar5 = receive(sub_sonar5, 10);
msg_sonar6 = receive(sub_sonar6, 10);
msg_sonar7 = receive(sub_sonar7, 10);
msg_laser = sub_laser.LatestMessage;

pos=sub_odom.LatestMessage.Pose.Pose.Position;
ori=sub_odom.LatestMessage.Pose.Pose.Orientation;