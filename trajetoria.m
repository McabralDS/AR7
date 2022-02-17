function [t1] = trajetoria( tf,td, thetaInicial, thetaFinal, grafico)

% Função Planejamento de Trajetória Polinômio 5 Ordem
%==========================================================================
%
% A função trajetoria é responsavel por calcular o polinomio de 5ª ordem
% que rege o movimento dos atuadores do robo. 
%
% Parametros de Entrada:
% - tf = Tempo final do movimento
% - td = Intervalo de Discretização
% - Theta_inicio = Posição Inicial do atuador
% - theta_final = Posição final do atuador
% - grafico = Gerar graficos(true/false)
% 
% Parametros de Saida:
% - t1 = Vetor de Angulos da Trajetoria

%% Variaveis

 velo_inicial = 0;
 velo_final = 0;
 ac_inicial = 0;
 ac_final = 0;

 %% Coeficientes do polinomio
 
 
A = [0 0 0 0 0 1;
     0 0 0 0 1 0;
     0 0 0 2 0 0;
     tf^5 tf^4 tf^3 tf^2 tf 1;
     5*tf^4 4*tf^3 3*tf^2 2*tf 1 0;
     20*tf^3 12*tf^2 6*tf 2 0 0];

B = [thetaInicial velo_inicial ac_inicial thetaFinal velo_final ac_final]';
B
x = A\B;
x
c0 = x(6);
c1 = x(5);
c2 = x(4);
c3 = x(3);
c4 = x(2);
c5 = x(1);

C = [c0 c1 c2 c3 c4 c5];
C
%% Plot polinomio 
   
    i=1;
    t1 = zeros(1, (tf/td +1));
    t2 = zeros(1, (tf/td +1));
    t3 = zeros(1, (tf/td +1));
    
 for t = 0:td:(tf)
     
        t1(i) = c0 + c1*t + c2*t^2 + c3*t^3 + c4*t^4 + c5*t^5;
        t2(i) = c1 + 2*c2*t + 3*c3*t^2 + 4*c4*t^3 + 5*c5*t^4;
        t3(i) = 2*c2 + 6*c3*t + 12*c4*t^2 + 20*c5*t^3;
        t
        i=i+1;
 end
 
 t1
 t2
 t3
 
    
    %\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
      if(grafico == true)
           figure()
        plot(t1,'or-');
        hold on
        plot(t2,'ob-');
        hold on
        plot(t3,'ok-');

    hold off
    grid on
   % title('Planejamento de Trajetoria - Polinomio de Ordem 5');
    legend({'Position','Velocity','Acceleration'},'Location','northwest'); 
    xlabel('Time(s)');
    ylabel('Angle(º)');
    axis;
      end
% 
