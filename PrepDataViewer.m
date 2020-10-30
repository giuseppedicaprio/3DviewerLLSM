function PrepDataViewer(dataVir)
for dataN=1:size(dataVir,2)
clearvars  -except dataVir dataN
tic
header_name = [dataVir(dataN).source,'Analysis/Masks/'];
dirOutput1 = dir(fullfile(header_name,'*.tif'));
pic = {dirOutput1.name}';
info = imfinfo([header_name pic{1}]);

% Filter by duration
load([dataVir(dataN).source 'Analysis/ProcessedTracks_split.mat']);
tracks_cluster=load([dataVir(dataN).source 'Analysis/ProcessedTracks_clustered.mat']); tracks_cluster=tracks_cluster.tracks;
for l=1:size(tracks_cluster,2)
    D(l)=tracks_cluster(l).lifetime_s/dataVir(dataN).framerate;
end
p=find(D>dataVir(dataN).movieLength*0.3);

parfor m=1:dataVir(dataN).movieLength
[fv,x,y,z]=PDV(m, header_name, info, pic, tracks_cluster, p);
FV{m}=fv; Coord{m}.x=x; Coord{m}.y=y; Coord{m}.z=z;
end

load([dataVir(dataN).source 'Analysis/ProcessedTracks_split.mat']);
n=0;
for l=1:size(p,2)
    for m=1:size(QQ{p(l)},2)
        n=n+1; 
        Tr(n).x = NaN(1,dataVir(dataN).movieLength); Tr(n).x(tracks(QQ{p(l)}(m)).f(1):tracks(QQ{p(l)}(m)).f(end))=tracks(QQ{p(l)}(m)).x(1,:);
        Tr(n).y = NaN(1,dataVir(dataN).movieLength); Tr(n).y(tracks(QQ{p(l)}(m)).f(1):tracks(QQ{p(l)}(m)).f(end))=tracks(QQ{p(l)}(m)).y(1,:);
        Tr(n).z = NaN(1,dataVir(dataN).movieLength); Tr(n).z(tracks(QQ{p(l)}(m)).f(1):tracks(QQ{p(l)}(m)).f(end))=tracks(QQ{p(l)}(m)).z(1,:);
    end
end

idx=0;
for n=1:size(p,2)
for m=1:size(QQ{p(n)},2)
idx=idx+1;
TrTX(m,:)=Tr(idx).x; TrTY(m,:)=Tr(idx).y; TrTZ(m,:)=Tr(idx).z;
end
TrM(n).x=nanmean(TrTX,1); TrM(n).y=nanmean(TrTY,1); TrM(n).z=nanmean(TrTZ,1);
clear TrTX TrTY TrTZ
end
save([dataVir(dataN).source 'Analysis' filesep 'ViewerData.mat'],'FV', 'Coord', 'info', 'tracks_cluster','p')
[dataN toc]
end
end