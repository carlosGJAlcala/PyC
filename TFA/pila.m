classdef pila < handle
    properties 
        Contenido  % Array que almacena los elementos de la pila
    end
    
    methods
        function obj = pila()
            % Constructor que inicializa la pila vacía
            obj.Contenido = {};
        end
        
        function obj = enpilar(obj, elemento)
            % Método para agregar un elemento al final de la pila
            obj.Contenido{end + 1} = elemento;
        end
        
        function [obj, elemento] = desenpilar(obj)
            % Método para quitar el último elemento de la pila
            if isempty(obj.Contenido)
                error('Desenpilar de una pila vacía');
            else
                elemento = obj.Contenido{end};
                obj.Contenido(end) = [];  % Elimina el último elemento
            end
        end
        
         function elemento = obtenerTop(obj)
            % Método para ver el último elemento sin eliminarlo
            if isempty(obj.Contenido)
                error('Pila vacía, no se puede obtener el tope');
                elemento = [];
            else
                elemento = obj.Contenido{end};
            end
        end
        
        function esVacia = estaVacia(obj)
            % Método para verificar si la pila está vacía
            esVacia = isempty(obj.Contenido);
        end

        function enpilarConexiones(obj, casilla_in)
            % Método para enpilar todas las casillas conectadas
            claves = keys(casilla_in.Conexiones);  % Obtiene todas las claves del mapa de conexiones
            for i = 1:length(claves)
                elemento = casilla_in.Conexiones(claves{i});
                obj.enpilar(elemento);  % Utiliza el método enpilar para cada conexión
            end
        end

    end
end
