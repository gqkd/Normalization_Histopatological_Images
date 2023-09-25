function [C,beta_m,beta_b] = optimization_beta(W_m,W_b,I)
%Funzione che restituisce la stain color appearance Cs dei due coloranti
%ottimizzata rispetto alla fitness= 0.5.*(norm(Vs-Vopt,'fro').^2) in
%funzione delle variabili beta_ e beta_t che rappresentano il percentile delle due
%colorazioni 
%INPUT DELLA FUNZIONE: 
%   - W_m = immagine contenente le strutture marroni su sfondo nero 
%   - W_b = immagine contenente le strutture blu su sfondo nero 
%   - I = immagine nello spazio colore RGB 
%OUTPUT DELLA FUNZIONE: 
%   - C = stain color appearance nello spazio RGB
%   - beta_m = percentile ottimo per il calcolo della stain color
%   appearance dei marroni
%   - beta_b = percentile ottimo per il calcolo della stain color
%   appearance dei blu

%Definizione dei parametri utili: 
beta= [1,10:10:90,99]; 
[Nrow,Ncol,Nlayer]=size(I);
fitness=zeros(length(beta),length(beta));

%Vettorizzazione dell'immagine I
I_vett = zeros(Nlayer,Ncol*Nrow);
for i=1:Nlayer
    I_vett(i,:)=reshape(I(:,:,i),[1 Ncol*Nrow]);
end
%Optical density dell'immagine I: 
Vs=-log10(I_vett+10^(-8));  

%Calcolo della fitness per ogni combinazione dei parametri beta_m e beta_b
C = zeros(Nlayer,2);
for n=1:length(beta)
    for k=1:length(beta)  
        for i=1:Nlayer
            layer=W_m(:,:,i);
            C(i,1)=prctile(layer(W_m(:,:,i)~=0),beta(n));
            layer=W_b(:,:,i);
            C(i,2)= prctile(layer(W_b(:,:,i)~=0),beta(k));
        end
        Ws=-log10(C); 
        Hs=(pinv(Ws)*Vs);
        Hs(Hs<0) = 0; 
        Vopt = Ws*Hs; 
        fitness(n,k) = 0.5.*(norm(Vs-Vopt,'fro').^2);   
    end
end

%Calcolo del minimo della funzione fitness:
[m]=min(min(fitness));

%Calcolo della combinazione di beta_m e beta_b che minimizza la funzione
%fitness:
[row,col]=find(fitness==m);
beta_m=beta(row);
beta_b=beta(col);

%Calcolo della stain color appearance C ottimizzata minimizzando la funzione
%fitness:
for i=1:3
    layer=W_m(:,:,i);
    C(i,1)=prctile(layer(W_m(:,:,i)~=0),beta(row));
    layer=W_b(:,:,i);
    C(i,2)= prctile(layer(W_b(:,:,i)~=0),beta(col));
end
end 

