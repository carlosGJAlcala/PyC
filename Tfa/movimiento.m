leerSensores;
datos_mov.VelocidadAngular=0;
datos_mov.angulo=0;
datos_mov.velocidad_Lineal=0;
datos_mov.distancia=0;
ruta=zeros(1000,1000);
contador=0;
contador=contador+1;


datos_mov.VelocidadAngular==input('Introduzca la velocidad angular ')
datos_mov.angulo=input('Introduzca el angulo ')
t=girar(datos_mov);
ruta(contador)=t;

