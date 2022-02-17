
function plot_AR7(Ponto, XYZ)
%% Fun��o para plot do manipulador no ponto desejado
%=========================================================================
% A fun��o plot_AR7 exibe a posi��o final do manipulador no ponto desejado
% Parametros de Entradas:
% - Ponto = Ponto desejado [X Y Z]
% - XYZ = Vetor de saida da fun��o DH_AR7
%
% Parametro de Saida:
% - Grafico da Posi��o do Rob�

%% Plot 3D

     figure()
     xlabel('X','fontsize',10)
     ylabel('Y','fontsize',10)
     zlabel('Z','fontsize',10)
     grid on
     hold on
     plot3(Ponto(1),Ponto(2),Ponto(3), 'bo', 'LineWidth', 4 ); %
     hold on


 plot3([0 XYZ(1,1) XYZ(2,1) XYZ(3,1) XYZ(4,1)], ...
      [0 XYZ(1,2) XYZ(2,2) XYZ(3,2) XYZ(4,2)], ...
      [0 XYZ(1,3) XYZ(2,3) XYZ(3,3) XYZ(4,3)],'-ro','LineWidth', 4 , 'LineJoin', 'round'); % 
 grid on
 legend('Ponto Desejado', 'Manipulador');
  hold on

end