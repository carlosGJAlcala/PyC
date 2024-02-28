sonar.sonar0=sub_sonar0;
sonar.sonar1=sub_sonar1;
sonar.sonar2=sub_sonar2;
sonar.sonar3=sub_sonar3;
sonar.sonar4=sub_sonar4;
sonar.sonar5=sub_sonar5;
sonar.sonar6=sub_sonar6;
sonar.sonar7=sub_sonar7;

sen=sensor(sonar,sub_laser);
sen.leerSensor();

msg_vel.Linear.X=0.0;
msg_vel.Linear.Y=0.0;
msg_vel.Linear.Z=0;
msg_vel.Angular.X=0.0;
msg_vel.Angular.Y=0;
msg_vel.Angular.Z=0;

datos_mov.VelocidadAngular=0;
datos_mov.angulo=0;
datos_mov.velocidad_Lineal=0;
datos_mov.distancia=0;
while(1)
    valorGirarAvanzar=input('Introduzca un 1 para girar y 0 para avanzar ')
    if valorGirarAvanzar
        datos_mov.VelocidadAngular==input('Introduzca la velocidad angular ')
        datos_mov.angulo=input('Introduzca el angulo ')
        girar;
    else
        datos_mov.distancia=input('Introduzca la distancia ')
        datos_mov.velocidad_Lineal=input('Introduzca el velocidad_Lineal ')
        avanzar;
    end
end