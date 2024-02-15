distancia=4.0;
r=robotics.Rate(10);
msg_vel.Linear.X=0.7;
msg_vel.Linear.Y=0.0;
msg_vel.Linear.Z=0;
msg_vel.Angular.X=0;
msg_vel.Angular.Y=0;
msg_vel.Angular.Z=0;

ruta_seguida=[];


%Leemos la primera posicion
initpos = sub_odom.LatestMessage.Pose.Pose.Position;
disp("Inicializamos leyendo la primera posicion: ");
i=0;
while(1)
    i=i+1
    pos=sub_odom.LatestMessage.Pose.Pose.Position;
    dist=sqrt((initpos.X-pos.X)^2+(initpos.Y-pos.Y)^2);
    dist
     ruta_seguida(i)=dist;

    if(dist>distancia)
        msg_vel.Linear.X=0;
        send(pub_vel,msg_vel);
        break;
    else
       disp("avanza el bot ");

        send(pub_vel,msg_vel);
    end
    lee_sensores;
    waitfor(r);
end