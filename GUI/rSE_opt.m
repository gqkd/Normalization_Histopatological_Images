function [rse]=rSE_opt(IsNorm,It,p_mt,p_bt,p_ms,p_bs)
%Funzione che calcola l'rSE dell'immagine normalizzata rispetto
%all'immagine target prendendo in input le coordinate di tutti i punti prsenti
%all'interno delle strutture legate alla diaminobenzidina e
%all'ematossilina segmentate nelle immagini source e target 
%INPUT DELLA FUNZIONE: 
%   - IsNorm = immagine source normalizzata
%   - It = immagine target 
%   - p_mt = coordinate dei punti scelti all'interno dell'immagine contenente le strutture
%   marroni dell'immagine target
%   - p_bt = coordinate dei punti scelti all'interno dell'immagine contenente le strutture
%   blu dell'immagine target
%   - p_ms = punti scelti all'interno dell'immagine contenente le strutture
%   marroni dell'immagine source
%   - p_bs = coordinate dei punti scelti all'interno dell'immagine contenente le strutture
%   blu dell'immagine source

%OUTPUT DELLA FUNZIONE: 
%   - rSE = relative squared error

%Indici lineari:
idx_mt = sub2ind(size(It(:,:,1)), p_mt(:,1), p_mt(:,2));
idx_bt = sub2ind(size(It(:,:,1)), p_bt(:,1), p_bt(:,2));
idx_ms = sub2ind(size(IsNorm(:,:,1)), p_ms(:,1), p_ms(:,2));
idx_bs = sub2ind(size(IsNorm(:,:,1)), p_bs(:,1), p_bs(:,2));

%Calcolo dell'intensità mediana delle tonalità blu e marroni dei punti scelti all'interno
%dell'immagine target (Wt) e all'interno dell'immagine source (Ws)

for i=1:3
    layer=It(:,:,i);
    Wt(i,1)=median(layer(idx_mt));
    Wt(i,2)=median(layer(idx_bt));
    layer=IsNorm(:,:,i);
    Ws(i,1)=median(layer(idx_ms));
    Ws(i,2)=median(layer(idx_bs));
end

%Calcolo rSE:
rse=(norm(Ws-Wt,'fro'))^2/(norm(Wt,'fro')*norm(Ws,'fro'))*100;
end