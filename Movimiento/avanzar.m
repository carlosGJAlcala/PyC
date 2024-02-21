distancia=4.0;
r=robotics.Rate(10);

% Velocidades lineales en x,y y z (velocidades en y o z no se usan en 
% robots diferenciales y entornos 2D)
msg_vel.Linear.X= input('Introduzca la velocidad lineal (m/s): ');
msg_vel.Linear.Y=0.0;
msg_vel.Linear.Z=0;

% Velocidades angulares (en robots diferenciales y entornos 2D solo se
% utilizará el valor Z)
msg_vel.Angular.X=0;
msg_vel.Angular.Y=0;
msg_vel.Angular.Z=input('Introduzca la velocidad angular (rad/s): ');

%Array para almacenar datos odometria
ruta_seguida=[];


%Leemos la primera posicion
initpos = sub_odom.LatestMessage.Pose.Pose.Position;
disp("Inicializamos leyendo la primera posicion: ");
i=0;
while(1)
    i=i+1;
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

%% Probar eliminacion de datos duplicados por error de sensores
ruta_filtrada = ruta_seguida(1);

% Filtrar valores consecutivos iguales
for i = 2:length(ruta_seguida)
    if ruta_seguida(i) ~= ruta_seguida(i-1)
        ruta_filtrada = [ruta_filtrada, ruta_seguida(i)];
    end
end

%% Calculo entre medidas:
% Diferencias entre elementos consecutivos
diferencias = diff(ruta_filtrada);
diferencia_minima = min(diferencias);
disp(['La diferencia mínima entre elementos consecutivos es: ', num2str(diferencia_minima)]);

% Limpiar valor de arrays
clear ruta_seguida
clear diferencias
