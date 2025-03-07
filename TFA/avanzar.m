%% Utilizando apartado 2 de practica 2, movimiento respetando distancia a la pared
% Modificado para implementar distancia deseada a recorrer en lugar de max
% iteraciones
function resultado=avanzar()

% %% DECLARACIÓN DE VARIABLES NECESARIAS PARA EL CONTROL
MAX_TIME = 1000; % Numero máximo de iteraciones
distancia_total = 0; % Variable para acumular la distancia avanzada

distancia_pared = 0.9;
distancia_avanzar = 2;
Kp_dist = 0.8;
Kp_ori = 0.2;

%% DECLARACIÓN DE SUBSCRIBERS
odom = rossubscriber('/robot0/odom'); % Subscripción a la odometría
sonar0 = rossubscriber('/robot0/sonar_0', rostype.sensor_msgs_Range);
sonar5 = rossubscriber('/robot0/sonar_5', rostype.sensor_msgs_Range);
pub = rospublisher('/robot0/cmd_vel', 'geometry_msgs/Twist'); %


%% DECLARACIÓN DE PUBLISHERS
msg_vel=rosmessage(pub); %% Creamos un mensaje del tipo declarado en "pub" (geometry_msgs/Twist)
msg_sonar0=rosmessage(sonar0);
msg_sonar5= rosmessage(sonar5);
%% Definimos la periodicidad del bucle (10 hz)
r = robotics.Rate(9);
waitfor(r);
% pause(3); %% Esperamos entre 2 y 5 segundos antes de leer el primer mensaje para aseguramos que empiezan a llegar mensajes.
%% Nos aseguramos recibir un mensaje relacionado con el robot
while (strcmp(odom.LatestMessage.ChildFrameId,'robot0')~=1)
    odom.LatestMessage;
end
%% Inicializamos variables para el control
i = 0;
pos = odom.LatestMessage.Pose.Pose.Position;
dist = msg_sonar0.Range_;
distav = 0;
dist_aux = msg_sonar5.Range_;
sensorT = 0;

if receive(sonar0).Range_ > 1.5 && receive(sonar5).Range_ < 1.5
    sensorT = 5;    
end

lastpos = pos;
lastdist = dist;
lastdistav = 0.01;


%% Bucle de control
while (distancia_total < distancia_avanzar && i < MAX_TIME)
    i = i + 1;
    %% Obtenemos la posición y medidas de sonar
    pos=odom.LatestMessage.Pose.Pose.Position;
        
    if sensorT == 5
        msg_sonar0 = receive(sonar5);
    else
        msg_sonar0 = receive (sonar0);
    end

    %% Calculamos la distancia avanzada y medimos la distancia a la pared
    if i > 1
        distav = sqrt((pos.X - lastpos.X)^2 + (pos.Y - lastpos.Y)^2);
        distancia_total = distancia_total + distav;
    else
        distav = 0;
    end

    dist = msg_sonar0.Range_;
    if dist>5
%         dist_aux = recive(sonar5);
%         if dist_aux < 5 
%             dist=dist_aux;
%         else
            dist=5;
%         end       
    end
   

 %% Calculamos el error de distancia y orientación

    Eori = atan2(dist-lastdist, distav);
    Edist = (dist + 0.105)*cos(Eori) - distancia_pared;

    %% Calculamos las consignas de velocidades
    consigna_vel_linear = 0.3;
    consigna_vel_ang = Kp_dist * Edist + Kp_ori * Eori;

    if dist > 1.5
%         if dist_aux < 1.5
%             dist=dist_aux;
%         else
            consigna_vel_ang = 0;
%         end        
    end

    %% Aplicamos consignas de control
    msg_vel.Linear.X= consigna_vel_linear;
    msg_vel.Angular.Z= consigna_vel_ang;
    if sensorT == 5 
        msg_vel.Angular.Z = consigna_vel_ang * -1;
    end
    
    % Comando de velocidad
    send(pub,msg_vel);
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
% save('medidas.mat','medidas');
%% DESCONEXIÓN DE ROS
msg_vel.Linear.X= 0;
msg_vel.Angular.Z= 0;
send(pub,msg_vel);
% desconectar;
resultado = distancia_total;
end



