classdef casilla
    %CASILLA Summary of this class goes here
    %   Detailed explanation goes here

    properties
        Coordenadas;
        Resistencia;
        isRecorrida;
        codParedes;
        casillasHijas;
    end

    methods
        function obj = casilla(Coordenadas)
            %CASILLA Construct an instance of this class
            %   Detailed explanation goes here
            obj.Resistencia = 0;
            obj.Coordenadas = Coordenadas;
            obj.isRecorrida = 0;
            obj.codParedes=[0,0,0,0];
        end

        function obj = getResistencia(obj)
            obj = obj.Resistencia;
        end
        function obj = setResistencia(obj,nuevaResistencia)
            obj.Resistencia = nuevaResistencia;
        end
        function obj = calcularResistencia(obj,dst)
            obj.Resistencia = sqrt((dst(1) - obj.Coordenadas(1))^2 + (dst(2) -obj.Coordenadas(2))^2)+2 ;

        end
        function obj = getisRecorrida(obj)
            obj = obj.isRecorrida;
        end
        function obj = setisRecorrida(obj,nuevaisRecorrida)
            obj.isRecorrida = nuevaisRecorrida;
        end
        function obj = getcodParedes(obj)
            obj = obj.codParedes;
        end
        function obj = setcodParedes(obj,nuevacodParedes)

            obj.codParedes = nuevacodParedes;
        end
        function obj = getCasillaHijas(obj)
            obj = obj.casillasHijas;
        end
        function obj = addCasillaHija(obj,nuevaCasilla)
            obj.casillasHijas = [obj.casillasHijas,nuevaCasilla];
        end
        function resultado= obtenerCasillaHijaConMenorResistencia(obj)
            casillaAux=casilla(obj.Coordenadas);
            casillaAux=casillaAux.setResistencia(obj.getResistencia());
            for i=obj.casillasHijas
                if(i.Resistencia<casillaAux.Resistencia)
                    casillaAux=i;
                end
            end
            resultado=casillaAux;
        end
        function obj= generarCasillaHijas(obj,dst)
            derecha=obj.codParedes(4);
            abajo=obj.codParedes(3);
            izq=obj.codParedes(2);
            arriba=obj.codParedes(1);
            if(~derecha)
                nuevacasilla=casilla([obj.Coordenadas(1)+2,obj.Coordenadas(2)])
             
                obj=obj.addCasillaHija(nuevacasilla);
            end
            if(~abajo)
                nuevacasilla=casilla([obj.Coordenadas(1),obj.Coordenadas(2)-2])
                obj=obj.addCasillaHija(nuevacasilla);
            end
            if(~izq)
                nuevacasilla=casilla([obj.Coordenadas(1)-2,obj.Coordenadas(2)])
                obj=obj.addCasillaHija(nuevacasilla);
            end
            if(~arriba)
                nuevacasilla=casilla([obj.Coordenadas(1),obj.Coordenadas(2)+2])
                obj=obj.addCasillaHija(nuevacasilla);
            end

        end
        function resultado = isEqualCasilla(obj,casilla)
            if (obj.Coordenadas(1)==casilla.Coordenadas(1))&&(obj.Coordenadas(2)==casilla.Coordenadas(2))
                resultado=true;
            else
                resultado=false;
            end
        end


    end
end

