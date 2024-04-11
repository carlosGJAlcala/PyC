function [] = Controlador_P_simulador(x_punto,y_punto)
%Controlador Proporcional para utilizar con el simulador
%Conectar
rosshutdown;
%setenv('ROS_MASTER_URI','http://192.168.1.156:11311');%Casa
%setenv('ROS_IP','192.168.1.154'); %Casa
setenv('ROS_MASTER_URI','http://172.29.30.76:11311'); %Laboratorio
setenv('ROS_IP','172.29.29.65'); %Laboratorio
rosinit; % Inicialización de ROS
%% DECLARACIÓN DE SUBSCRIBERS
odom=rossubscriber('/robot0/odom'); % Subscripción a la odometría 
%% DECLARACIÓN DE PUBLISHERS
pub = rospublisher('/robot0/cmd_vel', 'geometry_msgs/Twist'); 
%% GENERACIÓN DE MENSAJE
msg_vel=rosmessage(pub) %% Creamos un mensaje del tipo declarado en "pub"(geometry_msgs/Twist)
%% Definimos la perodicidad del bucle (10 hz)
global r;
r = robotics.Rate(10);
%% Nos aseguramos recibir un mensaje relacionado con el robot "robot0"
pause(1); % Esperamos 1 segundo para asegurarnos que ha llegado algún mensaje odom, porque sino ls función strcmp da error al tener uno de los campos vacios.
while (strcmp(odom.LatestMessage.ChildFrameId,'robot0')~=1)
 odom.LatestMessage
end

%% Umbrales para condiciones de parada del robot
umbral_distancia = 0.3;
umbral_angulo = 0.3;
%% Variables para plotear
vel_l = [];
vel_a = [];
error_l = [];
error_a = [];
%% Muestreo de pos inicial
pos=odom.LatestMessage.Pose.Pose.Position; 
ori=odom.LatestMessage.Pose.Pose.Orientation; 
yaw=quat2eul([ori.W ori.X ori.Y ori.Z]);
yaw=yaw(1);
disp("Posicion inicial -> x:" + pos.X + "  y: " + pos.Y);
disp("Posicion a llegar -> x:" + x_punto + " y: " + y_punto);
%% Bucle de control infinito
while (1)
%% Obtenemos la posición y orientación actuales
pos=odom.LatestMessage.Pose.Pose.Position; 
ori=odom.LatestMessage.Pose.Pose.Orientation; 
yaw=quat2eul([ori.W ori.X ori.Y ori.Z]);
yaw=yaw(1);
%% Calculamos el error de distancia
error_dist=sqrt((pos.X-x_punto)^2+(pos.Y-y_punto)^2);
error_l = [error_l, error_dist];
%disp("Error de Distancia = " + error_dist);
%% Calculamos el error de orientación
a = atan2((y_punto - pos.Y),(x_punto-pos.X));
error_orientacion = a - yaw;
if error_orientacion < -pi
   error_orientacion = error_orientacion + 2*pi; %Hacemos la correccion de angulo
end
if error_orientacion > pi
   error_orientacion = error_orientacion - 2*pi; %Hacemos la correccion de angulo
end
%disp("Error de Orientacion = " + error_orientacion);
error_a = [error_a, error_orientacion];
%% Calculamos las consignas de velocidades
consigna_vel_linear = 0.1 * error_dist;
if consigna_vel_linear > 1  %Con estas lineas de codigo dejamos en el limite de velocidad que tiene el robot para no saturar
    consigna_vel_linear = 1;
else
    if consigna_vel_linear < -1
        consigna_vel_linear = -1;
    end
end
vel_l = [vel_l, consigna_vel_linear];
consigna_vel_ang = 0.30 * error_orientacion;
if consigna_vel_ang > 0.5 %Con estas lineas de codigo dejamos en el limite de velocidad que tiene el robot para no saturar
    consigna_vel_ang = 0.5;
else
    if consigna_vel_ang < -0.5
        consigna_vel_ang = -0.5;
    end
end
vel_a = [vel_a, consigna_vel_ang];
%% Condición de parada
if (error_dist<umbral_distancia) && (abs(error_orientacion)<umbral_angulo)
    msg_vel.Linear.X= 0;
    msg_vel.Linear.Y=0;
    msg_vel.Linear.Z=0;
    msg_vel.Angular.X=0;
    msg_vel.Angular.Y=0;
    msg_vel.Angular.Z= 0;
    % Comando de velocidad
    send(pub,msg_vel);
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
% Temporización del bucle según el parámetro establecido en r
waitfor(r); 
end
%% Plots
nexttile
plot(error_a);
title("Error de orientación");
nexttile
plot(error_l);
title("Error de distancia");
nexttile
plot(vel_l);
title("Velocidad Lineal");
nexttile
plot(vel_a);
title('Velocidad Angular');
%% DESCONEXIÓN DE ROS
rosshutdown;

end

