%% INICIALIZACIÓN DE ROS (COMPLETAR ESPACIOS CON LAS DIRECCIONES IP)
setenv('ROS_MASTER_URI','http://192.168.1.149:11311');
setenv('ROS_IP','192.168.1.141');
rosinit() % Inicialización de ROS en la IP correspondiente
%% DECLARACIÓN DE VARIABLES NECESARIAS PARA EL CONTROL
MAX_TIME = 1000; %% Numero máximo de iteraciones
medidas = zeros(5,1000);
Kp_dist = 0.1;
Kp_ori = 1;
D = 1; %Distancia de separacion pared en metros 

%% DECLARACIÓN DE SUBSCRIBERS
odom = rossubscriber('/robot0/odom'); % Subscripción a la odometría
sonar0 = rossubscriber('/robot0/sonar_0', rostype.sensor_msgs_Range);
%% DECLARACIÓN DE PUBLISHERS
pub = rospublisher('/robot0/cmd_vel', 'geometry_msgs/Twist'); %
msg_vel=rosmessage(pub); %% Creamos un mensaje del tipo declarado en "pub" (geometry_msgs/Twist)
msg_sonar0=rosmessage(sonar0);
%% Definimos la periodicidad del bucle (10 hz)
r = robotics.Rate(10);
waitfor(r);
pause(3); %% Esperamos entre 2 y 5 segundos antes de leer el primer mensaje para aseguramos que empiezan a llegar mensajes.
%% Nos aseguramos recibir un mensaje relacionado con el robot
while (strcmp(odom.LatestMessage.ChildFrameId,'robot0')~=1)
    odom.LatestMessage
end
%% Inicializamos variables para el control
i = 0;
pos = zeros(1,2);
dist = 0;
lastpos = zeros(1,2); 
lastdist = 0;
lastdistav = 0;
%% Bucle de control
while (1)
    i = i + 1;
    %% Obtenemos la posición y medidas de sonar
    pos=odom.LatestMessage.Pose.Pose.Position;
    msg_sonar0 = receive (sonar0);
    %% Calculamos la distancia avanzada y medimos la distancia a la pared
    if i > 1
        distav = sqrt((pos.X - lastpos.X)^2 + (pos.Y - lastpos.Y)^2);
    else
        distav = 0;
    end
    
    dist = msg_sonar0.Range_;
    if dist>5
        dist = 5;
    end
    %% Calculamos el error de distancia y orientación

    if distav > 0 
        Eori = atan2(dist(1) - lastdist(1),distav);
    else 
        Eori = 0;        
    end

    Edist = (dist(1) + 0.105)*cos(Eori) - D;
    medidas(1,i)= dist;
    medidas(2,i)= lastdist; %% valor anterior de distancia
    medidas(3,i)= distav;
    medidas(4,i)= Eori;
    medidas(5,i)= Edist;
    %% Calculamos las consignas de velocidades
    consigna_vel_linear = 0.3;    
    if Eori == 0 
        consigna_vel_ang = 0;
    else
        consigna_vel_ang = Kp_dist * Edist + Kp_ori * Eori;
    end

    %% Condición de parada
    if (Edist<0.01) && (Eori<0.01)
        break;
    end
    %% Aplicamos consignas de control
    msg_vel.Linear.X= consigna_vel_linear;
    msg_vel.Linear.Y=0;
    msg_vel.Linear.Z=0;
    msg_vel.Angular.X=0;
    msg_vel.Angular.Y=0;
    msg_vel.Angular.Z= consigna_vel_ang;
    % Comando de velocidad
    send(pub,msg_vel);
    lastpos = pos;
    lastdist = dist;
    %lastvAng = vAng;
    lastdistav = distav;
    % Temporización del bucle según el parámetro establecido en r
    waitfor(r);
    if i==MAX_TIME
        msg_vel.Linear.X= 0;
        msg_vel.Angular.Z= 0;
        send(pub,msg_vel);
        break;
    end
end
save('medidas.mat','medidas');
%% DESCONEXIÓN DE ROS
rosshutdown;