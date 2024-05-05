
%% Devuelve un array con la codificación de las paredes en el sentido de las aujas del reloj
function resultadoMapa=obtenerCodCasilla()
ini_simulador;
lee_sensores;

%sonar=1=>Mide Sonar, sonar=0=>Mide Laseres
sonar=1;
sensorAMedir=sub_laser;
if sonar
    distancia0=msg_sonar0.Range_;
    distancia1=msg_sonar1.Range_;
    distancia2=msg_sonar2.Range_;
    distancia3=msg_sonar3.Range_;
    distancia4=msg_sonar4.Range_;
    distancia5=msg_sonar5.Range_;
    distancia6=msg_sonar6.Range_;
    distancia7=msg_sonar7.Range_;
    % disp(sprintf('\t distancias Sonar-7:%f %f %f %f %f %f %f %f',distancia0,distancia1,distancia2,distancia3,distancia4,distancia5,distancia6,distancia7));
    sensorAMedir=sub_sonar0;
else
    distancia0=msg_laser.Ranges(300);
    distancia1=msg_laser.Ranges(250);
    distancia2=msg_laser.Ranges(200);
    distancia3=msg_laser.Ranges(150);
    distancia4=msg_laser.Ranges(100);
    distancia5=msg_laser.Ranges(50);
    distancia6=msg_laser.Ranges(400);
    distancia7=msg_laser.Ranges(350);
    % disp(sprintf('\t distancias Laser-7:%f %f %f %f %f %f %f %f',distancia0,distancia1,distancia2,distancia3,distancia4,distancia5,distancia6,distancia7));
end
% plot(msg_laser,'MaximumRange',8);
resultado=codificacionLocalizacionLocal(distancia0,distancia1,distancia2,distancia3,distancia4,distancia5,distancia6,distancia7,sonar);
resultadoMapa=resultado.combinacionIdentificada.arreglo;
end
%  vector=muestrearMilMedidas(sensorAMedir, sonar);
%  plot(vector);
%  title('Medidas de Distancia  0');
%  xlabel('Número de Medida');
%  ylabel('Distancia (m)');
%
%  vectorsuavizado=mediamovil5(vector);
%resultadoParalelo=IsParallel(distancia0,distancia1,distancia2,distancia3,distancia4,distancia5,distancia6,distancia7,sonar);

%% Funcion codificacionLocalizacionLocal
% Devuelve la codificación del numero de parededes identificadas
%y también devuelve el grado confianza de estas medidas
function resultado=codificacionLocalizacionLocal(num0,num1,num2,num3,num4,num5,num6,num7,sonar)

datos.gradoConfianza=[0,0,0,0];
idCombinacional=identificacionCombinacional(num0,num1,num2,num3,num4,num5,num6,num7,sonar);
datos.combinacionIdentificada=idCombinacional;
if idCombinacional.numeroComb~=0
    pendientes=obtenerPendientes(num0,num1,num2,num3,num4,num5,num6,num7,sonar);
    pendienteIzq=pendientes(1);
    pendienteFrente=pendientes(3);
    pendienteDerecha=pendientes(5);
    pendienteAtras=pendientes(7);
    pendientes=[pendienteIzq,pendienteAtras,pendienteDerecha,pendienteFrente];
    gradoConfPared=gradoConfianza(pendientes,idCombinacional.arreglo);

    datos.gradoConfianza=gradoConfPared;
end
resultado=datos;
end
%% Funcion Grado de confianza
% Recibe como paramentros tanto un arreglo de pendiente como un
%arreglo que indica la combinación de paredes en la que se encuentra, a
%partir de eso calcula la probabilidad que se encuentre en dicha casilla
function resultado=gradoConfianza(pendientes, idcombinacional)

pendienteIzq=pendientes(1);
pendienteFrente=pendientes(4);
pendienteDerecha=pendientes(3);
pendienteAtras=pendientes(2);

porcentajePendienteAtras=0;
porcentajePendienteDerecha=0;
porcentajePendienteFrente=0;
porcentajePendienteIzq=0;
if idcombinacional(1)

    porcentajePendienteIzq= compararPendiente(pendienteIzq);
end
if idcombinacional(2)
    porcentajePendienteAtras= compararPendiente(1/pendienteAtras);
end
if idcombinacional(3)

    porcentajePendienteDerecha= compararPendiente(pendienteDerecha);

end
if idcombinacional(4)
    porcentajePendienteFrente= compararPendiente(1/pendienteFrente);
end
resultado=(porcentajePendienteFrente+porcentajePendienteDerecha+porcentajePendienteAtras+porcentajePendienteIzq)/sum(idcombinacional);

end
%% Función comparacion
% Comparamos la pendiente obtenida con una pendiente de referencia, si se
% parece darán un valor cercano a 1 , si no parecido a 0 , al ser
% pendientes que se toman como si estuvieran en paralelo al robot, van ser
% pendientes cercanas a cero y la pendiente de referencia se toma como idealmente cero,
% por lo tanto para no tener que evaluar valor de 0/0 sumamos un uno tanto a la pendiente
% de referencia como a la pendiente a medir
function resultado= compararPendiente(pendiente)
pendienteRef=0+1;
resultado= (pendienteRef)/(abs(pendiente)+1);
end

function resultado= compararPendienteParalelas(pendiente, pendiente2)
if abs(pendiente) > abs(pendiente2)
    resultado= abs(pendiente2)/(abs(pendiente));
else
    resultado= abs(pendiente)/(abs(pendiente2));
end
end

%% función de identificacionCombinacional
%función que devuelve la codificación de las paredes en un arreglo dicho
%arreglo lo devolverá en el siguiente orden [paredIzquierda,paredAtras,paredDerecha,paredEnFrente]
function resultado=obtenerangulo(vector)
if vector.x==0
    resultado=pi/2;
else
    resultado=atan(vector.y/vector.x);
end
end
function resultado=hallarVector(x1,y1,x2,y2)
vector.x=x2-x1;
vector.y=y2-y1;
resultado=vector;
end
function resultado=hallarNumeroRot(angulo)
% el punto está arriba
if(3*pi/4<angulo)&&(angulo<pi/4)
    resultado=0;
% el punto en la derecha
elseif (pi/4>angulo)&&(angulo<-pi/4)
    resultado=1;
elseif (-pi/4>angulo)&&(angulo<-3*pi/4)
        resultado=2;
elseif (-3*pi/4>angulo)&&(angulo<3*pi/4)
    resultado=3;
end
end

%% TODO hacer que la codificación de las paredes tenga en cuenta la posición
%%relativa del robot

function resultadoArray=identificacionCombinacionalGlobal(num0,num1,num2,num3,num4,num5,num6,num7,sonar)
ini_simulador;
leerSensores;

variable0=realToBinary(num0)*num0;
variable1=realToBinary(num1)*num1;
variable2=realToBinary(num2)*num2;
variable3=realToBinary(num3)*num3;
variable4=realToBinary(num4)*num4;
variable5=realToBinary(num5)*num5;
variable6=realToBinary(num6)*num5;
variable7=realToBinary(num7)*num6;

puntos=obtenerPuntosGlobales(variable0,variable1,variable2,variable3,variable4,variable5,variable6,variable7);
resultado=identificacionCombinacional(num0,num1,num2,num3,num4,num5,num6,num7,sonar);
datos=resultado.arreglo;

punto.x=sub_odom.LatestMessage.Pose.Pose.Position.X;
punto.y=sub_odom.LatestMessage.Pose.Pose.Position.Y;

vector=puntos(1).x;
vector=puntos(1).y;
angulo=obtenerangulo(vector);
numrot=hallarNumeroRot(angulo);
pared1=variable2;
pared2=variable4;
pared3=variable6;
pared4=variable0;

arreglo=[pared4,pared3,pared2,pared1];

resultadoArray=arreglo;
end
function resultadoArray=identificacionCombinacional(num0,num1,num2,num3,num4,num5,num6,num7,sonar)

variable0=realToBinary(num0);
variable1=realToBinary(num1);
variable2=realToBinary(num2);
variable3=realToBinary(num3);
variable4=realToBinary(num4);
variable5=realToBinary(num5);
variable6=realToBinary(num6);
variable7=realToBinary(num7);
datos.arreglo=[];
datos.numeroComb=0;
if sonar
    pared1=0;
    pared2=variable5;
    pared3=0;
    pared4=variable0;

    if variable2==1&variable3==1
        pared1=1;
    end

    if variable6==1&variable7==1
        pared3=1;
    end
else
    pared1=variable2;
    pared2=variable4;
    pared3=variable6;
    pared4=variable0;
end
arregloT=[pared4,pared3,pared2,pared1];
datos.arreglo=arregloT;
datos.numeroComb=deco(arregloT);
resultadoArray=datos;
end
%% funcion decodificadora,
% Se le pasa un arreglo compuesto por las paredes y
%devuelve un numero correspondiente a su codificación que viene el pdf de
%la práctica
function resultado=deco(arreglo)
str_arreglo=num2str(arreglo);
str_arreglo(isspace(str_arreglo)) = '';
dec=bin2dec(str_arreglo);
if dec==3
    resultado=5;
elseif dec==4
    resultado=3;
elseif dec==5
    resultado=6;
elseif dec==6
    resultado=8;
elseif dec==7
    resultado=11;
elseif dec==8
    resultado=4;
elseif dec==9
    resultado=7;
elseif dec==10
    resultado=9;
elseif dec==11
    resultado=14;
elseif dec == 12
    resultado=10;
elseif dec ==14
    resultado=12;
else
    resultado=dec;
end
end
%% Función ResultadoToBinario
% funcion que devuelve un uno si el sonar y el laser devuelven una
% distancia menor a uno
function resultadoToBinario=realToBinary(numeroReal)
if(numeroReal<1.3)
    resultadoToBinario= 1;

else
    resultadoToBinario= 0;

end
end
%% Función muestrearMilMedidas
%función que muestra mil medidas ya sea del sensor o del sonar, esta
%funcion tiene dos modos, modo sonar o modo sensor esto depende del segundo
%parametro
function resultado=muestrearMilMedidas(sensor,sonar)
medidasSensor = zeros(1, 1000);
for i = 1:1000
    msg_sensor = receive(sensor,1);
    if(sonar)
        medidasSensor(i) = msg_sensor.Range_;
    else
        medidasSensor(i) = msg_sensor.Ranges(100);
    end
end
resultado=medidasSensor;
end

%% funcion IsParallel
%fucnión que compara las pendientes un lado y de otro para medir si el
%robot está en paralelo, está función tienes dos modo s uno con el modo
%sonar y otro con el modo laser
function resultado=IsParallel(num0,num1,num2,num3,num4,num5,num6,num7,sonar)
pendientes=obtenerPendientes(num0,num1,num2,num3,num4,num5,num6,num7,sonar);
pendiente1=pendientes(1);
pendiente3=pendientes(3);
pendiente5=pendientes(5);
pendiente7=pendientes(7);
gradoConf_LadosIzqDer= compararPendienteParalelas(1/pendiente1,1/pendiente5);
gradoConf_LadosDelanteAtras=compararPendienteParalelas(pendiente3,pendiente7);
resultado=[gradoConf_LadosIzqDer,gradoConf_LadosDelanteAtras];
end
%% función obtenerPendientes
%Función que devuleve las pendiente a partir de de unas medidas hechas,
%tiene dos modos un modo laser y otro modo sonar
%%TODO
function resultado= obtenerPuntosGlobales(num0,num1,num2,num3,num4,num5,num6,num7)
anguloCono=0.261799;
anglesensor0=1.5708;
anglesensor1=0.715585;
anglesensor2=0.261799;
anglesensor3=-0.261799;
anglesensor4=-1*anglesensor1;
anglesensor5=-1*anglesensor0;
anglesensor6=-2.53073;
anglesensor7=-1*anglesensor6;

sensor0X=0.076;
sensor0Y=0.1;

sensor0XR=num0*cos(anguloCono/2);
sensor0YR=num0*sin(anguloCono/2);

sensor1X=0.125;
sensor1Y=0.075;
sensor1XR=num1*cos(anguloCono);
sensor1YR=num1*sin(anguloCono);
sensor2X=0.15;
sensor2Y=0.03;
sensor2XR=num2*cos(anguloCono);
sensor2YR=num2*sin(anguloCono);
sensor3X=0.15;
sensor3Y=-0.03;


sensor3XR=num3*cos(anguloCono);
sensor3YR=num3*sin(anguloCono);
sensor4X=0.125;
sensor4Y=-0.075;

sensor4XR=num4*cos(anguloCono);
sensor4YR=num4*sin(anguloCono);
sensor5X=0.076;
sensor5Y=-0.1;
sensor5XR=num5*cos(anguloCono/2);
sensor5YR=num5*sin(anguloCono/2);

sensor6X=-0.14;
sensor6Y=-0.058;

sensor6XR=num6*cos(anguloCono);
sensor6YR=num6*sin(anguloCono);
sensor7X=-0.14;
sensor7Y=0.058;

sensor7XR=num7*cos(anguloCono);
sensor7YR=num7*sin(anguloCono);

valt0=obtenerPuntosGlobal(anglesensor0,sensor0YR,sensor0XR,sensor0X,sensor0Y);
punto0.x=valt0(1);
punto0.y=valt0(2);


valt1=obtenerPuntosGlobal(anglesensor1,sensor1YR,sensor1XR,sensor1X,sensor1Y);
punto1.x=valt1(1);
punto1.y=valt1(2);




valt2=obtenerPuntosGlobal(anglesensor2,sensor2YR,sensor2XR,sensor2X,sensor2Y);
punto2.x=valt2(1);
punto2.y=valt2(2);


valt3=obtenerPuntosGlobal(anglesensor3,sensor3YR,sensor3XR,sensor3X,sensor3Y);
punto3.x=valt3(1);
punto3.y=valt3(2);

valt4=obtenerPuntosGlobal(anglesensor4,sensor4YR,sensor4XR,sensor4X,sensor4Y);
punto4.x=valt4(1);
punto4.y=valt4(2);



valt5=obtenerPuntosGlobal(anglesensor5,sensor5YR,sensor5XR,sensor5X,sensor5Y);
punto5.x=valt5(1);
punto5.y=valt5(2);


valt6=obtenerPuntosGlobal(anglesensor6,sensor6YR,sensor6XR,sensor6X,sensor6Y);
punto6.x=valt6(1);
punto6.y=valt6(2);
pendiente6=calcularPendiente(punto6,punto5);


valt7=obtenerPuntosGlobal(anglesensor7,sensor7YR,sensor7XR,sensor7X,sensor7Y);
punto7.x=valt7(1);
punto7.y=valt7(2);
resultado= [punto1,punto2,punto3,punto4,punto5,punto6,punto7];

end
function resultado=obtenerPendientes(num0,num1,num2,num3,num4,num5,num6,num7,sonar)


if sonar
    anguloCono=0.261799;
    anglesensor0=1.5708;
    anglesensor1=0.715585;
    anglesensor2=0.261799;
    anglesensor3=-0.261799;
    anglesensor4=-1*anglesensor1;
    anglesensor5=-1*anglesensor0;
    anglesensor6=-2.53073;
    anglesensor7=-1*anglesensor6;

    sensor0X=0.076;
    sensor0Y=0.1;

    sensor0XR=num0*cos(anguloCono/2);
    sensor0YR=num0*sin(anguloCono/2);

    sensor1X=0.125;
    sensor1Y=0.075;
    sensor1XR=num1*cos(anguloCono);
    sensor1YR=num1*sin(anguloCono);
    sensor2X=0.15;
    sensor2Y=0.03;
    sensor2XR=num2*cos(anguloCono);
    sensor2YR=num2*sin(anguloCono);
    sensor3X=0.15;
    sensor3Y=-0.03;


    sensor3XR=num3*cos(anguloCono);
    sensor3YR=num3*sin(anguloCono);
    sensor4X=0.125;
    sensor4Y=-0.075;

    sensor4XR=num4*cos(anguloCono);
    sensor4YR=num4*sin(anguloCono);
    sensor5X=0.076;
    sensor5Y=-0.1;
    sensor5XR=num5*cos(anguloCono/2);
    sensor5YR=num5*sin(anguloCono/2);

    sensor6X=-0.14;
    sensor6Y=-0.058;

    sensor6XR=num6*cos(anguloCono);
    sensor6YR=num6*sin(anguloCono);
    sensor7X=-0.14;
    sensor7Y=0.058;

    sensor7XR=num7*cos(anguloCono);
    sensor7YR=num7*sin(anguloCono);

else
    anglePose=pi;
    anglesensor0=anglePose;
    anglesensor1=anglePose;
    anglesensor2=anglePose;
    anglesensor3=anglePose;
    anglesensor4=anglePose;
    anglesensor5=anglePose;
    anglesensor6=anglePose;
    anglesensor7=anglePose;
    poseX=0.09;
    sensor0X=poseX;
    sensor0Y=0;
    sensor0XR=num0*cos(0.5*pi);
    sensor0YR=num0*sin(0.5*pi);

    sensor1X=poseX;
    sensor1Y=0;
    sensor1XR=num2*cos((1/4)*pi);
    sensor1YR=num2*sin((1/4)*pi);

    sensor2X=poseX;
    sensor2Y=0;
    sensor2XR=num2*cos(0);
    sensor2YR=num2*sin(0);

    sensor3X=poseX;
    sensor3Y=0;
    sensor3XR=num3*cos(-(1/4)*pi);
    sensor3YR=num3*sin(-(1/4)*pi);

    sensor4X=poseX;
    sensor4Y=0;

    sensor4XR=num4*cos(-(1/2)*pi);
    sensor4YR=num4*sin(-(1/2)*pi);

    sensor5X=poseX;
    sensor5Y=0;
    sensor5XR=num5*cos(-(3/4)*pi);
    sensor5YR=num5*sin(-(3/4)*pi);

    sensor6X=poseX;
    sensor6Y=0;
    sensor6XR=num6*cos(pi);
    sensor6YR=num6*sin(pi);

    sensor7X=poseX;
    sensor7Y=0;

    sensor7XR=num7*cos((3/4)*pi);
    sensor7YR=num7*sin((3/4)*pi);
end

valt0=obtenerPuntosGlobal(anglesensor0,sensor0YR,sensor0XR,sensor0X,sensor0Y);
punto0.x=valt0(1);
punto0.y=valt0(2);


valt1=obtenerPuntosGlobal(anglesensor1,sensor1YR,sensor1XR,sensor1X,sensor1Y);
punto1.x=valt1(1);
punto1.y=valt1(2);




valt2=obtenerPuntosGlobal(anglesensor2,sensor2YR,sensor2XR,sensor2X,sensor2Y);
punto2.x=valt2(1);
punto2.y=valt2(2);


valt3=obtenerPuntosGlobal(anglesensor3,sensor3YR,sensor3XR,sensor3X,sensor3Y);
punto3.x=valt3(1);
punto3.y=valt3(2);

valt4=obtenerPuntosGlobal(anglesensor4,sensor4YR,sensor4XR,sensor4X,sensor4Y);
punto4.x=valt4(1);
punto4.y=valt4(2);



valt5=obtenerPuntosGlobal(anglesensor5,sensor5YR,sensor5XR,sensor5X,sensor5Y);
punto5.x=valt5(1);
punto5.y=valt5(2);




valt6=obtenerPuntosGlobal(anglesensor6,sensor6YR,sensor6XR,sensor6X,sensor6Y);
punto6.x=valt6(1);
punto6.y=valt6(2);
pendiente6=calcularPendiente(punto6,punto5);


valt7=obtenerPuntosGlobal(anglesensor7,sensor7YR,sensor7XR,sensor7X,sensor7Y);
punto7.x=valt7(1);
punto7.y=valt7(2);

pendiente1=calcularPendiente(punto0,punto1);
pendiente2=calcularPendiente(punto1,punto2);
pendiente3=calcularPendiente(punto2,punto3);
pendiente4=calcularPendiente(punto3,punto4);
pendiente5=calcularPendiente(punto4,punto5);
pendiente6=calcularPendiente(punto5,punto6);
pendiente7=calcularPendiente(punto6,punto7);
pendiente8=calcularPendiente(punto7,punto0);
datos=[pendiente1,pendiente2,pendiente3,pendiente4,pendiente5,pendiente6,pendiente7,pendiente8];
resultado=datos;

end
%% funcion calcularPendiente
%función que implementa la formula de calcular la pendiente y2-y1/x2-x1
function resultado=calcularPendiente(punto1,punto2)
resultado=(punto2.y-punto1.y)/(punto2.x-punto1.x);
end
%% funcion obtenerPuntosGlobal
%funcion que realiza la transformación de las cordenadas de los sensores a
%las coordenadas del robot
function resultado=obtenerPuntosGlobal(angulo,yr,xr,x,y )
ini_simulador;
x=x+sub_odom.LatestMessage.Pose.Pose.Position.X;
y=y+sub_odom.LatestMessage.Pose.Pose.Position.Y;
matrizrot=[cos(angulo),-sin(angulo);
    sin(angulo),cos(angulo)];

resultado = (matrizrot*[xr;yr])+[x;y];
end
%% función mediamovil5
%Media movil con ventana de 5 periodos, suaviza la funcion y quita el ruido
function resultado = mediamovil5(vector)
vectort=zeros(1,1000);

for i=6:1000
    sumatorio = 0;

    for j=1:5
        sumatorio = sumatorio+vector(i-j);
    end
    vectort(i)=sumatorio/5;
end
resultado = vectort;
figure;
plot(resultado);
title('Medidas de Distancia del Laser 0 suave');
xlabel('Número de Medida');
ylabel('Distancia (m)');
end
