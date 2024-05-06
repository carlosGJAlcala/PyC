function explorarMapa()
BEP = pila();


%Empezamos analizando donde empezamos
%% Pasos
% Ini:
% Analizar que tenemos y hacia donde podemos avanzar
% Añadir direccion disponibles a la pila y crear el objeto casilla
% donde añadiremos las direcciones disponibles y la informacion de la
% casilla
idManager = IDManager();
casilla_ini = casilla();
casilla_ini.setVisitada()
casilla_ini.setEsInicial();
cod = codificacion_casilla();
dir = obtenerDireccionesLibres(cod);
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
lastBack = 0;
% Ejemplo de cómo usar obtenerTop
while ~BEP.estaVacia()
    % Obtener la casilla en el tope de la pila sin desenpilar
    casilla_actual = BEP.obtenerTop()
    nuevas_dir = [];
    %Si ya esta visitada, es que estamos realizando backtracking
    if casilla_actual.getVisitada()
        if casilla_actual.getEsFinalRama()
            destino_back = casilla_actual.getDireccionDestino();
%             if lastSalida
%                 realizarMovimientoBackTracking(destino_back);
%             else
                realizarMovimientoBackTrackingFinRama(destino_back);
%             end

            %Como es final de rama, prepara backtracking especial solo para
            %este caso
            if ~BEP.estaVacia()
                BEP.desenpilar();                
            end
        else
            % recorrer sentido contrario a su destino
            destino_back = casilla_actual.getDireccionDestino();
            realizarMovimientoBackTracking(destino_back);
            if casilla_actual.getEsInicial()
                girar(90);
                girar(90);
            end

            if ~BEP.estaVacia()
                BEP.desenpilar();                
            end
            
        end
        lastBack = 1;
    else
        if lastBack
            girar(90);
            girar(90);
        end

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

        if isempty(nuevas_dir)
            casilla_actual.setEsFinalRama();
        else
            %Comprobar si tiene 3 caminos libres, si es asi, esta sera la
            %salida
            comprobarEsSalida = 0;
            for i = 1:length(nuevas_dir)
                if nuevas_dir{i} == "norte"
                    comprobarEsSalida = comprobarEsSalida+ 1;
                end
                if nuevas_dir{i} == "este"
                    comprobarEsSalida = comprobarEsSalida+1;
                end
                if nuevas_dir{i} == "oeste"
                    comprobarEsSalida = comprobarEsSalida+1;
                end
            end
            
            if comprobarEsSalida == 3 
                casillaSalida = casilla();
                casillaSalida.setEsSalida();
                casillaSalida.setEsFinalRama();
                casillaSalida.setVisitada();

                casilla_actual.setEsFinalRama();

                casilla_actual.agregarConexion("norte", casillaSalida);
%                 BEP.enpilarConexiones(casilla_actual);
            else
                casilla_actual.agregarConexiones(nuevas_dir);
                BEP.enpilarConexiones(casilla_actual);
            end           
        end  
        lastBack = 0;
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
    % hay 8, 4 normales y otros 4 de cuando es final de rama
    direcciones = {'oeste', 'sur', 'este', 'norte'};     
    switch destino
        case direcciones{1}
            avanzar();  
            girar(-90);
        case direcciones{2}
            avanzar();
        case direcciones{3}
            avanzar();
            girar(90);            
        case direcciones{4}
            avanzar();
    end  
end

function realizarMovimientoBackTrackingFinRama(destino)
    %Dependiendo de cual sea el destino, hara un movimiento u otro
    % hay 8, 4 normales y otros 4 de cuando es final de rama
    direcciones = {'oeste', 'sur', 'este', 'norte'};     
    switch destino
        case direcciones{1}
            girar(-90);
            girar(-90);
            avanzar(); 
            girar(-90);
        case direcciones{2}
            girar(-90);
            girar(-90);
            avanzar();
        case direcciones{3}
            girar(90);
            girar(90);
            avanzar();
            girar(90);            
        case direcciones{4}
            girar(90);
            girar(90);
            avanzar();
    end  
end

