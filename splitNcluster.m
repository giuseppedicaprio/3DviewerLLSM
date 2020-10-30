function [] = splitNcluster(data, dia)

for dataN=1:size(data,2)
tic
clearvars -except data dataN dia
var=load([data(dataN).source 'Analysis/ProcessedTracks.mat'], 'tracks'); trk=var.tracks;

i4 = [trk.catIdx]==4; p_i4 =find(i4==1);
i3 = [trk.catIdx]==3; p_i3=find(i3==1);
i2 = [trk.catIdx]==2; p_i2=find(i2==1);

pt_i3=p_i3(find([trk(p_i3).end]-[trk(p_i3).start]+1>25));
pt_i2=p_i2(find([trk(p_i2).end]-[trk(p_i2).start]+1>25));

p=[p_i4 pt_i3 pt_i2]; trk=trk(p);


tracksfn=fieldnames(trk);

tracks_split = struct('t', [], 'f',[], 'x', [], 'y', [], 'z', [], 'A', [],...
    'c', [], 'x_pstd', [], 'y_pstd', [], 'z_pstd', [],...
    'A_pstd', [], 'c_pstd', [], 'sigma_r', [],...
    'SE_sigma_r', [], 'pval_Ar', [], 'isPSF', [],...
    'tracksFeatIndxCG', [], 'gapVect', [], 'gapStatus', [],...
    'gapIdx', [], 'seqOfEvents', [], 'nSeg', [], 'visibility', [],...
    'lifetime_s', [], 'start', [], 'end', [], 'startBuffer', [],...
    'endBuffer', [], 'MotionAnalysis', [], 'mixtureIndex', [],...
    'RSS', [], 'hval_Ar', [], 'hval_AD', [], 'catIdx', [], 'hasMultiplePeaks', []);
tracksfn_split=fieldnames(tracks_split);

n=0;
for l=1:size(trk,2)
    if trk(l).catIdx<5
        n=n+1;        
        for o=1:size(tracksfn,1)
            newField = tracksfn{o};
            tracks_split(n).(newField)=trk(l).(newField);
        end
    else
        p=find(isnan(trk(l).t));
        rng_in=[1 p+1]; rng_end=[p-1 size(trk(l).t,2)]; dur=rng_end-rng_in+1;
        for m=1:size(rng_in,2)
            n=n+1;
            for o=[1:18,30:33]
                newField = tracksfn_split{o};
                for q=1:size(tracksfn,1)
                    if strfind(newField,tracksfn{q},'ForceCellOutput',0)==1
                        Temp=[trk(l).(newField)];
                        [tracks_split(n).(newField)]=Temp(rng_in(m):rng_end(m));
                    end
                end
            end          
            newField = tracksfn_split{24};
            for q=1:size(tracksfn,1)
                if strfind(newField,tracksfn{q},'ForceCellOutput',0)==1
                    [tracks_split(n).(newField)]=dur(m)*data(dataN).framerate;
                end
            end
            newField = tracksfn_split{25};
            for q=1:size(tracksfn,1)
                if strfind(newField,tracksfn{q},'ForceCellOutput',0)==1
                    [tracks_split(n).(newField)]=trk(l).f(rng_in(m));
                end
            end
            newField = tracksfn_split{26};
            for q=1:size(tracksfn,1)
                if strfind(newField,tracksfn{q},'ForceCellOutput',0)==1
                    [tracks_split(n).(newField)]=trk(l).f(rng_end(m));
                end
            end

            for o=[19:23,27:29,34:35]
                newField = tracksfn_split{o};
                for q=1:size(tracksfn,1)
                    if strfind(newField,tracksfn{q},'ForceCellOutput',0)==1
                        Temp=[trk(l).(newField)];
                        [tracks_split(n).(newField)]=Temp;
                    end
                end
            end
        end
    end
end

tracks = tracks_split;

parfor l=1:size(tracks,2)
    [MAP(l,:)] = snc(tracks, l, dia);
end

Map=MAP;n=0;
for l=1:size(Map,1)
    if size(find(Map(l,:)),2)>0
        t=find(Map(l,:));
        Comp=[t]; Map(l,:)=zeros(1,size(Map,1));
        while size(t,2)>0
            Comp=[Comp t];
            u=[];
            for m=1:size(t,2)
                u=[u find(Map(t(m),:))];
                Map(t(m),:)=zeros(1,size(Map,1));
            end
            t=u;
        end
        n=n+1;C(n,1:size(Comp,2))=Comp;
    end
end

Tot=[]; CC{1}=nonzeros(C(1,:)); n=1;
for l=1:size(C,1)-1
    Tot=[Tot, C(l,:)];
    if size(intersect(Tot, C(l+1)),2)==0
       n=n+1; CC{n}=nonzeros(C(l+1,:));
    end
end

QT=[];
for n=1:size(CC,2)
    QQ{n}= unique(CC{n}');
    QT=[QT, QQ{n}];
end

save([data(dataN).source 'Analysis/ProcessedTracks_split.mat'], 'tracks','QQ');

for l=1:size(tracksfn,1)
    newField = tracksfn{l};
    [tracks_cluster.(newField)] = [];
end

for m=1:size(QQ,2)
for o=[1:18,30:33]
newField = tracksfn{o}; tracks_cluster(m).(newField)=tracks(QQ{m}(1)).(newField)(1,:);
for l=1:size(QQ{m},2)-1
    tracks_cluster(m).(newField)=[tracks_cluster(m).(newField) NaN tracks(QQ{m}(l+1)).(newField)(1,:)];
end
end
n=0; clear St En In
for q=QQ{m}
    n=n+1; St(n)=tracks(q).start; En(n)=tracks(q).end; In(q)=max(tracks(q).A(1,:));
end
Dur=max(En)-min(St)+1; 
tracks_cluster(m).nSeg=size(QQ{m},2);
tracks_cluster(m).start=min(St);
tracks_cluster(m).end=max(En);
tracks_cluster(m).lifetime_s=Dur*data(dataN).framerate;
if Dur==data(dataN).movieLength && size(QQ{m},2)==1
    tracks_cluster(m).catIdx=4;
elseif Dur==data(dataN).movieLength && size(QQ{m},2)>1
    tracks_cluster(m).catIdx=8;
elseif Dur<data(dataN).movieLength && size(QQ{m},2)==1
    tracks_cluster(m).catIdx=3;
else
    tracks_cluster(m).catIdx=7;
end
end

for m=1:size(QQ,2)
    A=tracks_cluster(m).A(1,:).*(1-tracks_cluster(m).gapVect);
    for l=tracks_cluster(m).start:tracks_cluster(m).end
        AT(l)=sum(A(1,find(tracks_cluster(m).f==l)));
    end
    AT=AT(min(tracks_cluster(m).f):max(tracks_cluster(m).f));
    tracks_cluster(m).AT=AT; clear AT
end

tracks=tracks_cluster; save([data(dataN).source 'Analysis/ProcessedTracks_clustered.mat'], 'tracks');
[dataN toc]
end
end