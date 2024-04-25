function resultado=girar(datos_mov)
ini_simulador;
% ini_robot;
leerSensores;
th= datos_mov.angulo*(3.14/180);
ruta_seguida=[];
msg_vel.Angular.Z= datos_mov.VelocidadAngular;

if (th<0)
    msg_vel.Angular.Z = msg_vel.Angular.Z * -1;
end
yaw=0.0;
initpos = sub_odom.LatestMessage.Pose.Pose.Position;

initori = sub_odom.LatestMessage.Pose.Pose.Orientation;
ang_euler=quat2eul([initori.W initori.X initori.Y initori.Z]); 
yawini=ang_euler(1);

disp("Inicializamos leyendo la primera posicion: ");
disp(yawini);
i=0;

while(1)
    i=i+1;
    ori = sub_odom.LatestMessage.Pose.Pose.Orientation;
    ang_euler1=quat2eul([ori.W ori.X ori.Y ori.Z]);
    yaw=ang_euler1(1);
    ang=angdiff(yawini,yaw);
    disp(ang);
    if(abs(ang)>abs(th))

        msg_vel.Angular.Z=0.0;
        send(pub_vel,msg_vel);
        break;  
    else
        send(pub_vel,msg_vel);
    end
    leerSensores;
    waitfor(r);
end


end
