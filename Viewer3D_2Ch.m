% Giuseppe Di Caprio 201030

function Viewer3D_2Ch(FV, Coord, info, dataVir, tracks_cluster, p, dataN)

sld = uicontrol('Style', 'slider','Min',1,'Max',dataVir(dataN).movieLength,'SliderStep',[1/dataVir(dataN).movieLength .01],'Position', [20 20 400 20],'Value',1,'callback',@sld_Callaback);
sld1 = uicontrol('Style', 'slider','Min',1,'Max',size(tracks_cluster,2), 'SliderStep',[1/size(tracks_cluster,2) .01], 'Position', [20 50 400 20],'Value',1,'callback',@sld1_Callaback);

l=1; fig=subplot(2,5,[1:3 6:8]);fig=patch('Faces',FV{l}.faces,'Vertices',FV{l}.vertices);
fig.FaceColor = 'red'; fig.EdgeColor = 'none'; daspect([1 1 1])
axis tight, camlight, lighting gouraud, hold on; view(-32, 26)
% fig.Parent.XLim=[0 375];fig.Parent.YLim=[0 512];
btn = uicontrol('Style', 'pushbutton','String','Raw data','Position', [100 100 50 20],'Callback', @btn_Callaback);
btn1 = uicontrol('Style', 'pushbutton','String','Amplitude','Position', [dataVir(dataN).movieLength 100 50 20],'Callback', @btn1_Callaback);

function m=sld1_Callaback(src,erv)
m = round(get(sld1,'value'));
idx=[0 find(isnan(tracks_cluster(m).f)) size(tracks_cluster(m).f,2)+1];
col=jet(size(idx,2)-1);
n=0;
for o=1:size(idx,2)-1
    T{o}.x=NaN(1,dataVir(dataN).movieLength); T{o}.x(tracks_cluster(m).f(idx(o)+1:idx(o+1)-1))=tracks_cluster(m).x(idx(o)+1:idx(o+1)-1);
    T{o}.y=NaN(1,dataVir(dataN).movieLength); T{o}.y(tracks_cluster(m).f(idx(o)+1:idx(o+1)-1))=tracks_cluster(m).y(idx(o)+1:idx(o+1)-1);
    T{o}.z=NaN(1,dataVir(dataN).movieLength); T{o}.z(tracks_cluster(m).f(idx(o)+1:idx(o+1)-1))=tracks_cluster(m).z(idx(o)+1:idx(o+1)-1);
    T{o}.f=NaN(1,dataVir(dataN).movieLength); T{o}.f(tracks_cluster(m).f(idx(o)+1:idx(o+1)-1))=tracks_cluster(m).f(idx(o)+1:idx(o+1)-1);
    T{o}.A=NaN(1,dataVir(dataN).movieLength); T{o}.A(tracks_cluster(m).f(idx(o)+1:idx(o+1)-1))=tracks_cluster(m).A(idx(o)+1:idx(o+1)-1);    
end
Tt=zeros(1,dataVir(dataN).movieLength);
for o=1:size(T,2)
    A=[Tt;T{o}.A]; Tt=sum(A,'omitnan');
end
for o=1:size(idx,2)-1
    subplot(2,5,[1:3 6:8]); 
    n=n+1;
    plot3(T{o}.x(1:l),T{o}.y(1:l),size(info,1)-T{o}.z(1:l),'Linewidth',3,'color', col(n,:)); hold on
end
for o=1:size(idx,2)-1
subplot(2,5,9:10), plot(T{o}.f,T{o}.A,'Linewidth',3,'color', col(o,:)), hold on
end
plot(Tt,'k','Linewidth',1), title(num2str(m))
G=get(gca); line([l l], G.YLim,'Linewidth',3), hold off
end

function l=sld_Callaback(src,erv)
Xlim=fig.Parent.XLim; Ylim=fig.Parent.YLim; Zlim=fig.Parent.ZLim;
l = round(get(sld,'value'));
fig.Faces=FV{l}.faces; fig.Vertices=FV{l}.vertices;
fig1.XData=Coord{l}.x; fig1.YData=Coord{l}.y; fig1.ZData=size(info,1)-Coord{l}.z;
fig3.XData=[]; fig3.YData=[]; fig3.ZData=[];

m = round(get(sld1,'value'));
idx=[0 find(isnan(tracks_cluster(m).f)) size(tracks_cluster(m).f,2)+1];
col=jet(size(idx,2)-1);
n=0;
for o=1:size(idx,2)-1
    T{o}.x=NaN(1,dataVir(dataN).movieLength); T{o}.x(tracks_cluster(m).f(idx(o)+1:idx(o+1)-1))=tracks_cluster(m).x(idx(o)+1:idx(o+1)-1);
    T{o}.y=NaN(1,dataVir(dataN).movieLength); T{o}.y(tracks_cluster(m).f(idx(o)+1:idx(o+1)-1))=tracks_cluster(m).y(idx(o)+1:idx(o+1)-1);
    T{o}.z=NaN(1,dataVir(dataN).movieLength); T{o}.z(tracks_cluster(m).f(idx(o)+1:idx(o+1)-1))=tracks_cluster(m).z(idx(o)+1:idx(o+1)-1);
    T{o}.f=NaN(1,dataVir(dataN).movieLength); T{o}.f(tracks_cluster(m).f(idx(o)+1:idx(o+1)-1))=tracks_cluster(m).f(idx(o)+1:idx(o+1)-1);
    T{o}.A=NaN(1,dataVir(dataN).movieLength); T{o}.A(tracks_cluster(m).f(idx(o)+1:idx(o+1)-1))=tracks_cluster(m).A(idx(o)+1:idx(o+1)-1);    
end
Tt=zeros(1,dataVir(dataN).movieLength);
for o=1:size(T,2)
    A=[Tt;T{o}.A]; Tt=sum(A,'omitnan');
end
for o=1:size(idx,2)-1
    subplot(2,5,[1:3 6:8]); 
    n=n+1;
    plot3(T{o}.x(1:l),T{o}.y(1:l),size(info,1)-T{o}.z(1:l),'Linewidth',3,'color', col(n,:)); hold on
end
for o=1:size(idx,2)-1
subplot(2,5,9:10), plot(T{o}.f,T{o}.A,'Linewidth',3,'color', col(o,:)), hold on
end
plot(Tt,'k','Linewidth',1), title(num2str(m))
G=get(gca); line([l l], G.YLim,'Linewidth',3), hold off

fig.Parent.XLim=Xlim; fig.Parent.YLim=Ylim; fig.Parent.ZLim=Zlim;
for o=1:size(idx,2)-1
mx(o)=round(T{o}.x(l)); my(o)=round(T{o}.y(l)); mz(o)=round(T{o}.z(l));
end

PDS=dataVir(dataN).framePathsDS;
% for m=1:size(info,1)%
n=0;
for m=round(max(1,size(info,1)-T{o}.z(l)-2)):round(min(size(info,1),size(info,1)-T{o}.z(l)+4))
AT=double(imread(PDS{1}{l},m));
n=n+1;A2(:,:,n)=(AT);
end
rng=15; %AM=A2(y-rng:y+rng,x-rng:x+rng,:);
mip = max(A2, [], 3); subplot(4,5,4),imagesc(mip), axis image,hold on
for o=1:size(idx,2)-1
plot(T{o}.x(l),T{o}.y(l),'o','color', col(o,:),'Markersize',20, 'Linewidth', 3)
end
hold off
rng=15; xlim([min(mx)-rng max(mx)+rng]), ylim([min(my)-rng max(my)+rng])
c1=min(min(mip(min(my)-rng:max(my)+rng,min(mx)-rng:max(mx)+rng))); c2=max(max(mip(min(my)-rng:max(my)+rng,min(mx)-rng:max(mx)+rng)));
caxis([c1 c2]), colormap jet
mip = squeeze(max(A2, [], 1)); subplot(4,5,9),imagesc(mip'), axis image
rng=15; xlim([min(mx)-rng max(mx)+rng])
caxis([c1 c2]), colormap jet

n=0;
for m=round(max(1,size(info,1)-T{o}.z(l)-2)):round(min(size(info,1),size(info,1)-T{o}.z(l)+4))
AT=double(imread(PDS{2}{l},m));
n=n+1;A2(:,:,n)=(AT);
end
rng=15; %AM=A2(y-rng:y+rng,x-rng:x+rng,:);
mip = max(A2, [], 3); subplot(4,5,5),imagesc(mip), axis image,hold on
for o=1:size(idx,2)-1
plot(T{o}.x(l),T{o}.y(l),'o','color', col(o,:),'Markersize',20, 'Linewidth', 3)
end
hold off
rng=15; xlim([min(mx)-rng max(mx)+rng]), ylim([min(my)-rng max(my)+rng])
c1=min(min(mip(min(my)-rng:max(my)+rng,min(mx)-rng:max(mx)+rng))); c2=max(max(mip(min(my)-rng:max(my)+rng,min(mx)-rng:max(mx)+rng)));
caxis([c1 c2]), colormap jet
mip = squeeze(max(A2, [], 1)); subplot(4,5,10),imagesc(mip'), axis image
rng=15; xlim([min(mx)-rng max(mx)+rng])
caxis([c1 c2]), colormap jet


end

function btn_Callaback(src,erv)
[x,y] = ginput(1); x=round(x); y=round(y);
PDS=dataVir(dataN).framePathsDS;
for m=1:size(info,1)
AT=double(imread(PDS{1}{l},m));
A(:,:,m)=(AT);
end
rng=15; AM=A(y-rng:y+rng,x-rng:x+rng,:);
mip = max(A, [], 3); subplot(2,5,4:5),imagesc(mip), axis image,
rng=15; xlim([x-rng x+rng]); ylim([y-rng y+rng]); caxis([min(AM(:)) max(AM(:))])
end


% function btn1_Callaback(src,erv)
% pts = ginput(1);
% TrTx=[]; TrTy=[];
% for idx=1:size(TrM,2)
% TrTx=[TrTx TrM(idx).x];
% TrTy=[TrTy TrM(idx).y];
% end
% trn=ceil(knnsearch([(TrTx)',(TrTy)'],pts)/200);
% plot3(TrM(p(trn)).x,TrM(p(trn)).y,size(info,1)-TrM(p(trn)).z,'.k','Markersize',10)
% subplot(2,5,9:10), plot(tracks_cluster(p(trn)).f,tracks_cluster(p(trn)).A)
% end
end

