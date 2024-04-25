
msg_vel.Linear.X= 0;
msg_vel.Linear.Y=0;
msg_vel.Linear.Z=0;
msg_vel.Angular.X=0;
msg_vel.Angular.Y=0;
msg_vel.Angular.Z= 0;
send(pub_vel,msg_vel);

datos_mov.VelocidadAngular=0.3;
datos_mov.velocidad_Lineal=0;
datos_mov.distancia=0;
yawini=0.0;
ori = sub_odom.LatestMessage.Pose.Pose.Orientation;
ang_euler1=quat2eul([ori.W ori.X ori.Y ori.Z]);
yaw=ang_euler1(1);
datos_mov.angulo=-angdiff(yawini,yaw);
girar(datos_mov);