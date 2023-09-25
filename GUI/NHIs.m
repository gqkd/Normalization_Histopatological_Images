function [IsNorm]=NHIs(fileSource,pathSource,fileTarget,pathTarget)
%% ALGORITMO NHIs PER LA NORMALIZZAZIONE DI IMMAGINI ISTOPATOLOGICHE 
%Algoritmo che data un'immaginee source ne calcola la corrsipettiva
%immagine normalizzata rispetto all'immagine target
%QUESTO ALGORITMO HA LA FINALITA' DI CALCOLARE:
%   - IsNorm = immagine source normalizzata rispetto all'immagine
%              target
%   - rse = relative squared error, parametro per la quantificazione
%           dell'errore sulla normalizzazione dell'immagine source rispetto
%           all'immagine target
%clc; clear; close all; 
%% ESTRAZIONE DELLA STAIN COLOR APPEARANCE E DELLA STAIN DENSITY MAP DALL'IMMAGINE TARGET:
%DEFINIZIONE DELLE VARIABILI UTILIZZATE:
%   - Vt = optical density dell'immagine ottenuta applicando la legge inversa di
%          Lambert-Beer
%   - Wt = [W|dab W|ematossilina]
%           matrice della stain color appearance, dimensione 3x2 che contiene
%           la codifica RGB dei coloranti presenti nell'immagine target (diaminobenzidina e ematossilina)
%   - Ht = [C|dab; C|ematossilina]
%           matrice della stain density map, dimensione 2x(righe*colonne immagine target)
%           che contiene la concentrazione dei coloranti presenti
%           nell'immagine (prima riga rappresenta la concentrazione di
%           diaminobenzidina e seconda riga rappresenta la concentrazione di
%           ematossilina).

%Caricamento dell'immagine target:
filenameT=sprintf('%s%s',pathTarget,fileTarget);
filenameT = convertCharsToStrings(filenameT);
Itarget=imread(filenameT); Itarget = im2double(Itarget);
%Itarget = imread("TARGET.jpg"); Itarget = im2double(Itarget);

%Definizione di parametri utili:
[Nrow,Ncol,Nlayer]=size(Itarget);
n_coloranti = 2;                    %numero di coloranti considerati (diaminobenzidina e ematossilina)
beta_m= 20;                         %percentile per il calcolo della tonalità della diaminobenzidina
beta_b=10;                           %percentile per il calcolo della tonalità dell'ematossilina
delta =10^(-8);                     %parametro che viene sommato all'immagine in modo tale che i pixel neri
                                    %non producano delle singolarità quando viene calcolata l'optical density 

%Vettorizzazione dell'immagine target:
It = zeros(Nlayer, Nrow*Ncol);
for i=1:Nlayer
    It(i,:)=reshape(Itarget(:,:,i),[1 Nrow*Ncol]);
end

%Calcolo della optical density dell'immagine target mediante la legge
%inversa di Lambert-Beer:
Vt=-log10(It+delta);

%Segmentazione dei nuclei legati alla diaminobenzidina (W_m), delle
%strutture legate all'ematossilina (W_b):
%   - W_mt = immagine contenente solo le strutture marroni su sfondo nero
%   - W_bt = immagine contenente solo le strutture blu su sfondo nero

[W_mt,W_bt]=segmentation(Itarget);

%Calcolo della stain color appearance nello spazio RGB della diaminobenzidina e dell'ematossilina
%come beta-percentile della distribuzione delle tonalità della
%diaminobenzidina nell'immagine W_mt e delle tonalità dell'ematossilina
%nell'immagine W_bt (senza tener conto dei pixels neri)
%   - Ct = matrice [3x2] contenente sulle colonne le tonalità marroni e blu
%   nello spazio RGB 

Ct = zeros(Nlayer,n_coloranti);
for i=1:Nlayer
    layer=W_mt(:,:,i);
    Ct(i,1)=prctile(layer(W_mt(:,:,i)~=0),beta_m);  
    layer=W_bt(:,:,i);
    Ct(i,2)= prctile(layer(W_bt(:,:,i)~=0),beta_b);
end

%Calcolo dell'optical density della stain color appearance Wt
%( Wt = [W|dab W|ematossilina] )
Wt=-log10(Ct);

%Calcolo della stain density map (Ht=[C|dab; C|ematossilina])
%invertendo la relazione che lega Ht a Vt e Wt.
%Vt = - log10(It) = Wt * Ht
%Di conseguenza Ht = Vt*(Wt^-1). Ma Wt è matrice rettangolare di
%dimensione 3x2. Per calcolarne l'inversa è necessario procedere con il
%calcolo della matrice pseudo inversa di Moore-Penrose nel seguente
%modo:
Ht=(pinv(Wt)*Vt);
Ht(Ht<0) = 0;         %Da un punto di vista fisico non è possibile ottenere dei valori
                      %di densità di colorante negativi. Quindi tutti i valori negativi vengono messi a 0


%% ESTRAZIONE DELLA STAIN COLOR APPEARANCE E DELLA STAIN DENSITY MAP DALL'IMMAGINE SOURCE:
%   - Vs = optical density dell'immagine ottenuta applicando la legge di
%          Lambert-Beer
%   - Ws = [W|dab W|ematossilina]
%           matrice della stain color appearance, dimensione 3x2 che contiene
%           la codifica RGB dei coloranti presenti nell'immagine source (diaminobenzidina e ematossilina)
%   - Hs = [C|dab; C|ematossilina]
%           matrice della stain density map, dimensione 2x(righe*colonne immagine source)
%           che contiene la concentrazione dei coloranti presenti
%           nell'immagine (prima riga rappresenta la concentrazione di
%           diaminobenzidina e seconda riga rappresenta la concentrazione di
%           ematossilina).

%Caricamento dell'immagine source:
filenameS=sprintf('%s%s',pathSource,fileSource);
filenameS = convertCharsToStrings(filenameS);
I = imread(filenameS); I = im2double(I);

%Definizione di parametri utili:
[Nrow,Ncol,Nlayer]=size(I);

%Vettorizzazione dell'immagine source:
Is = zeros(Nlayer, Nrow*Ncol);
for i=1:Nlayer
    Is(i,:)=reshape(I(:,:,i),[1 Ncol*Nrow]);
end

%Calcolo della optical density dell'immagine target mediante la legge
%inversa di Lambert-Beer:
Vs=-log10(Is+delta);

%Segmentazione dei nuclei legati alla diaminobenzidina (W_m), delle
%strutture legate all'ematossilina (W_b):
%   - W_ms = immagine contenente solo le strutture marroni su sfondo nero
%   - W_bs = immagine contenente solo le strutture blu su sfondo nero
[W_ms,W_bs]=segmentation(I);

%Calcolo della stain color appearance nello spazio RGB della diaminobenzidina e dell'ematossilina
%come beta-percentile della distribuzione delle tonalità della
%diaminobenzidina nell'immagine W_ms e delle tonalità dell'ematossilina
%nell'immagine W_bs (senza tener conto dei pixels neri)
%   - Cs = matrice [3x2] contenente sulle colonne le tonalità marroni e blu
%   nello spazio RGB  
%utilizzo della funzione "optimization" per calcolare i valori
%RGB dei coloranti che minimizzano l'errore tra l'optical density stimata
%sull'immagine source e l'optical density reale dell'immagine source
[Cs,beta_m,beta_b] = optimization_beta(W_ms,W_bs,I);

%Calcolo dell'optical density della stain color appearance Ws  
%( Ws = [W|dab W|ematossilina] )
Ws=-log10(Cs);

%Calcolo della stain density map Hs ([C|dab; C|ematossilina])
%invertendo la relazione che lega Hs a Vs e Ws.
%Vs = - log10(Is) = Ws * Hs
%Di conseguenza Hs = Vs*(Ws^-1). Ma Ws è matrice rettangolare di
%dimensione 3x2. Per calcolarne l'inversa è necessario procedere con il
%calcolo della matrice pseudo inversa di Moore-Penrose nel seguente
%modo:
Hs=(pinv(Ws)*Vs);
Hs(Hs<0) = 0;               %Da un punto di vista fisico non è possibile ottenere dei valori
                            %di densità di colorante negativi. Quindi tutti i
                            %valori negativi vengono messi a 0

%% NORMALIZZAZIONE DELL'IMMAGINE SOURCE AVENDO A DISPOSIZIONE Ht, Wt, Hs e Ws
%Calcolo dello pseudo-massimo robusto delle stain density maps ottenute dall'immagine target (Ht)
%e dall'immagine source (Hs) : utilizzo di una funzione che calcola gli
%apha ottimi al fine di minimizzare rSE sull'immagine source
[alpha_s,alpha_t] = optimization_alpha(Hs,Ht,Wt,I,Itarget,W_mt,W_bt,W_ms,W_bs);

HsRM = zeros(n_coloranti, 1);
HtRM = zeros(n_coloranti, 1);
for j=1:n_coloranti
    HsRM(j,1) = prctile(Hs(j,:), alpha_s);
    HtRM(j,1) = prctile(Ht(j,:), alpha_t);
end

%Normalizzazione della stain density map Hs dell'immagine source
%rispetto agli pseudo-massimi robusti calcolati su Hs e Ht:
HsNorm = zeros(n_coloranti, Nrow*Ncol);
for j=1:n_coloranti
    HsNorm(j,:)=(Hs(j,:)/HsRM(j,:))*HtRM(j,:);
end

%Normalizzazione dell'immagine source nello spazio dell'optical
%density:
%   -Wt = stain color appearance DELL'IMMAGINE TARGET, che contiene
%         l'apparenza ottimale dei coloranti
%   -HsNorm = stain density map DELL'IMMAGINE SOURCE, che contiene la
%             concentrazione normalizzata dei coloranti
VsNorm=Wt*HsNorm;

%Trasformazione dell'immagine source nello spazio RGB invertendo la
%relazione di Lambert-Beer:
IsNormalizzata=10.^(-VsNorm);

%Ricomposizione dell'immagine source nella matrice righe x colonne x layers RGB:
IsNorm = zeros(Nrow,Ncol,Nlayer);
for i=1:Nlayer
    IsNorm(:,:,i)=reshape(IsNormalizzata(i,:),[Nrow Ncol]);
end

end