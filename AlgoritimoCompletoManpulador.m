%% Algoritmo de funcionamento de um manipulador autonomo
%
% TO Do List
%
%
% * Validar Modelo DH do manipulador
%
%

% Etapas de trabalho:
%
% Carrega Parametros Utilizados
%
% 1�) Entrada de imagem (FEITO)
%
% 2�) Identifica��o dos pontos na camera (FEITO)
%
% 3�) Convers�o pontos da camera para coordenadas globais (FEITO)
%
% 4�) Solu��o da cinematica inversa por RNA (FEITO)
%
% 5�) Calculo do Polinomio da trajetoria (FEITO)
%
% 6�) Comunica��o com microcontrolador e Execu��o do movimento (FEITO)
%
% 8�) Retorno ao ponto inicial (FEITO)
%
%% Painel de Controle


close all

%Modo de funcionamento
automatico = false; %Ativa identifica��o de objeto
arduinoOn = false; %Arduino conectado
motores = false; %executa movimentos
Ponto = [110 0 15]; %ponto para modo Manual
N = 2;

camerasOn = false; %Cameras Ligadas
previewCam = false; %Ativa Preview das Cameras
camerasCaptura = true; %Tira foto
carregaImagem = false; %carrega Imagem salva
bw = true; %imagem em preto e branco

%Gera��o de Graficos
% True = exibe    False = n�o exibe
ImagemCapturada = false; %exibe imagem da camera
Imshow = false; %Imagem localiza��o do ponto
posSimulada = false; %Posi��o Simulada do Robo
GraficoTrajetoria = false; %Graficos de Trajetoria, Velocidade e Acelera��o
GraficoAtuador = false; %Graficos de Movimentos dos Atuadores
nuvemPontos = false; %Nuvem de Pontos com Ponto desejado

%Calculo de erro
erroRede = true; %Calcula o erro da Rede em rela��o ao DH

%Tempo de Movimento
tf = 2; %tempo do movimento
td = 2; %intervalo de distretiza��o

%Paremetros Identifi��o de Objetos(Moeda)
raio = [10 30]; % Raio em pixel da Moeda Identificada
sensibilidade = 0.9; %Sensibilidade
OrigemPixel = [281 111]; %Cordenadas da Origem em Pixel (Imagem Camera 2)
PixelPorMm = 1.2; % numero de Pixels por mm - Esta errado propositalmente para dar continuidade no codigo
H = 37;

%% Carrega parametros da camera

%Carrega os parametros da camera
if ~exist('stereoParams','var')
    load cameraParamsV2
end

% Carrega Arquivos RNACI
if ~exist('normalizadores','var') %carrega normalizadores
    load NormalizadoresV5
end

%Carrega Rede Neural
if ~exist('RnaCI','class')
    load Rna_V7
end

%% Carrega arduino

% Realiza a conex�o do Matlab com o Arduino e os Atuadores
if(arduinoOn == true)
    if ~exist('Arduino', 'var')
        Arduino = arduino();
    end
    
    % Define Servos
    if ~exist('Base', 'var')
        % Executa Movimento
        Base = servo(Arduino, 'D9', 'MinPulseDuration', 5e-4, 'MaxPulseDuration', 25e-4);
    end
    
    if ~exist('Ombro', 'var')
        % Executa Movimento
        Ombro = servo(Arduino, 'D10', 'MinPulseDuration', 5e-4, 'MaxPulseDuration', 25e-4);
    end
    
    if ~exist('Cotovelo', 'var')
        % Executa Movimento
        Cotovelo = servo(Arduino, 'D11', 'MinPulseDuration', 5e-4, 'MaxPulseDuration', 25e-4);
        
        %Coloca Na posi��o Inicial
        writePosition(Base, 0.5); %90/180
        writePosition(Ombro, 0.7); %90/130
        writePosition(Cotovelo, 0.6); %90/150
        writeDigitalPin(Arduino,'D13',1);
    end
end
%% 1�)  Entrada da imagem da camera
% Atrav�s da toolbox do Matlab, uma imagem � inserida no algortimo
tic
for i= 1:N
    if(automatico == true)
        
        % CARREGA ARQUIVOS A SEREM UTILIZADOS
        % So rodar quando estiver com as cameras conectadas
        % Carrega Camera
        if(camerasOn == true)
            if ~exist('LeftCam', 'var')
                LeftCam = imaq.VideoDevice('winvideo', 1); %Carrega Camera
                LeftCam.ReturnedDataType = 'uint8';
            end
            
            if ~exist('RightCam', 'var')
                RightCam = imaq.VideoDevice('winvideo', 2); %Carrega Camera
                RightCam.ReturnedDataType = 'uint8';
                
            end
        end
        
        % Preview de Calibra��o
        if(previewCam == true)
            preview(LeftCam);
            preview(RightCam);
        end
        
        if(carregaImagem == true)
            %carrega Imagens pre selecionadas
            load('ImagemTeste\ImagemLeft-3.mat');
            load('ImagemTeste\ImagemRight-3.mat');
        end
        
        if(camerasCaptura == true)
            %Tira Fotos
            I2 = (step(LeftCam));
            I1 = (step(RightCam));
     
        end
        
        if(bw == true)
                I1Ori = I1;
                I2Ori = I2;
                I1 = im2bw(I1);
                I2 = im2bw(I2);
            end
        
        %imagem de entrada
        if(ImagemCapturada == true)
            figure();
            imshowpair(I1, I2, 'montage');
            title('Imagens de Entrada');
        end
        
        %% 2�) Identifica��o dos pontos na camera
        %  3�) Convers�o pontos da camera para coordenadas globais
        %  A imagem de entrada � pre processada, retirando a distor��o das lentes
        %  das cameras. Objeto � identificado, as coordenadas em pixels s�o
        %  encontradas (u, v, w). As coordenadas em Pixels s�o trasnformadas para
        %  Coordenadas reais (X, Y, Z) em milimetros.
        
        %Fun��o que processa e identifica objeto na imagem
        
        [Ponto, Cam1, Cam2, Wob] = coordObjeto(I1, I2, I2Ori,  stereoParams, raio,...
            sensibilidade,OrigemPixel, PixelPorMm, H, Imshow);
        
        %pause(2);
        
        
    end
    
    %% Plot do ponto na nuvem com o Ponto do Objeto
    if(nuvemPontos == true)
        open('NuvemPontosV2.fig');
        hold on;
        plot3(Ponto(1), Ponto(2), Ponto(3), 'ro');
    end
    
    %% 4�) Solu��o da cinematica inversa por RNA
    %
    % As coordenadas Globais s�o inseridas como Input em uma rede neural
    % treinada com uma nuvem de pontos. A saida da rede s�o os angulos
    % necessarios para o maniulador alca�ar o ponto desejado
    
    [ang] = cinematicaInversa_AR7(Ponto, normalizadores, RnaCI);
    angO = ang;
    % plot de confirma��o do ponto pela rede
    if(posSimulada == true)
        [XYZ] = DH_AR7(ang); % Calcula os pontos de cada seguimento
        plot_AR7(Ponto, XYZ); % plota  desenho do manipulador
 
     
    end
    %erro da solu��o da cinematica inversa
    
    if(erroRede == true)
        [XYZ] = DH_AR7(ang); % Calcula os pontos de cada seguimento
        erroCI = abs(XYZ(4,:) - Ponto) % em mimiletros
        
        if((erroCI(1) > 15) || (erroCI(2) > 15) || (erroCI(3) > 15) )
            motores = false;
            disp('Ponto fora da regi�o de trabalho');
        end
        
    end
    %% 5�) Calculo do Polinomio de Trajetoria
    %
    % Utiliza os angulos de controle encontrados pelo RNA para calcular o
    % polinomio de trajetoria do movimento
    
    % Corrige Valores de angulos de acordo com posicionamento dos servos no
    %  robo
    [ang] = correcaoAng(ang);
    
    % Execu�ao da fun�ao trajetoria Inicio-Objeto
    [TrajetoriaBaseInOb] = (trajetoria( tf,td, 90, ang(1), GraficoTrajetoria ));
    [TrajetoriaOmbroInOb] = (trajetoria( tf,td, 90, ang(2), GraficoTrajetoria ));
    [TrajetoriaCotoveloInOb] = (trajetoria( tf,td, 90, ang(3), GraficoTrajetoria));
    
    % Execu��o da fu��o trajetoria Objeto-Descarte
    [TrajetoriaBaseObDes] = (trajetoria( tf,td, ang(1), 30, GraficoTrajetoria ));
    [TrajetoriaOmbroObDes] = (trajetoria( tf,td, ang(2), 130, GraficoTrajetoria  ));
    [TrajetoriaCotoveloObDes] = (trajetoria( tf,td, ang(3), 150, GraficoTrajetoria ));
    
    % Execu��o da fu��o trajetoria Descarte-Inicio
    [TrajetoriaBaseDesIn] = (trajetoria( tf,td,  30, 90, GraficoTrajetoria ));
    [TrajetoriaOmbroDesIn] = (trajetoria( tf,td,  130, 90, GraficoTrajetoria ));
    [TrajetoriaCotoveloDesIn] = (trajetoria( tf,td,  150, 90, GraficoTrajetoria ));
    
    
    
    %% 6�) Transmis�o dos angulos de controle para o microcontrolador
    % Os angulos Obtidos s�o enviados para o microcontrolador onde ser�o
    % realizados pelos atuadores
    
    %  7�) Execu��o do movimento
    %Os movimentos s�o realizados pelos atuadores seguindo um polinomio de
    % grau 5. O polinomio � calculado via matlab, e os coeficientes s�o
    % enviados para o microcontrolador
    
    if(motores == true)
        % Sequencia de Movimento
        % Sai da Posi��o Inicial e Vai ate o objeto
        movimentaServos(Base, Ombro, Cotovelo, TrajetoriaBaseInOb, TrajetoriaOmbroInOb, TrajetoriaCotoveloInOb, tf, td, GraficoAtuador);
        
        %     Aciona o Efetor
        writeDigitalPin(Arduino,'D13',0); %pega Objeto
        pause(0.05); %0.5 Segundos
        
        %     Sai da Posi��o do Objeto e Vai at� o Ponto de Descarte
        movimentaServos(Base, Ombro, Cotovelo, TrajetoriaBaseObDes, TrajetoriaOmbroObDes, TrajetoriaCotoveloObDes, tf, td, GraficoAtuador);
        
        %     Aciona o Efetor
         pause(0.05); %0.5 Segundos
        writeDigitalPin(Arduino,'D13',1); %solta Objeto
       
       
        
        %     Sai da Posi��o de Descarte e retorna a posi��o Inicial
%        writePosition(Base, 0.5); %90/180
%         writePosition(Ombro, 0.7); %90/130
%         writePosition(Cotovelo, 0.6); %90/150
        %         
 movimentaServos(Base, Ombro, Cotovelo, TrajetoriaBaseDesIn, TrajetoriaOmbroDesIn, TrajetoriaCotoveloDesIn, tf, td, GraficoAtuador);
    end
    
    %% 8�) Retorno ao ponto inicial
    %
    % Ap�s a execu��o do movimento, o manipulador retorna a posi��o inicial
    % determinada e j� esta pronto para um novo input de imagem.
    
end
toc