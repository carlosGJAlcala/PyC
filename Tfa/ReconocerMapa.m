ini_simulador;
pause(3);
leerSensores;
codParedes=obtenerCodCasilla;
casillaini=casilla([pos.X,pos.Y]);
casillaTemp=casillaini;
numeroini=0;
recorrer(casillaini);
function resultado=recorrer(casilla)
ini_simulador;
leerSensores;
avanzarSiguiente(casilla);
casilla=casilla.setcodParedes(obtenerCodCasilla);
casilla=casilla.generarCasillaHijas();
arraycasillas= casilla.getCasillaHijas();
for i= 1:size(arraycasillas);   
    recorrer(arraycasillas(i));
    avanzarSiguiente(casilla);
end
resultado=casilla;
end

function resultado=IsRecorridoMapa(numeroini)
numCasillas=21;
resultado=(numCasillas==numero);
end
function resultado=avanzarSiguiente(casilla)
moverRobot(casilla.Coordenadas(1),casilla.Coordenadas(2));
end
