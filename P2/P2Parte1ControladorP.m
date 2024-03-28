%% INICIALIZACIÓN DE ROS (COMPLETAR ESPACIOS CON LAS DIRECCIONES IP)
setenv('ROS_MASTER_URI','http://192.168.1.149:11311');
setenv('ROS_IP','192.168.1.141');
rosinit() % Inicialización de ROS en la IP correspondiente
%% DECLARACIÓN DE VARIABLES NECESARIAS PARA EL CONTROL

x_destino = input('Introduzca coordenada destino X: ');
y_destino = input('Introduzca coordenada destino Y: ');

% Ganancias de los controladores P
Kp_distancia = 1; % Ganancia proporcional para el error de distancia
Kp_angulo = 0.5; % Ganancia proporcional para el error de orientación


%% DECLARACIÓN DE SUBSCRIBERS
odom = rossubscriber('/robot0/odom'); % Subscripción a la odometría
%% DECLARACIÓN DE PUBLISHERS
pub = rospublisher('/robot0/cmd_vel', 'geometry_msgs/Twist'); %
msg_vel=rosmessage(pub); %% Creamos un mensaje del tipo declarado en"pub" (geometry_msgs/Twist)
%% Definimos la perodicidad del bucle (10 hz)
r = robotics.Rate(10);
waitfor(r);
pause(3); %% Esperamos entre 2 y 5 segundos antes de leer el primer mensaje para aseguramos que empiezan a llegar mensajes.
%% Nos aseguramos recibir un mensaje relacionado con el robot
while (strcmp(odom.LatestMessage.ChildFrameId,'robot0')~=1)
    odom.LatestMessage
end
%% Umbrales para condiciones de parada del robot
umbral_distancia = 0.5;
umbral_angulo = 0.1;
%% Bucle de control infinito
while (1)
    %% Obtenemos la posición y orientación actuales
    pos=odom.LatestMessage.Pose.Pose.Position;
    ori=odom.LatestMessage.Pose.Pose.Orientation;
    yaw=quat2eul([ori.W ori.X ori.Y ori.Z]);
    yaw=yaw(1);
    %% Calculamos el error de distancia
    Edist = sqrt((x_destino - pos.X)^2 + (y_destino - pos.Y)^2);
    %% Calculamos el error de orientación
    angulo_destino = atan2(y_destino - pos.Y, x_destino - pos.X);
    Eori = angulo_destino - yaw;

    %% Asignamos valores de consigna
    consigna_vel_ang =Kp_angulo * Eori;
    consigna_vel_linear =Kp_distancia * Edist;
    %% 1º Orientar correctamente al robot
    if (abs(Eori) > umbral_angulo)
        msg_vel.Linear.X=0;
        msg_vel.Linear.Y=0;
        msg_vel.Linear.Z=0;
        
        msg_vel.Angular.X=0;
        msg_vel.Angular.Y=0;
        msg_vel.Angular.Z= abs(consigna_vel_ang);
        if (abs(consigna_vel_ang) > 0.5)
            msg_vel.Angular.Z= 0.5;
        end
    else
        %% 2º Desplazar al amigobot
        msg_vel.Linear.X=consigna_vel_linear;
        if (consigna_vel_linear > 1)
            msg_vel.Linear.X= 1;
        end
        msg_vel.Linear.Y=0;
        msg_vel.Linear.Z=0;
    
        msg_vel.Angular.X=0;
        msg_vel.Angular.Y=0;
        msg_vel.Angular.Z=0;
    end
    
    %% Comprobamos umbrales
    if (Edist<umbral_distancia) && (abs(Eori)<umbral_angulo)
        msg_vel.Linear.X=0;
        msg_vel.Linear.Y=0;
        msg_vel.Linear.Z=0;

        msg_vel.Angular.X=0;
        msg_vel.Angular.Y=0;
        msg_vel.Angular.Z=0; 

        send(pub,msg_vel);
        break;
    else
        send(pub,msg_vel);
    end
    
    % Temporización del bucle según el parámetro establecido en r
    waitfor(r);
end
%% DESCONEXIÓN DE ROS
rosshutdown;
