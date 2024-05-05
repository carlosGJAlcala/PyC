function explorarMapa()
BEP = pila();


%Empezamos analizando donde empezamos
%% Pasos
% Ini:
% Analizar que tenemos y hacia donde podemos avanzar
% Añadir direccion disponibles a la pila y crear el objeto casilla
% donde añadiremos las direcciones disponibles y la informacion de la
% casilla
casilla_ini = casilla();
casilla_ini.setVisitada()
cod = codificacion_casilla()
dir = obtenerDireccionesLibres(cod)
casilla_ini.agregarConexiones(dir);
%Enpilamos esta casilla inicial y sus conexiones
BEP.enpilar(casilla_ini);
BEP.enpilarConexiones(casilla_ini);

% avanzar hacia la direccion libre fijandonos en el top de la pila
recorrerMapa(BEP);







verHijos(casilla_ini);



end

% pared izquierda
% pared trasera
% pared derecha
% pared delantera
function resultado = obtenerDireccionesLibres(array)
    direcciones = {'oeste', 'sur', 'este', 'norte'};    
    % Inicializa un cell array vacío para almacenar las direcciones libres
    resultado = {};    
    % Itera a través del array para verificar las paredes libres
    for i = 1:length(array)
        if array(i) == 0
            resultado{end + 1} = direcciones{i};
        end
    end
end


function verHijos(casilla_in)
claves = keys(casilla_in.obtenerTodasConexiones());  % Obtiene todas las claves del mapa
valores = values(casilla_in.obtenerTodasConexiones());  % Obtiene todos los valores del mapa
% Mostrar las claves y los valores
disp('Conexiones disponibles:');
for i = 1:length(claves)
    fprintf('Dirección: %s, Casilla: %s\n', claves{i}, class(valores{i}));
end
end


function recorrerMapa(BEP)
direcciones = {'oeste', 'sur', 'este', 'norte'}; 

% Ejemplo de cómo usar obtenerTop
while ~BEP.estaVacia()
    % Obtener la casilla en el tope de la pila sin desenpilar
    casilla_actual = BEP.obtenerTop();
    
    %Si ya esta visitada, es que estamos realizando backtracking
    if casilla_actual.getVisitada()
        % recorrer sentido contrario a su destino
        destino_back = casilla_actual.getDireccionDestino();
        %dir_back = obtenerDireccionOpuesta(destino_back)
        realizarMovimientoBackTracking(destino_back);

        % eliminar de la pila

    else
        % evaluar direccion destino
        destino = casilla_actual.getDireccionDestino();
        %realizar movimiento
        realizarMovimiento(destino);

        %% Evaluar nueva casilla
        % Comprobar las conexiones disponibles desde la casilla actual
        cod = codificacion_casilla();  % Obtiene el estado actual basado en la ubicación/condición de la casilla
        nuevas_dir = obtenerDireccionesLibres(cod);

        % Controlar para no añadir como direccion libre la direccion de donde proviene
        direccionProveniente = obtenerDireccionOpuesta(casilla_actual.DireccionDestino);
        nuevas_dir = nuevas_dir(~strcmp(nuevas_dir, direccionProveniente));
        
        casilla_actual.setVisitada();
    end


    if isempty(nuevas_dir)       

        % No hay direcciones disponibles, hacer backtracking
        BEP.desenpilar();  % Solo desenpilar cuando no hay otras opciones
    else

        %if all(nuevas_dir,1)
        
            %pdt analizar para marcar la salida
        %else

        %end
        % Procesar nuevas direcciones
        % Asume que agregarConexiones y enpilarConexiones manejan la verificación de casillas visitadas
        casilla_actual.agregarConexiones(nuevas_dir);
        BEP.enpilarConexiones(casilla_actual);
    end
end

end


function direccionOpuesta = obtenerDireccionOpuesta(direccion)
    %Este y Oeste seran opuestos al sur, ya que hacen un giro.
    switch direccion
        case 'norte'
            direccionOpuesta = 'sur';
        case 'sur'
            direccionOpuesta = 'norte';
        case 'este'
            direccionOpuesta = 'sur';
        case 'oeste'
            direccionOpuesta = 'sur';
        otherwise
            error('Dirección no reconocida');
    end
end

function realizarMovimiento(destino)
    %Dependiendo de cual sea el destino, hara un movimiento u otro
    direcciones = {'oeste', 'sur', 'este', 'norte'};     
    switch destino
        case direcciones{1}
            girar(90);
            avanzar();
            %despues de avanzar volver a repetir el proceso
        case direcciones{2}
            girar(90);
            girar(90);
            avanzar();
        case direcciones{3}
            girar(-90);
            avanzar();
        case direcciones{4}
            avanzar();
    end  
end

function realizarMovimientoBackTracking(destino)
    %Dependiendo de cual sea el destino, hara un movimiento u otro
    direcciones = {'oeste', 'sur', 'este', 'norte'};     
    switch destino
        case direcciones{1}
            girar(90);
            girar(90);
            avanzar();
            girar(-90);            
            %despues de avanzar volver a repetir el proceso
        case direcciones{2}
%             girar(90);
%             girar(90);
            avanzar();
        case direcciones{3}
            girar(-90);
            avanzar();
        case direcciones{4}
%             girar(90);
%             girar(90);
            avanzar();
    end  
end


