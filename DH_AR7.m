function [Coord]= DH_AR7(ang_controle)
%% Função para solução da cinematica direta pelo modelo DH
%=========================================================================
%
% A fução DH_AR7 calcula a cinematica direta para o robo manipulador AR7
% utilizando o modelo DH criado para solucionar a rede
%
% Parametro de Entrada:
% - Ang_controle = Vetor com os angulos de controle de cada junta
%
% Parametro de Saida:
% - Coord = Cordenadas XYZ da ponta do manipulador

%% DH - Tabela

%   0   ALPHA     a   TETHA   d
%   1   0         0   0       L1
%   2   90        0   0       L2
%   3   0         L3  0       0
%   4   -90       L4  90      0

%% Tamanho dos elos

L1 = 70 ;    % d1
L2 = 70 ;    % d2
L3 = 105;    % a3
L4 = 105;    % a4 

%% Parâmentro de o DH

d1 = L1;
d2 = L2;
d3 = 0 ;
d4 = 0 ;

a1 = 0 ;
a2 = 0 ;
a3 = L3;
a4 = L4;

%% Thetas Iniciais
THETA1 = 0  ; 
THETA2 = 0  ;  %THETA2 É O ANGULO DA JUNTA 1 
THETA3 = 90  ; %THETA3 É O ANGULA DA JUNTA 2
THETA4 = 90  ; %THETA4 É O ANGULO DA JUNTA 3

%% Alphas iniciais
ALPHA1 = 0 ;
ALPHA2 = 90;
ALPHA3 = 0 ;
ALPHA4 = 0 ;

%% Modelo DH

%Angulos de entrada
ang = [ang_controle]';

    %Matrizes de transformação para cada seguimento
            T1 = [cosd(THETA1)     -sind(THETA1)*cosd(ALPHA1)         sind(THETA1)*sind(ALPHA1)       cosd(THETA1)*a1  ; 
                 sind(THETA1)      cosd(THETA1)*cosd(ALPHA1)        -cosd(THETA1)*sind(ALPHA1)       sind(THETA1)*a1  ; 
                     0                   sind(ALPHA1)                      cosd(ALPHA1)                    d1        ; 
                     0                        0                                 0                          1        ];
           
            T2 = [cosd(ang(1))     -sind(ang(1))*cosd(ALPHA2)         sind(ang(1))*sind(ALPHA2)       cosd(ang(1))*a2  ; 
                  sind(ang(1))      cosd(ang(1))*cosd(ALPHA2)        -cosd(ang(1))*sind(ALPHA2)       sind(ang(1))*a2  ; 
                     0                   sind(ALPHA2)                      cosd(ALPHA2)                    d2        ; 
                     0                        0                                 0                          1        ];
       
            T3 = [cosd(ang(2))     -sind(ang(2))*cosd(ALPHA3)         sind(ang(2))*sind(ALPHA3)       cosd(ang(2))*a3  ; 
                  sind(ang(2))      cosd(ang(2))*cosd(ALPHA3)        -cosd(ang(2))*sind(ALPHA3)       sind(ang(2))*a3  ; 
                     0                   sind(ALPHA3)                      cosd(ALPHA3)                    d3        ; 
                     0                        0                                 0                          1        ];
            
            T4 = [cosd(ang(3))     -sind(ang(3))*cosd(ALPHA4)         sind(ang(3))*sind(ALPHA4)       cosd(ang(3))*a4  ; 
                 sind(ang(3))      cosd(ang(3))*cosd(ALPHA4)        -cosd(ang(3))*sind(ALPHA4)       sind(ang(3))*a4  ; 
                     0                   sind(ALPHA4)                      cosd(ALPHA4)                    d4        ; 
                     0                        0                                 0                          1        ];

            % Multiplicação das matrizes do de seguimento     
            Tt4 = T1*T2*T3*T4;
            Tt3 = T1*T2*T3;
            Tt2 = T1*T2;
            Tt1 = T1;
            
            %Coordenadas homogeneas por seguimento
            p0 = [0; 0; 0; 1];
            p1 = Tt1*p0;
            p2 = Tt2*p0;
            p3 = Tt3*p0;
            p4 = Tt4*p0;
            
            %Coordenadas Cartesianas por seguimento
            X1 = p1(1)/p1(4);
            Y1 = p1(2)/p1(4);
            Z1 = p1(3)/p1(4);
            
            X2 = p2(1)/p2(4);
            Y2 = p2(2)/p2(4);
            Z2 = p2(3)/p2(4);
            
            X3 = p3(1)/p3(4);
            Y3 = p3(2)/p3(4);
            Z3 = p3(3)/p3(4);
            
            X4 = p4(1)/p4(4);
            Y4 = p4(2)/p4(4);
            Z4 = p4(3)/p4(4);
           
            %Vetor de coordenadas cartesianas por seguimento
            Coord= [ X1 Y1 Z1;  X2 Y2 Z2; X3 Y3 Z3;  X4 Y4 Z4;];
            
end