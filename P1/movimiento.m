
datos_mov.VelocidadAngular=0;
datos_mov.angulo=0;
datos_mov.velocidad_Lineal=0;
datos_mov.distancia=0;
while(1)
    valorGirarAvanzar=input('Introduzca un 1 para girar y 0 para avanzar ')
    if valorGirarAvanzar
        datos_mov.VelocidadAngular==input('Introduzca la velocidad angular ')
        datos_mov.angulo=input('Introduzca el angulo ')
        girar(datos_mov);
    else
        datos_mov.distancia=input('Introduzca la distancia ')
        datos_mov.velocidad_Lineal=input('Introduzca el velocidad_Lineal ')
        avanzar(datos_mov);
    end
end