function movimentaServos( Base, Ombro, Cotovelo, TrajetoriaBase, TrajetoriaOmbro, TrajetoriaCotovelo, tf, td, graficos)
% 
%Fun��o movimentaServos
%=====================================================
%
% A fun��o movimentaServos recebe os objetos Servos do robo e a trajetoria
% de cada atuador e executa o movimento no arduino. Ao final do Movimento,
% s�o exibidos os graficos de Posi��o e Velocidade do movimento;
%
% Parametros Entrada:
% - Base = Objeto Servo Motor da Base do robo
% - Ombro = Objeto Servo Motor do Ombro do robo
% - Cotovelo = Objeto Servo Motor do Cotovelo do Robo
% - TrajetoriaBase = Vetor de Angulos da trajetoria do atuador
% - TrajetoriaOmbro = Vetor de Angulos da trajetoria do atuador
% - TrajetoriaCotovelo = Vetor de Angulos da trajetoria do atuador
% - tf = Tempo final do movimento
% - td = Intervalo de Discretiza��o
% - grafico = Gerar graficos(true/false)


%% Movimento Servos
i = 1;
posicaoBase = zeros(1, (tf/td +1));
posicaoOmbro = zeros(1, (tf/td +1));
posicaoCotovelo = zeros(1, (tf/td +1));

  for t = 0:td:(tf)
      %Base
         angleBase = round((TrajetoriaBase(i)/180),2); %mapeia ang para atuador
         writePosition(Base, angleBase); %executa movimento
         current_pos = readPosition(Base); %le Posi��o Servo
         posicaoBase(i) = current_pos*180; %mapeia Servo
     
     %Ombro
         angleOmbro = round((TrajetoriaOmbro(i)/130),2); %mapeia ang para atuador
         writePosition(Ombro, angleOmbro); %executa movimento
         current_pos = readPosition(Ombro); %le Posi��o Servo
         posicaoOmbro(i) = current_pos*130; %mapeia Servo
     
     
     %Cotovelo
         angleCotovelo = round((TrajetoriaCotovelo(i)/150),2); %mapeia ang para atuador
         writePosition(Cotovelo, angleCotovelo); %executa movimento
         current_pos = readPosition(Cotovelo); %le Posi��o Servo
         posicaoCotovelo(i) = current_pos*150; %mapeia Servo
         
         
         i=i+1;
     pause(td); %intervalo de Movimento - constante de discretiza�ao
     
  end
  
  %% Gera Graficos
  
  if(graficos == true)
   % Calcula Velocidades
  j=2;
  velBase(1) = 0;
  velOmbro(1) = 0;
  velCotovelo(1) = 0;
%   velBase(tf) = 0;
%   velOmbro(tf) = 0;
%   velCotovelo(tf) = 0;
%   
  for v = (td):td:(tf)
     velBase(j) = (posicaoBase(j) - posicaoBase(j-1))/td;
     velOmbro(j) = (posicaoOmbro(j) - posicaoOmbro(j-1))/td; 
     velCotovelo(j) = (posicaoCotovelo(j) - posicaoCotovelo(j-1))/td; 
     j=j+1;
  end
  
   figure();
   plot(posicaoBase); %Plot do movimento feito
   hold on
   plot(TrajetoriaBase,'r.'); %Pontos discretizados desejados
   hold on
  plot(velBase); 
   title('Posi��o Atuador Base');
   grid on
   ylabel('Angulo (�)');
   xlabel('Tempo (i)');
   legend('Posi��o','Trajetoria','Velocidade');
  
   
   figure();
   plot(posicaoOmbro); %Plot do movimento feito
   hold on
   plot(TrajetoriaOmbro,'r.'); %Pontos discretizados desejados
   title('Posi��o Atuador Bra�o');
   grid on
  plot(velOmbro); 
   ylabel('Angulo (�)');
   xlabel('Tempo (i)');
   legend('Posi��o','Trajetoria','Velocidade');
  
   
   figure();
   plot(posicaoCotovelo); %Plot do movimento feito 
   hold on
   plot(TrajetoriaCotovelo,'r.'); %Pontos discretizados desejados
   title('Posi��o Atuador Cotovelo');
   grid on
  plot(velCotovelo); 
   ylabel('Angulo (�)');
   xlabel('Tempo (i)');
   legend('Posi��o','Trajetoria','Velocidade');
  
  end
end
