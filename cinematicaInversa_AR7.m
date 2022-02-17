%% Função para calculo da Cinematica Inversa utlizando RNA
%=========================================================================
% A função cinematicaInversa_AR7 calcula a cinematica inversa do
% manipulador AR7 em 3 dimensões e retorna o angulo desejado.
%  Parametros de Entrada:
% - Ponto = Ponto desejado [X Y Z]
% - normalizadores = normalizadores da rede neural
% - RnaCI = Rede Neural Utilizada
%
%  Parametro de Saida:
% - Ang = Angulo das juntas do manipulador [Base Ombro Cotovelo]

function [ ang ] = cinematicaInversa_AR7( Ponto, normalizadores, RnaCI )

% calcula
ponto(1) = Ponto(1) ./normalizadores(1);
ponto(2) = Ponto(2) ./normalizadores(2);
ponto(3) = Ponto(3) ./normalizadores(3);

% joga o ponto na rede
ang = RnaCI(ponto');

%desnormaliza a saida
ang(1) = ang(1) .* normalizadores(4); %rotação
ang(2) = ang(2) .* normalizadores(5); %primeira junta
ang(3) = ang(3) .* normalizadores(6); %segunda junta




%arredonda para uma casa decimal
ang = round(ang);
 
end

