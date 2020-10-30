function [Map] = snc(tracks, l, dia)
for m=1:size(tracks,2)
[C, iA, iB]=intersect(tracks(l).f,tracks(m).f);
Uq(:,1)=tracks(l).x(iA); Uq(:,2)=tracks(m).x(iB);
Uq(:,3)=tracks(l).y(iA); Uq(:,4)=tracks(m).y(iB);
Uq(:,5)=tracks(l).z(iA); Uq(:,6)=tracks(m).z(iB);
D=sqrt((Uq(:,1)-Uq(:,2)).^2+(Uq(:,3)-Uq(:,4)).^2+(Uq(:,5)-Uq(:,6)).^2);
B=zeros(size(D)); B(D<dia)=1; B(D>dia)=0; Map(m)=sum(B);
clear Uq
end
end