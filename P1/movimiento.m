lee_sensores;
datos_mov.VelocidadAngular=0;
datos_mov.angulo=0;
datos_mov.velocidad_Lineal=0;
datos_mov.distancia=0;
ruta=zeros(1000,1000);
contador=0;
while(1)
    contador=contador+1;
    valorGirarAvanzar=input('Introduzca un 0 avanzar , 1 girar , 2 modo test y cualquier numero para salir ')
    if valorGirarAvanzar==0
        datos_mov.distancia=input('Introduzca la distancia ')
        datos_mov.velocidad_Lineal=input('Introduzca el velocidad_Lineal ')
        ruta(contador)=avanzar(datos_mov);

    elseif valorGirarAvanzar==1
        datos_mov.VelocidadAngular==input('Introduzca la velocidad angular ')
        datos_mov.angulo=input('Introduzca el angulo ')
        t=girar(datos_mov);
        ruta(contador)=t;

    elseif valorGirarAvanzar==2
        datos_mov.velocidad_Lineal=0.3;
        datos_mov.VelocidadAngular=0.3;
        datos_mov.distancia=2;
        ruta(contador)=avanzar(datos_mov);
        contador=contador+1;
        datos_mov.angulo=90;
        ruta(contador)=girar(datos_mov);
        contador=contador+1;
        datos_mov.distancia=1;
        avanzar(datos_mov);
        datos_mov.angulo=-90;
        ruta(contador)=girar(datos_mov);
        contador=contador+1;
        ruta(contador)=avanzar(datos_mov);
        contador=contador+1;

    else
        break;

    end
end