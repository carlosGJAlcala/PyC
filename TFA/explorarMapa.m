function explorarMapa()
BEP = pila();

casilla_ini = casilla(IDManager.getNextID());
casilla_ini.setVisitada()
casilla_ini.setEsInicial();
cod = codificacion_casilla();
dir = obtenerDireccionesLibres(cod);
casilla_ini.agregarConexiones(dir);

BEP.enpilar(casilla_ini);
BEP.enpilarConexiones(casilla_ini);


recorrerMapa(BEP);

grafo = visualizeCasillaGraph(casilla_ini);

[caminoSalida, direcciones] = buscarSalida(casilla_ini);

% Imprimir el camino y las direcciones
disp('Camino hacia la salida:');
disp(caminoSalida);
disp('Direcciones para seguir:');
disp(direcciones);

salirMapa(direcciones);

end

function salirMapa(direcciones)
    for i=1:length(direcciones)
        realizarMovimiento(direcciones{i}) ;
    end
end

function [camino, direccionesArray] = buscarSalida(casillaInicial)
    % Mapa para controlar las casillas visitadas
    visitados = containers.Map('KeyType', 'char', 'ValueType', 'logical');
    % Mapa para registrar el camino de predecesores
    predecesores = containers.Map('KeyType', 'char', 'ValueType', 'any');
    % Mapa para guardar las direcciones tomadas para llegar a cada casilla
    direcciones = containers.Map('KeyType', 'char', 'ValueType', 'char');
    % Cola de casillas por visitar
    cola = {casillaInicial};
    % Marcar la primera casilla como visitada
    visitados(num2str(casillaInicial.getID())) = true;

    nodoSalida = '';
    encontrado = false;

    while ~isempty(cola)
        actual = cola{1};
        cola(1) = [];  % Desencolar

        % Verificar si la casilla actual es la salida
        if actual.getEsSalida()
            nodoSalida = actual;
            encontrado = true;
            break;
        end

        % Revisar todas las conexiones de la casilla actual
        conexiones = actual.obtenerTodasConexiones();
        direccionesActuales = keys(conexiones);

        for i = 1:length(direccionesActuales)
            vecino = conexiones(direccionesActuales{i});
            idVecino = num2str(vecino.getID());

            % Solo agregar a la cola si no ha sido visitado
            if ~isKey(visitados, idVecino)
                visitados(idVecino) = true;
                cola{end+1} = vecino;
                predecesores(idVecino) = actual;
                direcciones(idVecino) = vecino.getDireccionDestino();
            end
        end
    end

    % Reconstruir el camino de regreso si se encontró la salida
    camino = {};
    if encontrado
        while ~isempty(nodoSalida)
            camino{end+1} = nodoSalida;
            if isKey(predecesores, num2str(nodoSalida.getID()))
                nodoSalida = predecesores(num2str(nodoSalida.getID()));
            else
                break;
            end
        end
        camino = fliplr(camino);  % Invertir el orden para obtener el camino correcto
    end

    % Convertir las direcciones a un arreglo
    direccionesArray = {};
    for i = 1:length(camino)-1
        direccionesArray{end+1} = direcciones(num2str(camino{i+1}.getID()));
    end

    return
end




% pared izquierda
% pared trasera
% pared derecha
% pared delantera
function resultado = obtenerDireccionesLibres(array)
direcciones = {'oeste', 'sur', 'este', 'norte'};
resultado = {};
for i = 1:length(array)
    if array(i) == 0
        resultado{end + 1} = direcciones{i};
    end
end
end


function recorrerMapa(BEP)
lastBack = 0;

while ~BEP.estaVacia()

    casilla_actual = BEP.obtenerTop()
    nuevas_dir = [];

    %Si ya esta visitada, es que estamos realizando backtracking
    if casilla_actual.getVisitada()
        if casilla_actual.getEsFinalRama()
            destino_back = casilla_actual.getDireccionDestino();
            %Como es final de rama, prepara backtracking especial solo para
            realizarMovimientoBackTrackingFinRama(destino_back);
            
            if ~BEP.estaVacia()
                BEP.desenpilar();
            end
        else
            % recorrer sentido contrario a su destino
            destino_back = casilla_actual.getDireccionDestino();
            realizarMovimientoBackTracking(destino_back);
            % Girar 180 cuando llegue al punto inicial para continuar tal y
            % como se empezo
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
        % En el caso que este haciendo backtracking y vuelva a incoporarse
        % en el flujo normal
        if lastBack
            girar(90);
            girar(90);
        end

        destino = casilla_actual.getDireccionDestino();
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
            %Comprobar si tiene 3 caminos libres, excluyendo de donde proviene, si es asi, esta sera la salida
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
                casillaSalida = casilla(IDManager.getNextID());
                casillaSalida.setEsSalida();
                casillaSalida.setEsFinalRama();
                casillaSalida.setVisitada();

                casilla_actual.setEsFinalRama();

                casilla_actual.agregarConexion("salida", casillaSalida);
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
direcciones = {'oeste', 'sur', 'este', 'norte', 'salida'};
switch destino
    case direcciones{1}
        girar(90);
        avanzar();
    case direcciones{2}
        girar(90);
        girar(90);
        avanzar();
    case direcciones{3}
        girar(-90);
        avanzar();
    case direcciones{4}
        avanzar();
    case direcciones{5}
        disp('Ha llegado a la salida');
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

function G = visualizeCasillaGraph(casilla, G, parentNode)
g_vacio = 0;
if nargin < 2 || isempty(G)
    g_vacio = 1;
    G = digraph;  % Crea un nuevo grafo si no se proporciona uno
end

% Asegura que el ID de casilla se convierte en cadena para su uso en el grafo
casillaID = num2str(casilla.getID());

if g_vacio
    G = addnode(G, casillaID);
    g_vacio = 0;
else
    if isempty(findnode(G, casillaID))
        G = addnode(G, casillaID);  % Añade el nodo si no está en el grafo
    end
end
% Siempre añade el nodo actual al grafo antes de cualquier otra operación


% Añade una arista si existe un nodo padre
if nargin >= 3 && ~isempty(parentNode)
    parentID = num2str(parentNode.getID());
    if isempty(findnode(G, parentID))
        G = addnode(G, parentID);  % Añade el nodo padre si no está
    end
    G = addedge(G, parentID, casillaID);  % Añade la arista
end

% Recorre todas las conexiones y aplica la función de manera recursiva
keys = casilla.Conexiones.keys;
for i = 1:length(keys)
    direccion = keys{i};
    childNode = casilla.Conexiones(direccion);
    G = visualizeCasillaGraph(childNode, G, casilla);  % Llamada recursiva
end


if nargin < 3
    figure;
    p = plot(G, 'Layout', 'force');  
    p.MarkerSize = 9;  
    p.NodeColor = [0 0.4470 0.7410]; 
    p.LineWidth = 2; 
    p.EdgeColor = [0.3010 0.7450 0.9330];  
    p.ArrowSize = 12;
    p.NodeLabel = G.Nodes.Name;  

%     salidaID = '';
%     keys = casilla.Conexiones.keys;
%     for i = 1:length(keys)
%         if casilla.Conexiones(keys{i}).getEsSalida()
%             salidaID = keys{i};
%             break;
%         end
%     end
% 
%     if ~isempty(salidaID)
%         % Resaltar el nodo de salida
%         highlight(p, salidaID, 'NodeColor', 'red', 'MarkerSize', 10, 'Marker', 's');
%     end

    title('Visualización del Grafo de Casillas'); 
end
end

