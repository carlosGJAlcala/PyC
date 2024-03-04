

%Lectura de sensores
msg_sonar0 = sub_sonar0.LatestMessage;
%msg_sonar0 = receive(sub_sonar0, 10);
msg_sonar1 = sub_sonar1.LatestMessage;
msg_sonar2 = sub_sonar2.LatestMessage;
msg_sonar3 = sub_sonar3.LatestMessage;
msg_sonar4 = sub_sonar4.LatestMessage;
msg_sonar5 = sub_sonar5.LatestMessage;
msg_sonar6 = sub_sonar6.LatestMessage;
msg_sonar7 = sub_sonar7.LatestMessage;

%msg_laser
msg_laser = sub_laser.LatestMessage;

%Representacion gráfica de los datos del laser.
plot(msg_laser,'MaximumRange',8);
%Mostramos  lecturas del sonar
% disp(sprintf('\tSONARES_0-7:%f %f %f %f %f %f %f %f',msg_sonar0.Range_,msg_sonar1.Range_,msg_sonar2.Range_,msg_sonar3.Range_,msg_sonar4.Range_,msg_sonar5.Range_,msg_sonar6.Range_,msg_sonar7.Range_));

resultadoMapa=codificacionLocalizacionLocal(msg_sonar0.Range_,msg_sonar1.Range_,msg_sonar2.Range_,msg_sonar3.Range_,msg_sonar4.Range_,msg_sonar5.Range_,msg_sonar6.Range_,msg_sonar7.Range_);
% vector=muestrearMilMedidas(sub_sonar0);
%  vectorsuavizado=mediamovil5(vector);
 resultadoParalelo=IsParallel(msg_sonar0.Range_,msg_sonar1.Range_,msg_sonar2.Range_,msg_sonar3.Range_,msg_sonar4.Range_,msg_sonar5.Range_,msg_sonar6.Range_,msg_sonar7.Range_);

function resultado=codificacionLocalizacionLocal(num0,num1,num2,num3,num4,num5,num6,num7)
pared1=0;
pared2=0;
pared3=0;
pared4=0;
datos.gradoConfianza=[];
idCombinacional=identificacionCombinacional(num0,num1,num2,num3,num4,num5,num6,num7);
datos.combinacionIdentificada=idCombinacional;
if idCombinacional.numeroComb~=0
pendientes=obtenerPendientes(num0,num1,num2,num3,num4,num5,num6,num7);
pendiente1=pendientes(1);
pendiente2=pendientes(2);
pendiente3=pendientes(3);
pendiente4=pendientes(4);
pendiente5=pendientes(5);
pendiente6=pendientes(6);
pendiente7=pendientes(7);
pendiente8=pendientes(8);
vector=IsParallel(num0,num1,num2,num3,num4,num5,num6,num7);
% gradoConfPared1=gradoConfianza(pendiente2,pendiente4);
% gradoConfPared2=gradoConfianza(pendiente5,pendiente6);
% gradoConfPared3=gradoConfianza(pendiente6,pendiente8);
% gradoConfPared4=gradoConfianza(pendiente8,pendiente1);
gradoConfPared1=vector(2);
gradoConfPared2=vector(1);
gradoConfPared3=vector(2);
gradoConfPared4=vector(1);
datos.gradoConfianza=[gradoConfPared4,gradoConfPared3,gradoConfPared2,gradoConfPared1];

end

resultado=datos;
end

function resultadoArray=identificacionCombinacional(num0,num1,num2,num3,num4,num5,num6,num7)
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
pared1=0;
pared2=variable5;
pared3=0;
pared4=variable0;


if variable2==1|variable3==1
    pared1=1;
end


if variable6==1|variable7==1
    pared3=1;
end
arreglo=[pared4,pared3,pared2,pared1];
str_arreglo=num2str(arreglo);
str_arreglo(isspace(str_arreglo)) = '';
datos.arreglo=arreglo;
dec=bin2dec(str_arreglo);
if dec==3
   datos.numeroComb=5;
elseif dec==4
    datos.numeroComb=3;
elseif dec==5
    datos.numeroComb=6;
elseif dec==6
    datos.numeroComb=8;
elseif dec==7
    datos.numeroComb=11;
elseif dec==8
    datos.numeroComb=4;
elseif dec==9
    datos.numeroComb=7;
elseif dec==10
    datos.numeroComb=9;
elseif dec==11
    datos.numeroComb=14;
elseif dec == 12
    datos.numeroComb=10;
elseif dec ==14
    datos.numeroComb=12;
else
   datos.numeroComb=dec;
end

resultadoArray=datos;
end
function resultadoToBinario=realToBinary(numeroReal)
if(numeroReal<4)
    resultadoToBinario= 1;

else
    resultadoToBinario= 0;

end
end
function resultado=muestrearMilMedidas(sub_sonar0)
medidas_sonar0 = zeros(1, 1000);
for i = 1:1000
    msg_sonar0 = receive(sub_sonar0,10);
    medidas_sonar0(i) = msg_sonar0.Range_;
end
resultado=medidas_sonar0;
% Representación gráfica de los datos del sonar 0
plot(medidas_sonar0);
title('Medidas de Distancia del Sonar 0');
xlabel('Número de Medida');
ylabel('Distancia (m)');
end

function resultado=gradoConfianza(pendiente1, pendiente2)
numerador=0;
denominador=0;
pendiente1=abs(pendiente1);
pendiente2=abs(pendiente2);
if (pendiente1) <(pendiente2)
    denominador=pendiente2;
    numerador=pendiente1;
else
    denominador=pendiente1;
    numerador=pendiente2;
end
resultado=1-(denominador-numerador)/denominador;
end
function resultado=IsParallel(num0,num1,num2,num3,num4,num5,num6,num7)
pendientes=obtenerPendientes(num0,num1,num2,num3,num4,num5,num6,num7);
pendiente1=pendientes(1);
pendiente3=pendientes(3);
pendiente5=pendientes(5);
pendiente7=pendientes(7);
gradoConf_LadosIzqDer=gradoConfianza(pendiente1,pendiente5);
gradoConf_LadosDelanteAtras=gradoConfianza(-1/pendiente3,-1/pendiente7);
resultado=[gradoConf_LadosIzqDer,gradoConf_LadosDelanteAtras];
end

function resultado=obtenerPendientes(num0,num1,num2,num3,num4,num5,num6,num7)
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
valt0=obtenerPuntosGlobal(anglesensor0,sensor0YR,sensor0XR,sensor0X,sensor0Y);
punto0.x=valt0(1);
punto0.y=valt0(2);

sensor1X=0.125;
sensor1Y=0.075;
sensor1XR=num1*cos(anguloCono);
sensor1YR=num1*sin(anguloCono);
valt1=obtenerPuntosGlobal(anglesensor1,sensor1YR,sensor1XR,sensor1X,sensor1Y);
punto1.x=valt1(1);
punto1.y=valt1(2);


sensor2X=0.15;
sensor2Y=0.03;
sensor2XR=num2*cos(anguloCono);
sensor2YR=num2*sin(anguloCono);
valt2=obtenerPuntosGlobal(anglesensor2,sensor2YR,sensor2XR,sensor2X,sensor2Y);
punto2.x=valt2(1);
punto2.y=valt2(2);

sensor3X=0.15;
sensor3Y=-0.03;
sensor3XR=num3*cos(anguloCono);
sensor3YR=num3*sin(anguloCono);
valt3=obtenerPuntosGlobal(anglesensor3,sensor3YR,sensor3XR,sensor3X,sensor3Y);
punto3.x=valt3(1);
punto3.y=valt3(2);

sensor4X=0.125;
sensor4Y=-0.075;
sensor4XR=num4*cos(anguloCono);
sensor4YR=num4*sin(anguloCono);
valt4=obtenerPuntosGlobal(anglesensor4,sensor4YR,sensor4XR,sensor4X,sensor4Y);
punto4.x=valt4(1);
punto4.y=valt4(2);

sensor5X=0.076;
sensor5Y=-0.1;
sensor5XR=num5*cos(anguloCono/2);
sensor5YR=num5*sin(anguloCono/2);
valt5=obtenerPuntosGlobal(anglesensor5,sensor5YR,sensor5XR,sensor5X,sensor5Y);
punto5.x=valt5(1);
punto5.y=valt5(2);




sensor6X=-0.14;
sensor6Y=-0.058;
sensor6XR=num6*cos(anguloCono);
sensor6YR=num6*sin(anguloCono);
valt6=obtenerPuntosGlobal(anglesensor6,sensor6YR,sensor6XR,sensor6X,sensor6Y);
punto6.x=valt6(1);
punto6.y=valt6(2);
pendiente6=calcularPendiente(punto6,punto5);

sensor7X=-0.14;
sensor7Y=0.058;
sensor7XR=num7*cos(anguloCono);
sensor7YR=num7*sin(anguloCono);
valt7=obtenerPuntosGlobal(anglesensor7,sensor7YR,sensor7XR,sensor7X,sensor7Y);
punto7.x=valt7(1);
punto7.y=valt7(2);

pendiente1=calcularPendiente(punto0,punto1);
pendiente2=calcularPendiente(punto1,punto2);
pendiente3=calcularPendiente(punto2,punto3);
pendiente4=calcularPendiente(punto4,punto5);
pendiente5=calcularPendiente(punto5,punto6);
pendiente7=calcularPendiente(punto6,punto7);
pendiente8=calcularPendiente(punto7,punto0);


resultado=[pendiente1,pendiente2,pendiente3,pendiente4,pendiente5,pendiente6,pendiente7,pendiente8];
end
function resultado=calcularPendiente(punto1,punto2)
resultado=(punto2.y-punto1.y)/(punto2.x-punto1.x);
end
function resultado=obtenerPuntosGlobal(angulo,yr,xr,x,y )
matrizrot=[cos(angulo),-sin(angulo);
          sin(angulo),cos(angulo)]

resultado = (matrizrot*[xr;yr])+[x;y];
end

function resultado=calculateHypotenuse(angle,side)
resultado=side /cos(angle)

end
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
title('Medidas de Distancia del Sonar 0 suave');
xlabel('Número de Medida');
ylabel('Distancia (m)');
end





