function [rse]=rSE(IsNorm,file,path)
%Funzione che calcola l'rSE dell'immagine normalizzata rispetto
%all'immagine target prendendo in input le coordinate dei punti scelti
%manualmente all'interno delle immagini source target
%INPUT DELLA FUNZIONE: 
%   - IsNorm = immagine source normalizzata 
%   - file = nome del file contenente le coordinate dei punti selezionati
%   manualmente
%   - path = percorso per caricare il file 
%OUTPUT DELLA FUNZIONE: 
%   -rse = relative squared error 

%Caricamento dati:
It = imread(path+"TARGET.jpg");It=im2double(It);
targ=load(path+"punti_target.mat");
sour=load(path+"punti_"+file(1:end-4)+".mat");

%Indici lineari:roe[Nrow,Ncol,Nlayer]=size(It);
p_mt=round(targ.tot_brown);
p_bt=round(targ.tot_blue);
p_ms=round(sour.tot_brown);
p_bs=round(sour.tot_blue);
idx_mt = sub2ind(size(It(:,:,1)), p_mt(:,2), p_mt(:,1));
idx_bt = sub2ind(size(It(:,:,1)), p_bt(:,2), p_bt(:,1));
idx_ms = sub2ind(size(IsNorm(:,:,1)), p_ms(:,2), p_ms(:,1));
idx_bs = sub2ind(size(IsNorm(:,:,1)), p_bs(:,2), p_bs(:,1));

%Calcolo dell'intensità media delle tonalità blu e marroni dei punti scelti all'interno
%dell'immagine target (Wt) e all'interno dell'immagine source (Ws):
for i=1:3
    layer=It(:,:,i);
    Wt(i,1)=mean(layer(idx_mt));
    Wt(i,2)=mean(layer(idx_bt));
    layer=IsNorm(:,:,i);
    Ws(i,1)=mean(layer(idx_ms));
    Ws(i,2)=mean(layer(idx_bs));
end

%Calclo rSE
rse=(norm(Wt-Ws,'fro'))^2/(norm(Wt,'fro')*norm(Ws,'fro'))*100;
end