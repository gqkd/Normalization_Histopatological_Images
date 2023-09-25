function [alpha_s,alpha_t] = optimization_alpha(Hs,Ht,Wt,Is,It,W_mt,W_bt,W_ms,W_bs)
%Funzione che ottimizza la scelta dei parametri aplha_s e alpha_t che
%vengono successivamente utilizzati per la normalizzazione della stain
%density map Hs rispetto alla funzione rSE
%INPUT DELLA FUNZIONE: 
%   - Hs = stain density map dell'immagine source
%   - Ht = stain density map dell'immagine target
%   - Wt = stain color appearance dei coloranti presenti nell'immagine target 
%   - Is = immagine source
%   - It = immagine target 
%   - W_mt = immagine contenente le strutture marroni dell'immagine target su sfondo nero 
%   - W_bt = immagine contenente le strutture blu dell'immagine target su sfondo nero
%   - W_ms = immagine contenente le strutture marroni dell'immagine source su sfondo nero 
%   - W_bs = immagine contenente le strutture blu dell'immagine source su sfondo nero
%OUTPUT DELLA FUNZIONE: 
%   - alpha_s = percentile ottimo per il calcolo dello pseudo massimo
%   robusto della stain density map Hs
%   - alpha_t = percentile ottimo per il calcolo dello pseudo massimo
%   robusto della stain density map Ht
%% Scelta dei punti dell'immagine source Is e dell'immagine target It su cui calcolare l'rSE:
%E' stato scelto di calcolare l'rSE su tutti punti presenti nelle immagini W_ms, W_bs, W_mt e W_bt

%Selezione dei pixels diversi da quelli neri sull'immagine target:
[row,col]=find(W_mt(:,:,1)>0);
p_mt=[row,col];
[row,col]=find(W_bt(:,:,1)>0);
p_bt=[row,col];

%Selezione dei pixels diversi da quelli neri sull'immagine source:
[row,col]=find(W_ms(:,:,1)>0);
p_ms=[row,col];
[row,col]=find(W_bs(:,:,1)>0);
p_bs=[row,col];
%% Valutazione iteraitva dei parametri:

%Definizione dei parametri utili 
alpha=90:99;
n_coloranti=2;
Nlayer=3;
rse = zeros(length(alpha),length(alpha));
[Nrow,Ncol,~]=size(Is);
HsRM = zeros(n_coloranti, 1);           
HtRM = zeros(n_coloranti, 1);

%Calcolo dell'rSE per ogni combinazione di alpha_s e alpha_t:
for n=1:length(alpha)
    for k=1:length(alpha)
        for j=1:n_coloranti
            HsRM(j,1) = prctile(Hs(j,:), alpha(n));
            HtRM(j,1) = prctile(Ht(j,:), alpha(k));
        end
        %Normalizzazione della stain density map Hs dell'immagine source
        %rispetto agli pseudo-massimi robusti calcolati su Hs e Ht:
        HsNorm = zeros(n_coloranti, Nrow*Ncol);
        for j=1:n_coloranti
            HsNorm(j,:)=(Hs(j,:)/HsRM(j,:))*HtRM(j,:);
        end
        
        %Normalizzazione dell'immagine source nello spazio dell'optical
        %density:
        VsNorm=Wt*HsNorm;
        
        %Trasformazione dell'immagine source nello spazio RGB invertendo la
        %relazione di Lambert-Beer:
        IsNormalizzata=10.^(-VsNorm);
        
        %Ricomposizione dell'immagine source nella matrice righe x colonne x layers RGB:
        IsNorm = zeros(Nrow,Ncol,Nlayer);
        for i=1:Nlayer
            IsNorm(:,:,i)=reshape(IsNormalizzata(i,:),[Nrow Ncol]);
        end
        rse(n,k)=rSE_opt(IsNorm,It,p_mt,p_bt,p_ms,p_bs);
    end
end

%Calcolo del minimo della funzione rSE_opt:
[m]=min(min(rse));

%Calcolo della combinazione di alpha_s e alpha_t che minimizza la funzione
%rSE_opt:
[row,col]=find(rse==m);
alpha_s=alpha(row);
alpha_t=alpha(col);
end

