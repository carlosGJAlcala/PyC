function resultado= seguirPared
% DECLARACIÓN DE VARIABLES NECESARIAS PARA EL CONTROL
MAX_TIME = 1000; %% Numero máximo de iteraciones
kp_dist=[1,0.7,0.7,];
Kp_ori=[0.4,0.4,0.4];

D = [0.5,0.7,2];
distancia_parada=0.01;
velociadadLineal=0.2;
% Distancia de separacion pared en metros

% DECLARACIÓN DE SUBSCRIBERS
ini_simulador;

% Inicializamos variables para el control
leerSensores;
i = 0;
pos=sub_odom.LatestMessage.Pose.Pose.Position;
dist=[msg_sonar0.Range_,msg_sonar1.Range_,msg_sonar2.Range_];
lastpos = pos;

lastdist = dist;

msg_vel.Linear.X= 0;
msg_vel.Linear.Y=0;
msg_vel.Linear.Z=0;
msg_vel.Angular.X=0;
msg_vel.Angular.Y=0;
msg_vel.Angular.Z= 0;
consigna_vel_ang_arra=[0,0,0];
while (1)
    i = i + 1;
    % Obtenemos la posición y medidas de sonar
    pos=sub_odom.LatestMessage.Pose.Pose.Position;
    leerSensores;
    % Calculamos la distancia avanzada y medimos la distancia a la pared
    if i > 1
        distav = sqrt((pos.X - lastpos.X)^2 + (pos.Y - lastpos.Y)^2);
    else
        distav = 0;
    end
    %comparamos que sonar tiene menor rango y cogemos este sonar a seguir

    dist(1) = msg_sonar0.Range_;
    dist(2) = msg_sonar1.Range_;
    dist(3) = msg_sonar2.Range_;
    if(dist(2)<distancia_parada || msg_sonar3.Range_<distancia_parada)
        break;
    end
    if dist(1)>5
        dist(1)= 5;
    end

    if dist(2)>5
        dist(2)= 5;
    end
    if dist(3)>5
        dist(3)= 5;
    end

    % Calculamos las consignas de velocidades
    consigna_vel_linear = velociadadLineal;
    consigna_vel_ang_arra(1)=cPVA(dist(1),lastdist(1),distav,D(1),kp_dist(1),Kp_ori(1));
    consigna_vel_ang_arra(2)=cPVA(dist(2),lastdist(2),distav,D(2),kp_dist(2),Kp_ori(2));
    % consigna_vel_ang_arra(3)=cPVA(dist(3),lastdist(3),distav,D(3),kp_dist(1),Kp_ori(2));
    consigna_vel_ang =sum(consigna_vel_ang_arra)/2;
    if(dist(2)>1 && dist(1)>1)
        % kp_dist=[2,0.7,0.4,0.4];
        consigna_vel_ang=0.3;
        %     kp_dist=[1,0.7,0.7];
    end
    if(msg_sonar3.Range_<0.5 || msg_sonar2.Range_<0.5 )

        consigna_vel_ang=-1;
    end


    % Aplicamos consignas de control

    msg_vel.Linear.X= consigna_vel_linear;
    msg_vel.Angular.Z= consigna_vel_ang;
    % Comando de velocidad
    send(pub_vel,msg_vel);
    lastpos = pos;
    lastdist = dist;
    % Temporización del bucle según el parámetro establecido en r
    waitfor(r);
    if i==MAX_TIME
        msg_vel.Linear.X= 0;
        msg_vel.Angular.Z= 0;
        send(pub,msg_vel);
        break;
    end
end
stop;
end
%% contralador PorpocionalP , calcula la velocidad angular
function resultado=cPVA(dist,lastdist,distav,D,Kp_dist,Kp_ori)
Eori = atan2(dist-lastdist, distav);
Edist = (dist + 0.105)*cos(Eori) - D;
resultado= Kp_dist * Edist + Kp_ori * Eori;
end