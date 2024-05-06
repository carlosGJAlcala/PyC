classdef IDManager
    methods (Static)
        function id = getNextID()
            persistent currentID
            if isempty(currentID)
                currentID = 1;  % Inicializa con el primer ID
            else
                currentID = currentID + 1;  % Incrementa el ID
            end
            id = currentID;  % Devuelve el ID actualizado
        end
    end
end
