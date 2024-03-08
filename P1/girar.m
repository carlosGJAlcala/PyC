function resultado=girar(datos_mov)
ini_simulador;
ini_robot;
lee_sensores;
th= datos_mov.angulo*(3.14/180);
ruta_seguida=[];
msg_vel.Angular.Z= 0.3;

if (th<0)
    msg_vel.Angular.Z = msg_vel.Angular.Z * -1;

end
yaw=0.0;

%Leemos la primera posicion
initpos = sub_odom.LatestMessage.Pose.Pose.Position;
%angulo
% initori=sub_odom.LatestMessage.Pose.Pose.Orientation;
% ang_euler=quat2eul([initori.W initori.X initori.Z]);
% yawini=ang_euler(1);
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
     ruta_seguida(i)=abs(ang);
    if(abs(ang)>abs(th))

        msg_vel.Angular.Z=0.0;
        send(pub_vel,msg_vel);
        break;  
    else
        send(pub_vel,msg_vel);
    end
    lee_sensores;
    waitfor(r);
end

ruta_filtrada_angular = unique(ruta_seguida);

%% Calculo entre medidas:
% Diferencias entre elementos consecutivos
diferencias_angular = diff(ruta_filtrada_angular);
diferencia_minima_angular = min(diferencias_angular);
disp(['La diferencia mínima entre elementos consecutivos es: ', num2str(diferencia_minima_angular)]);
resultado=abs(ang);
% Limpiar valor de arrays
clear ruta_seguida
clear diferencias_angular
end
