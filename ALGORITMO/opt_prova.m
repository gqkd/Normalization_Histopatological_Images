function opt_prova(Hs,Ht,Wt,Is,It,W_mt,W_bt,W_ms,W_bs)

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

%funzione obiettivo
Ath = optimvar('Ath',1,'UpperBound',99,'LowerBound',1);
Atd = optimvar('Atd',1,'UpperBound',99,'LowerBound',1);
Ash = optimvar('Ash',1,'UpperBound',99,'LowerBound',1);
Asd = optimvar('Asd',1,'UpperBound',99,'LowerBound',1);

obj=obiettivo(Ath,Atd,Ash,Asd,Is,It,Hs,Ht,Wt,p_mt,p_bt,p_ms,p_bs);
prob = optimproblem('Objective',obj);
x0.x = [0 0];
[sol,fval,exitflag,output] = solve(prob,x0)
end

function [rse]=obiettivo(Ath,Atd,Ash,Asd,Is,It,Hs,Ht,Wt,p_mt,p_bt,p_ms,p_bs)
n_coloranti=2;
Nlayer=3;
[Nrow,Ncol,~]=size(Is);

    HsRM(1,1) = prctile(Hs(1,:), Ath);
    HtRM(1,1) = prctile(Ht(1,:), Atd);
    HsRM(2,1) = prctile(Hs(2,:), Ash);
    HtRM(2,1) = prctile(Ht(2,:), Asd);
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

idx_mt = sub2ind(size(It(:,:,1)), p_mt(:,1), p_mt(:,2));
idx_bt = sub2ind(size(It(:,:,1)), p_bt(:,1), p_bt(:,2));
idx_ms = sub2ind(size(IsNorm(:,:,1)), p_ms(:,1), p_ms(:,2));
idx_bs = sub2ind(size(IsNorm(:,:,1)), p_bs(:,1), p_bs(:,2));

for i=1:3
    layer=It(:,:,i);
    Wt(i,1)=median(layer(idx_mt));
    Wt(i,2)=median(layer(idx_bt));
    layer=IsNorm(:,:,i);
    Ws(i,1)=median(layer(idx_ms));
    Ws(i,2)=median(layer(idx_bs));
end

rse=(norm(Wt-Ws,'fro'))^2/(norm(Wt,'fro')*norm(Ws,'fro'))*100;
end