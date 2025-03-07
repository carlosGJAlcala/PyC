conectar;
%% DECLARACIÓN DE VARIABLES NECESARIAS PARA EL CONTROL

x_destino = input('Introduzca coordenada destino X: ');
y_destino = input('Introduzca coordenada destino Y: ');

% Ganancias de los controladores P e I
Kp_distancia = 1; 
Kp_angulo = 0.5; 
Ki_angulo = 0.05; 

% Definir el intervalo de muestreo (dt), basado en la frecuencia de su ciclo de control
dt = 0.1; % 10 Hz de frecuencia de muestreo

%% DECLARACIÓN DE SUBSCRIBERS
%odom = rossubscriber('/robot0/odom'); % Subscripción a la odometría
odom=rossubscriber('/pose');

pub_enable= rospublisher('/cmd_motor_state','std_msgs/Int32');
msg_enable_motor=rosmessage(pub_enable);
msg_enable_motor.Data=1;
send(pub_enable,msg_enable_motor);

%% DECLARACIÓN DE PUBLISHERS
%pub = rospublisher('/robot0/cmd_vel', 'geometry_msgs/Twist'); %
pub = rospublisher('/cmd_vel', 'geometry_msgs/Twist');

msg_vel=rosmessage(pub); %% Creamos un mensaje del tipo declarado en"pub" (geometry_msgs/Twist)
%% Definimos la perodicidad del bucle (10 hz)
r = robotics.Rate(10);
waitfor(r);
pause(3); %% Esperamos entre 2 y 5 segundos antes de leer el primer mensaje para aseguramos que empiezan a llegar mensajes.
%% Nos aseguramos recibir un mensaje relacionado con el robot
%while (strcmp(odom.LatestMessage.ChildFrameId,'robot0')~=1)
while (strcmp(odom.LatestMessage.ChildFrameId,'base_link')~=1)
    odom.LatestMessage
end
%% Umbrales para condiciones de parada del robot
umbral_distancia = 0.5;
umbral_angulo = 0.1;
%% Bucle de control infinito
suma_error_ori = 0;
%% Variables para plotear
vel_lineal = [];
vel_angular = [];
error_lineal = [];
error_angular = [];
while (1)
    %% Obtenemos la posición y orientación actuales
    pos=odom.LatestMessage.Pose.Pose.Position;
    ori=odom.LatestMessage.Pose.Pose.Orientation;
    yaw=quat2eul([ori.W ori.X ori.Y ori.Z]);
    yaw=yaw(1);
    %% Calculamos el error de distancia
    Edist = sqrt((x_destino - pos.X)^2 + (y_destino - pos.Y)^2);
    error_lineal=[error_lineal,Edist];
    %% Calculamos el error de orientación
    angulo_destino = atan2(y_destino - pos.Y, x_destino - pos.X);
    Eori = angulo_destino - yaw;
    suma_error_ori = suma_error_ori + Eori * dt;
    error_angular=[error_angular,Eori];

    %% Asignamos valores de consigna
    consigna_vel_linear = Kp_distancia * Edist;
    consigna_vel_ang = Kp_angulo * Eori + Ki_angulo * suma_error_ori;

    %% 1º Orientar correctamente al robot
    if (abs(Eori) > umbral_angulo)
        vel_angular=[vel_angular,consigna_vel_ang];
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
        vel_lineal=[vel_lineal,msg_vel.Linear.X];
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
