coordenas_dst=[3,4];
coordenas_src=[1,3];
coordenas_curren=coordenas_src;
ini_simulador;
casillaInicial=casilla(coordenas_src);
casillaActual=casillaInicial;
casillaFinal=casilla(coordenas_dst);

while(~casillaFinal.isEqualCasilla(casillaActual))
    casillaActual=casillaActual.calcularResistencia(coordenas_dst);
    casillaActual=casillaActual.setcodParedes(lee_sensores);
    casillaActual= casillaActual.generarCasillaHijas(coordenas_dst);
    
    casillaHijaAux=casillaActual.obtenerCasillaHijaConMenorResistencia();
    moverRobot(casillaHijaAux.Coordenadas(1),casillaHijaAux.Coordenadas(2));
    casillaActual=casillaHijaAux;
end





