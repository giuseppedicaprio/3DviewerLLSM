%% TRACKING 3D
data=loadconditiondata3D
%
clearvars -except data

% Calculating sigmas for detection
PSFrt = 'Z:\Alex\20200716_p5_p55_sCMOS_Alex\LLSCalibrations'; %copy file location from LLS calibrations of the same day as experiment
PSF488 = '488totalPSF.tif';
PSF560 = '560totalPSF.tif';
PSF642 = '642totalPSF.tif';

% a. How thick are the illumination planes? -> How big is the PSF?
[sigmaXY488, sigmaZ488] = GU_estimateSigma3D([PSFrt filesep],PSF488);
[sigmaXY560, sigmaZ560] = GU_estimateSigma3D([PSFrt filesep],PSF560);
[sigmaXY642, sigmaZ642] = GU_estimateSigma3D([PSFrt filesep],PSF642);

% Sigmas obtained in pitch of 0.1, however plane distance  = 0.4 *
% sin(31.5), i.e. sigmaZ = sigmaZ488/(0.5 * sin(31.5))

zRatio = (0.4 * sind(31.5))/0.1;

sigmaZ488corr = sigmaZ488/zRatio; % 1.6006
sigmaZ560corr = sigmaZ560/zRatio; % 1.6931
sigmaZ642corr = sigmaZ642/zRatio; % 1.9648


% GU_runDetTrack3d(data, 'Sigma', [sigmaXY488, sigmaZ488corr; sigmaXY560, sigmaZ560corr; sigmaXY642, sigmaZ642corr;], 'Overwrite', [false, true, false, false]);  % 1. deskew; 2. detection; 3. tracking; 4. track processing

%%
%load condition data with 2 channels, viirus channel is to be the fisrt.

splitNcluster(data, dia) %dia is the diameter that you want to use to cluster the different tracks. I use 3. If you want to reduce the extent of clustering, you can bin down the number to 0
PrepDataViewer(data)  %This will create the outline for the regions above threshold
load([data.source 'Analysis' filesep 'ViewerData.mat'])

Viewer3D_2Ch(FV, Coord, info, data, tracks_cluster, p, dataN) % dataN is the experiment number