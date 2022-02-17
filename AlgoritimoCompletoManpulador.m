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
% 1º) Entrada de imagem (FEITO)
%
% 2º) Identificação dos pontos na camera (FEITO)
%
% 3º) Conversão pontos da camera para coordenadas globais (FEITO)
%
% 4º) Solução da cinematica inversa por RNA (FEITO)
%
% 5º) Calculo do Polinomio da trajetoria (FEITO)
%
% 6º) Comunicação com microcontrolador e Execução do movimento (FEITO)
%
% 8º) Retorno ao ponto inicial (FEITO)
%
%% Painel de Controle


close all

%Modo de funcionamento
automatico = false; %Ativa identificação de objeto
arduinoOn = false; %Arduino conectado
motores = false; %executa movimentos
Ponto = [110 0 15]; %ponto para modo Manual
N = 2;

camerasOn = false; %Cameras Ligadas
previewCam = false; %Ativa Preview das Cameras
camerasCaptura = true; %Tira foto
carregaImagem = false; %carrega Imagem salva
bw = true; %imagem em preto e branco

%Geração de Graficos
% True = exibe    False = não exibe
ImagemCapturada = false; %exibe imagem da camera
Imshow = false; %Imagem localização do ponto
posSimulada = false; %Posição Simulada do Robo
GraficoTrajetoria = false; %Graficos de Trajetoria, Velocidade e Aceleração
GraficoAtuador = false; %Graficos de Movimentos dos Atuadores
nuvemPontos = false; %Nuvem de Pontos com Ponto desejado

%Calculo de erro
erroRede = true; %Calcula o erro da Rede em relação ao DH

%Tempo de Movimento
tf = 2; %tempo do movimento
td = 2; %intervalo de distretização

%Paremetros Identifição de Objetos(Moeda)
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

% Realiza a conexão do Matlab com o Arduino e os Atuadores
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
        
        %Coloca Na posição Inicial
        writePosition(Base, 0.5); %90/180
        writePosition(Ombro, 0.7); %90/130
        writePosition(Cotovelo, 0.6); %90/150
        writeDigitalPin(Arduino,'D13',1);
    end
end
%% 1º)  Entrada da imagem da camera
% Através da toolbox do Matlab, uma imagem é inserida no algortimo
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
        
        % Preview de Calibração
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
        
        %% 2º) Identificação dos pontos na camera
        %  3º) Conversão pontos da camera para coordenadas globais
        %  A imagem de entrada é pre processada, retirando a distorção das lentes
        %  das cameras. Objeto é identificado, as coordenadas em pixels são
        %  encontradas (u, v, w). As coordenadas em Pixels são trasnformadas para
        %  Coordenadas reais (X, Y, Z) em milimetros.
        
        %Função que processa e identifica objeto na imagem
        
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
    
    %% 4º) Solução da cinematica inversa por RNA
    %
    % As coordenadas Globais são inseridas como Input em uma rede neural
    % treinada com uma nuvem de pontos. A saida da rede são os angulos
    % necessarios para o maniulador alcaçar o ponto desejado
    
    [ang] = cinematicaInversa_AR7(Ponto, normalizadores, RnaCI);
    angO = ang;
    % plot de confirmação do ponto pela rede
    if(posSimulada == true)
        [XYZ] = DH_AR7(ang); % Calcula os pontos de cada seguimento
        plot_AR7(Ponto, XYZ); % plota  desenho do manipulador
 
     
    end
    %erro da solução da cinematica inversa
    
    if(erroRede == true)
        [XYZ] = DH_AR7(ang); % Calcula os pontos de cada seguimento
        erroCI = abs(XYZ(4,:) - Ponto) % em mimiletros
        
        if((erroCI(1) > 15) || (erroCI(2) > 15) || (erroCI(3) > 15) )
            motores = false;
            disp('Ponto fora da região de trabalho');
        end
        
    end
    %% 5º) Calculo do Polinomio de Trajetoria
    %
    % Utiliza os angulos de controle encontrados pelo RNA para calcular o
    % polinomio de trajetoria do movimento
    
    % Corrige Valores de angulos de acordo com posicionamento dos servos no
    %  robo
    [ang] = correcaoAng(ang);
    
    % Execuçao da funçao trajetoria Inicio-Objeto
    [TrajetoriaBaseInOb] = (trajetoria( tf,td, 90, ang(1), GraficoTrajetoria ));
    [TrajetoriaOmbroInOb] = (trajetoria( tf,td, 90, ang(2), GraficoTrajetoria ));
    [TrajetoriaCotoveloInOb] = (trajetoria( tf,td, 90, ang(3), GraficoTrajetoria));
    
    % Execução da fução trajetoria Objeto-Descarte
    [TrajetoriaBaseObDes] = (trajetoria( tf,td, ang(1), 30, GraficoTrajetoria ));
    [TrajetoriaOmbroObDes] = (trajetoria( tf,td, ang(2), 130, GraficoTrajetoria  ));
    [TrajetoriaCotoveloObDes] = (trajetoria( tf,td, ang(3), 150, GraficoTrajetoria ));
    
    % Execução da fução trajetoria Descarte-Inicio
    [TrajetoriaBaseDesIn] = (trajetoria( tf,td,  30, 90, GraficoTrajetoria ));
    [TrajetoriaOmbroDesIn] = (trajetoria( tf,td,  130, 90, GraficoTrajetoria ));
    [TrajetoriaCotoveloDesIn] = (trajetoria( tf,td,  150, 90, GraficoTrajetoria ));
    
    
    
    %% 6º) Transmisão dos angulos de controle para o microcontrolador
    % Os angulos Obtidos são enviados para o microcontrolador onde serão
    % realizados pelos atuadores
    
    %  7º) Execução do movimento
    %Os movimentos são realizados pelos atuadores seguindo um polinomio de
    % grau 5. O polinomio é calculado via matlab, e os coeficientes são
    % enviados para o microcontrolador
    
    if(motores == true)
        % Sequencia de Movimento
        % Sai da Posição Inicial e Vai ate o objeto
        movimentaServos(Base, Ombro, Cotovelo, TrajetoriaBaseInOb, TrajetoriaOmbroInOb, TrajetoriaCotoveloInOb, tf, td, GraficoAtuador);
        
        %     Aciona o Efetor
        writeDigitalPin(Arduino,'D13',0); %pega Objeto
        pause(0.05); %0.5 Segundos
        
        %     Sai da Posição do Objeto e Vai até o Ponto de Descarte
        movimentaServos(Base, Ombro, Cotovelo, TrajetoriaBaseObDes, TrajetoriaOmbroObDes, TrajetoriaCotoveloObDes, tf, td, GraficoAtuador);
        
        %     Aciona o Efetor
         pause(0.05); %0.5 Segundos
        writeDigitalPin(Arduino,'D13',1); %solta Objeto
       
       
        
        %     Sai da Posição de Descarte e retorna a posição Inicial
%        writePosition(Base, 0.5); %90/180
%         writePosition(Ombro, 0.7); %90/130
%         writePosition(Cotovelo, 0.6); %90/150
        %         
 movimentaServos(Base, Ombro, Cotovelo, TrajetoriaBaseDesIn, TrajetoriaOmbroDesIn, TrajetoriaCotoveloDesIn, tf, td, GraficoAtuador);
    end
    
    %% 8º) Retorno ao ponto inicial
    %
    % Após a execução do movimento, o manipulador retorna a posição inicial
    % determinada e já esta pronto para um novo input de imagem.
    
end
toc