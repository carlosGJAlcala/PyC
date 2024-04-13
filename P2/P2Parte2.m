conectar;
%% DECLARACIÓN DE VARIABLES NECESARIAS PARA EL CONTROL
MAX_TIME = 1000; %% Numero máximo de iteraciones
medidas = zeros(5,1000);
Kp_dist = 1;
Kp_ori = 0.1;
D = 1; %Distancia de separacion pared en metros

%% DECLARACIÓN DE SUBSCRIBERS
odom = rossubscriber('/robot0/odom'); % Subscripción a la odometría
sonar0 = rossubscriber('/robot0/sonar_0', rostype.sensor_msgs_Range);
pub = rospublisher('/robot0/cmd_vel', 'geometry_msgs/Twist'); %

%odom=rossubscriber('/pose');
%pub_enable= rospublisher('/cmd_motor_state','std_msgs/Int32');
%msg_enable_motor=rosmessage(pub_enable);
%msg_enable_motor.Data=1;
%send(pub_enable,msg_enable_motor);
%sonar0=rossubscriber('/sonar_0');

%% DECLARACIÓN DE PUBLISHERS
%pub = rospublisher('/cmd_vel', 'geometry_msgs/Twist');
msg_vel=rosmessage(pub); %% Creamos un mensaje del tipo declarado en "pub" (geometry_msgs/Twist)
msg_sonar0=rosmessage(sonar0);
%% Definimos la periodicidad del bucle (10 hz)
r = robotics.Rate(10);
waitfor(r);
pause(3); %% Esperamos entre 2 y 5 segundos antes de leer el primer mensaje para aseguramos que empiezan a llegar mensajes.
%% Nos aseguramos recibir un mensaje relacionado con el robot
%while (strcmp(odom.LatestMessage.ChildFrameId,'base_link')~=1)
while (strcmp(odom.LatestMessage.ChildFrameId,'robot0')~=1)
    odom.LatestMessage
end
%% Inicializamos variables para el control
i = 0;
pos = odom.LatestMessage.Pose.Pose.Position;
dist = msg_sonar0.Range_;
lastpos = pos;
lastdist = dist;
lastdistav = 0.01;
%% Bucle de control
%% Variables para plotear
vel_lineal = [];
vel_angular = [];
error_lineal = [];
error_angular = [];
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

    Eori = atan2(dist-lastdist, distav);
    error_angular=[error_angular,Eori];
    Edist = (dist + 0.105)*cos(Eori) - D;
    error_lineal=[error_lineal,Edist];

    medidas(1,i)= dist;
    medidas(2,i)= lastdist; %% valor anterior de distancia
    medidas(3,i)= distav;
    medidas(4,i)= Eori;
    medidas(5,i)= Edist;
    %% Calculamos las consignas de velocidades
    consigna_vel_linear = 0.3;
    consigna_vel_ang = Kp_dist * Edist + Kp_ori * Eori;
    %% Aplicamos consignas de control
   vel_lineal=[vel_lineal,consigna_vel_linear];
   vel_angular=[vel_angular,consigna_vel_ang];

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
    lastvAng = consigna_vel_ang;
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
msg_vel.Linear.X= 0;
msg_vel.Angular.Z= 0;
send(pub,msg_vel);
%% Plots
figure;
nexttile
plot(error_angular);
title("Error de orientación");
nexttile
plot(error_lineal);
title("Error de distancia");
nexttile
plot(vel_lineal);
title("Velocidad Lineal");
nexttile
plot(vel_angular);
title('Velocidad Angular');
desconectar;