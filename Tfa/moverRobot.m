function resultado= moverRobot(x,y)
ini_simulador;

% DECLARACIÓN DE VARIABLES NECESARIAS PARA EL CONTROL
x_destino =x;
y_destino = y;
% Ganancias de los controladores P e I
Kp_distancia = 0.5;
Kp_angulo = 0.2;
Ki_angulo = 0.05;

% Definir el intervalo de muestreo (dt), basado en la frecuencia de su ciclo de control
dt = 0.1; % 10 Hz de frecuencia de muestreo
r = robotics.Rate(10);
waitfor(r);
pause(3); %% Esperamos entre 2 y 5 segundos antes de leer el primer mensaje para aseguramos que empiezan a llegar mensajes.
% Nos aseguramos recibir un mensaje relacionado con el robot
leerSensores;
% Umbrales para condiciones de parada del robot
umbral_distancia = 0.001;
umbral_angulo = 0.2;
% Bucle de control infinito
suma_error_ori = 0;
% Variables para plotear

while (1)
    leerSensores;
    % Obtenemos la posición y orientación actuales
    pos=sub_odom.LatestMessage.Pose.Pose.Position;
    ori=sub_odom.LatestMessage.Pose.Pose.Orientation;
    yaw=quat2eul([ori.W ori.X ori.Y ori.Z]);
    yaw=yaw(1);
    % Calculamos el error de distancia
    Edist = sqrt((x_destino - pos.X)^2 + (y_destino - pos.Y)^2);
    % Calculamos el error de orientación
    angulo_destino = atan2(y_destino - pos.Y, x_destino - pos.X);
    Eori = angulo_destino - yaw;
    suma_error_ori = suma_error_ori + Eori * dt;

    % Asignamos valores de consigna
    consigna_vel_linear = Kp_distancia * Edist;
    consigna_vel_ang = Kp_angulo * Eori + Ki_angulo * suma_error_ori;

    % 1º Orientar correctamente al robot
    if (abs(Eori) > umbral_angulo)
        msg_vel.Linear.X=0;
        msg_vel.Linear.Y=0;
        msg_vel.Linear.Z=0;

        msg_vel.Angular.X=0;
        msg_vel.Angular.Y=0;
        msg_vel.Angular.Z= abs(consigna_vel_ang);
    else
        % 2º Desplazar al amigobot
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

    % Comprobamos umbrales
    if (Edist<umbral_distancia) && (abs(Eori)<umbral_angulo)
        stop;
        recuperarPos(angulo_destino);
        break;
    else
        send(pub_vel,msg_vel);
    end

    % Temporización del bucle según el parámetro establecido en r
    waitfor(r);
end

end
