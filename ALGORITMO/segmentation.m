function [W_m,W_b,BWDAB]=segmentation(I)
%Funzione che prende in ingresso l'immagine I in formato double RGB e permette
%di ottenere la segmentazione dei nuclei marroni e delle strutture blu 
%applicando la tecnica del global thresholding. 

%INPUT DELLA FUNZIONE: 
%   -I = immagine source in formato double RGB 

%OUTPUT DELLA FUNZIONE: 
%   -W_m = immagine contenente solo i nuclei marroni su sfondo nero 
%   -W_b = immagine contenente solo le strutture blu su sfondo nero


%Definizione di parametri utili per la funzione:
%è possibile variare i parametri alpha e beta in modo tale che il rapporto 
%alpha/beta = 2
alpha=0.5;%[0 1]
beta=0.25;%[0 1]


%% SEGMENTAZIONE DEI NUCLEI MARRONI
%Creazione dell'immagine BN:
BN= I(:,:,3)-alpha.*I(:,:,1)-beta.*I(:,:,2);
BN(BN<0)=0;
BN=im2double(BN);
[x]=imhist(BN);

%Calcolo del picco principale dell'istogramma: 
[pks,locs]=findpeaks([0;x]);        %aggiunta dello zero come primo elemento dell'istogramma 
                                    %perchè la funzione findpeaks non trova il primo picco legato ai pixels neri
locs=locs-1;                        %correzione dell'indice calcolato 
[~,ind]=maxk(pks,2);                %Ricerca dei due picchi le cui tonalità corrispondono alle strutture marroni (primo picco trovato) 
                                    %e al background dell'immagine (secondo picco)
%Selezione del secondo picco:
if locs(ind(2))>locs(ind(1))
    M=ind(2);
else
    M=ind(1);
end
%Ricerca del minimo assoluto tra i due picchi precedentemente trovati:
[pks,locs]=findpeaks(-x(1:locs(M)));
[~,ind]=max(pks);
%Soglia per segmentare le strutture marroni:
TM=locs(ind);                       

%Maschera binaria per segmentare le strutture marroni:
BWDAB=(BN<TM/255);     

%Apertura maschera delle strutture marroni: 
se=strel('disk',1);
BWDAB=imopen(BWDAB,se);


%Calcolo immagine contenente solo le strutture marroni su sfondo nero (DAB) e 
%calcolo dell'immagine complementare (deDAB):
W_m=im2double(I).*BWDAB;
deDAB=im2double(I).*not(BWDAB);

%Operazioni per eliminare i pixel marroni più chiari selezionati nell'immagine W_m:
%Calcolo dell'optical density dell'immagine W_m
opD=-log2(W_m);
[x]=imhist(opD(:,:,3));

%Ricerca dei picchi corrispondenti ai pixels bianchi:
[pks,locs]=findpeaks([x;0]);                %aggiunta dello zero come ultimo elemento dell'istogramma 
                                            %perchè la funzione findpeaks non trova l'ultimo picco legato ai pixels bianchi
[~,Mind]=max(pks);                          %calcolo del picco dell'istogramma del layer B a cui corrispondono i pixels bianchi 
%Poichè il picco può essere formato da più punti
%(considerati anch'essi dei picchi), viene ricercato il picco meno
%pronunciato tra questi: 
[ind]=find(pks(1:Mind)>0.2*pks(Mind));      
ind(end)=[];                                
if isempty(ind)==1
    ind=Mind;
else
    [~,indx]=min(ind); 
    ind=ind(indx);
end
TM = locs(ind);                 %Posizione del picco trovato 
%Ricerca della valle precedente al picco trovato:
%Tale valle rappresenta la soglia utilizzata per segmentare le strutture
%marroni scure 
while x(TM-1)<x(TM)
    TM=TM-1;
end

%Maschera binaria per segmentare le strutture marrone scuro:
BW=(opD(:,:,3)<TM/255);

%Calcolo immagine contenente solo le strutture marroni su sfondo nero 
W_m=W_m.*not(BW);

%% SEGMENTAZIONE DELLE STRUTTURE BLU 
%Conversione dell'immagine deDAB nello spazio colore LAB:
lab=rgb2lab(deDAB,'WhitePoint','d65');
b=lab(:,:,3);

%Normalizzazione del layer b dell'immagine nello spazio LAB
b1=b-min(min(b));
b1=b1/max(max(b1));                     %layer b normalizzato           
x=imhist(b1);

%Ricerca del picco principale nell'istogramma: 
[pks,locs]=findpeaks(x);        
[~,Mind]=max(pks);
%Poichè il picco può essere formato da più punti
%(considerati anch'essi dei picchi), viene ricercato il picco meno
%pronunciato tra questi: 
[ind]=find(pks(1:Mind)>0.2*pks(Mind));
ind(end)=[];
if isempty(ind)==0
    [~,indx]=min(ind);
    ind=ind(indx);
else
    ind=Mind;
end
TB = locs(ind);             %Posizione del picco trovato 

%Ricerca della valle precedente al picco trovato:
%Tale valle rappresenta la soglia utilizzata per segmentare le strutture
%marroni scure 
while x(TB-1)<x(TB)
    TB=TB-1;
end

%Maschera binaria per segmentare le strutture blu:
BWdeDAB=(b1<TB/255);

%Apertura maschera blu:
se=strel('disk',1);
BWdeDAB=imopen(BWdeDAB,se);

%Calcolo immagine contenente solo le strutture blu su sfondo nero:
W_b=deDAB.*(BWdeDAB);
end