%% Localiza as coordenadas do Objeto
%==========================================================================
% A função coordObjeto identifica e retorna as coordenadas do objeto
% identificado na imagem.
%
% Parametros de Entrada:
%
% - I1 = Imagem Camera 1
% - I2 = Imagem Camera 2
% - stereoParams = Parametros das cameras
% - raio = vetor de alcance do raio do objeto em pixels [min max]
% - sensibilidade = sensibilidade da função de identificação, entre 0 e 1
% - OrigemPixel = Coordenadas da origem em pixel [ U V ]
% - PixelPorMm = relação entre pixels por milimetros
% - H = distancia das Cameras ao chão
% - Imshow = Ativa ou desativa Imagem de confirmação. Valores Logicos
%
% Parametros de Saida:
%
% - Ponto = Coordenadas Globais do Objeto [ X Y Z]
% - PositionC1 = Coordenada C1 do objeto em pixels
% - PositionC2 = Coordenada C2 do objeto em pixels
% - Wob = Coordenada W do objeto em pixels
%
% OBS: Para encontrar os valores de raio e PixelPorMm, utilize a função
% imdistline()
function [Ponto, PositionC1, PositionC2, Wob] = coordObjeto(I1, I2, I2Ori, stereoParams, raio, sensibilidade, OrigemPixel, PixelPorMm, H, Imshow)
%% Calculo Uob e Vob
    % Remove distorção das  Imagens
    I1d = undistortImage(I1,stereoParams.CameraParameters1);
    I2d = undistortImage(I2,stereoParams.CameraParameters2);
    RefPixelDistorcido = imref2d(size(I2));
    
%     figure();
%     imshowpair(I1d, I2d, 'montage'); 
%     title('Imagens de Entrada Distorcidas');

    % Localiza Circulo na imagem
    [C1,R1] = imfindcircles(I1d,raio,'ObjectPolarity','dark', ...
                            'Sensitivity',sensibilidade);   %identifica circulo
                        
    [C2,R2] = imfindcircles(I2d,raio,'ObjectPolarity','dark', ...
                            'Sensitivity',sensibilidade); % localiza centro e diametro   
    
    Uob = C2(1,1);
    Vob = C2(1,2);
    
    Cs1 = [C1(1,1) C1(1,2)];
    Cs2 = [C2(1,1) C2(1,2)];
    
    PositionC1 = [C1(1, 1) C1(1, 2) R1(1)]; %Vetor Posição
    PositionC2 = [C2(1, 1) C2(1, 2) R2(1)]; %Vetor Posição

%% Calculo Wob
   
    % detecta imagem

    % Triangulação
    point3d = triangulate(Cs1, Cs2, stereoParams); %triangula posição
    Wob = norm(point3d)/1; %dist Camera ponto
 
    %% Calcula distancia real do objeto a origem
    Y = (round((Uob - OrigemPixel(1))/PixelPorMm));
%     if( Y <0)
%         Y=Y-10;
%     end
    X = (round((Vob - OrigemPixel(2))/PixelPorMm)+0);
    Z = H;
    
    
    
        
    %% Plot
    
    if (Imshow == true)
        % Mostra imagem com distancia
        %dist = sprintf('H = %0.2f mm', Wob);
         ponto = sprintf('X = %d mm, Y = %d mm, Z = %d mm',  X, Y, Z);   
        etiqueta = sprintf('Objeto Identificado');
       % I1d = insertObjectAnnotation(I1Ori,'circle',PositionC1,distanceAsString,'FontSize',18);
        I2Orid = insertObjectAnnotation(I2Ori,'circle',PositionC2, etiqueta,'FontSize',18);
       % I1d = insertShape(I1d,'circle',PositionC1);
        I2Orid = insertShape(I2Orid,'circle',PositionC2);

        figure();
        imshow(I2Orid,RefPixelDistorcido);
        h = viscircles(C2(1,:) , R2(1) );  %desenha circulos
        hold on
        plot(OrigemPixel(1), OrigemPixel(2), 'b*') %plota Origem na foto
        hold on
        plot( Uob(:), Vob(:), 'ro') % exibe Centro do disco
        legend('Coordenada Origem', 'Centro do Objeto');
        
          
    end


    Ponto = [X Y Z]; %Distancia em mm eu acho
 
    

end