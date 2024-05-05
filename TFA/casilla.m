classdef casilla < handle
    properties
        Visitada = 0
        Conexiones % Mapa de conexiones con direcciones
        DireccionDestino
        EsSalida = 0;
    end

    methods
        function obj = casilla()
            % Inicializar el mapa de conexiones
            obj.Conexiones = containers.Map('KeyType', 'char', 'ValueType', 'any');
            obj.Visitada = 0;
            obj.DireccionDestino = '';
            obj.EsSalida = 0;
        end

        function obj = agregarConexion(obj, direccion, casilla)
            % Añadir una conexión en una dirección específica
            obj.Conexiones(direccion) = casilla;
        end

        function obj = agregarConexiones(obj, direccionesLibres)
            for i = 1:length(direccionesLibres)
                casilla_hija = casilla();
                casilla_hija.setDireccionDestino(direccionesLibres{i});
                obj.Conexiones(direccionesLibres{i}) = casilla_hija;
            end
        end

        function casilla = obtenerConexion(obj, direccion)
            % Obtener la casilla conectada en una dirección específica
            if obj.Conexiones.isKey(direccion)
                casilla = obj.Conexiones(direccion);
            else
                casilla = [];  % Devuelve vacío si no hay conexión en esa dirección
            end
        end

        function arrayConexiones = obtenerTodasConexiones(obj)
            arrayConexiones = obj.Conexiones;
        end

        function estado = setVisitada(obj)
            obj.Visitada = 1;
            estado = obj.Visitada;
        end

        function estado = getVisitada(obj)
            estado = obj.Visitada;
        end

        function setDireccionDestino(obj, direccionDest)
            obj.DireccionDestino = direccionDest;
        end

        function direccion = getDireccionDestino(obj)
            direccion = obj.DireccionDestino;
        end


        function setEsSalida(obj)
            obj.EsSalida = 1;
        end

        function esSalida = getEsSalida(obj)
            esSalida = obj.EsSalida;
        end

    end
end


