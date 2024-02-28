

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
disp(sprintf('\tSONARES_0-7:%f %f %f %f %f %f %f %f',msg_sonar0.Range_,msg_sonar1.Range_,msg_sonar2.Range_,msg_sonar3.Range_,msg_sonar4.Range_,msg_sonar5.Range_,msg_sonar6.Range_,msg_sonar7.Range_));

% resultadoMapa=codificacionLocalizacionLocal(msg_sonar0.Range_,msg_sonar1.Range_,msg_sonar2.Range_,msg_sonar3.Range_,msg_sonar4.Range_,msg_sonar5.Range_,msg_sonar6.Range_,msg_sonar7.Range_);
%resultado1=muestrearMilMedidas(sub_sonar0);
% resultadoParalelo=IsParallel(msg_sonar0.Range_,msg_sonar1.Range_,msg_sonar4.Range_,msg_sonar5.Range_,msg_sonar6.Range_,msg_sonar7.Range_);



function resultadoArray=codificacionLocalizacionLocal(num0,num1,num2,num3,num4,num5,num6,num7)
variable0=realToBinary(num0);
variable1=realToBinary(num1);
variable2=realToBinary(num2);
variable3=realToBinary(num3);
variable4=realToBinary(num4);
variable5=realToBinary(num5);
variable6=realToBinary(num6);
variable7=realToBinary(num7);

pared1=0;
pared2=0;
pared3=0;
pared4=0;

pared1=variable0;
if variable2==1|variable3==1
    pared2=1;
end
pared3=variable5;

if variable6==1|variable7==1
    pared4=1;
end


resultadoArray=[pared1,pared2,pared3,pared4];
end
function resultadoToBinario=realToBinary(numeroReal)
if(numeroReal<4)
    resultadoToBinario= 1;

else
    resultadoToBinario= 0;

end
end
function resultado=muestrearMilMedidas(sub_sonar0)

% Inicialización del array para las lecturas del sonar
medidas_sonar0 = zeros(1, 1000);

% Bucle para recoger 1.000 medidas
for i = 1:1000
    % Recoger la lectura actual del sonar 0
    % msg_sonar0 = receive(sub_sonar0, 10);
    msg_sonar0 = sub_sonar0.LatestMessage;
    % Guardar la distancia medida en el array
    medidas_sonar0(i) = msg_sonar0.Range_;
end

% Representación gráfica de los datos del sonar 0
plot(medidas_sonar0);
title('Medidas de Distancia del Sonar 0');
xlabel('Número de Medida');
ylabel('Distancia (m)');
end

function resultado=IsParallel(num0,num1,num4,num5,num6,num7)
margenError=0.05*5;
anglesensor0=1.5708;
anglesensor1=0.715585;
anglesensor4=-1*anglesensor1;
anglesensor5=-1*anglesensor0;
anglesensor6=-2.53073;
anglesensor7=-1*anglesensor6;
num1Fict=calculateHypotenuse(abs(anglesensor1-anglesensor0),num0);
num7Fict=calculateHypotenuse(abs(anglesensor7-anglesensor0),num0);
num4Fict=calculateHypotenuse(abs(anglesensor4-anglesensor5),num5);
num6Fict=calculateHypotenuse(abs(anglesensor6-anglesensor5),num5);
valeu1=(abs(num1-num1Fict)<margenError);
valeu2=(abs(num7-num7Fict)<margenError);
valeu3=(abs(num4-num4Fict)<margenError);
valeu4=(abs(num6-num6Fict)<margenError);

if valeu1 | valeu2 | valeu3| valeu4
    resultado=true;
else
    resultado=false;
end



end
function resultado=calculateHypotenuse(angle,side)
resultado=side /cos(angle)

end




