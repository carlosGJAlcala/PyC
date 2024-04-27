function recuperarPos(angulo)
ini_simulador;
datos_mov.VelocidadAngular=0.3;
datos_mov.velocidad_Lineal=0;
datos_mov.distancia=0;
yawini=0.0;
ori = sub_odom.LatestMessage.Pose.Pose.Orientation;
ang_euler1=quat2eul([ori.W ori.X ori.Y ori.Z]);
yaw=ang_euler1(1);
% datos_mov.angulo=angdiff(yawini,yaw);
 datos_mov.angulo=-angulo;

girar(datos_mov);
end