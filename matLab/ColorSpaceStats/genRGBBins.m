% [Y B R bin A] = colorStats( 0.114, 0.299, pi/2 -0.778, 0, 255, 256, 0, 255, 256, 0, 255, 256)
function [ Rv, Gv, Bv, binOut, chromBin, LxyBin, cA ] = genRGBBins(dirName, rMin, rMax, rBins, gMin, gMax, gBins, bMin, bMax, bBins)
%
if nargin<2
    rMin = 0; rMax = 255; rBins = 256; gMin = 0; gMax = 255; gBins =256; bMin = 0; bMax =255; bBins = 256;
end

rScale = rMax - rMin;
gScale = gMax - gMin;
bScale = bMax - bMin;
Rv = rMin:(rMax-rMin)/(rBins-1):rMax;
Gv = gMin:(gMax-gMin)/(gBins-1):gMax;
Bv = bMin:(bMax-bMin)/(bBins-1):bMax;
[G, R, B] = meshgrid(Rv, Gv, Bv);
% Bin map : input chan value - chan min +1 (1:chanScale+1) : Output bin
% number (1:chanBins).
rBin = floor((0:rScale).*(rBins)./(rScale+1))+1;
gBin = floor((0:gScale).*(gBins)./(gScale+1))+1;
bBin = floor((0:bScale).*(bBins)./(bScale+1))+1;

bin = zeros(rBins,gBins,bBins);

% Lxy bins
LScale = rScale+ gScale + bScale;
xScale = rScale+ 2*gScale + bScale;
yScale = rScale + bScale;
LBins = ceil(sqrt(3.) * rScale)+1;
xBins = ceil(2 * sqrt(2./3.) * rScale)+1;
yBins = ceil(sqrt(2.) * rScale)+1;
Lv = 0:LScale/(LBins-1):LScale;
xv = 0:xScale/(xBins-1):xScale;
yv = 0:yScale/(yBins-1):yScale;
[L, x, y] = meshgrid(Lv, xv, yv);
% Bin map : input chan value - chan min +1 (1:chanScale+1) : Output bin
% number (1:chanBins).
LBin = floor((0:LScale).*(LBins)./(LScale+1))+1;
xBin = floor((0:xScale).*(xBins)./(xScale+1))+1;
yBin = floor((0:yScale).*(yBins)./(yScale+1))+1;

LxyBin = zeros(LBins,xBins,yBins);

% Cr Cb Bins
CrScale = rScale+ 2*gScale + bScale;
CbScale = rScale+bScale;
CrBins = ceil(2 * sqrt(2./3.) * rScale)+1;
CbBins = ceil(sqrt(2.) * rScale)+1;

Crv = 0:CrScale/(CrBins-1):CrScale;
Cbv = 0:CbScale/(CbBins-1):CbScale;
[Cr, Cb] = meshgrid(Crv, Cbv);
Cr = Cr';
Cb = Cb';

CrBin = floor((0:CrScale).*(CrBins)./(CrScale+1))+1;
CbBin = floor((0:CbScale).*(CbBins)./(CbScale+1))+1;

chromBin = zeros(CrBins,CbBins);

chanVals = [0 0 0];
cT = [0 0 0];
cA = [0 0 0];
cN = 0;
TZero = [1,1,1;(-1),2,(-1);(-1),0,1];
TzeroScale = [1/sqrt(3),1/sqrt(6),1/sqrt(2)];

D = [dir(strcat(dirName,'/*.jpg')),dir(strcat(dirName,'/*.JPG'))];
% D = dir('SkinSamples/*.jpg');
imcell = cell(1,numel(D));
for k = 1:numel(D)
  % imcell{k} = rgb2ycbcr(imread(strcat('Skin Samples/',D(k).name)));
  % imcell{k} = rgbToYcbcr(imread(strcat('Skin Samples/',D(k).name)), Kb, Kr, theta, yScale, bScale, rScale);
  imcell{k} = imread(strcat(dirName,'/',D(k).name));
[rows, cols, channels] = size(imcell{k});
for i = 1:rows
    for j = 1:cols
        chanVals = squeeze(imcell{k}(i,j,:)) - uint8([rMin; gMin; bMin]) + 1;
        bin(rBin(chanVals(1)),gBin(chanVals(2)),bBin(chanVals(3))) = bin(rBin(chanVals(1)),gBin(chanVals(2)),bBin(chanVals(3))) + 1;
        chromVals = TZero * double((chanVals)) + [0; rScale + bScale; rScale] +1;
        LxyBin(LBin(chromVals(1)),xBin(chromVals(2)),yBin(chromVals(3))) = LxyBin(LBin(chromVals(1)),xBin(chromVals(2)),yBin(chromVals(3))) + 1;
        chromBin(CrBin(chromVals(2)),CbBin(chromVals(3))) = chromBin(CrBin(chromVals(2)),CbBin(chromVals(3))) + 1;
    end
end

end

for i = 1:bBins
    for j = 1:gBins
        for k = 1:rBins
            cT(1) = cT(1) + bin(k,j,i) * R(k,j,i);
            cT(2) = cT(2) + bin(k,j,i) * G(k,j,i);
            cT(3) = cT(3) + bin(k,j,i) * B(k,j,i);
            cN  = cN  + bin(k,j,i);
        end
    end
end

cA = cT/cN;


%--- Normalised Histogram data ---------------------
% we remove zeros from the input bin data as some are due to the color
% space rotation and they affect the sigma values.
loc = find(bin>0);
ZGood = bin(loc)/max(max(max(bin)));

binOut = griddata(R(loc),G(loc),B(loc),ZGood,R,G,B);
NaNLoc = isnan(binOut)==1;
binOut(NaNLoc) = 0;

clear('loc','ZGood','NaNLoc');
loc = find(chromBin>0);
ZGood = chromBin(loc)/max(max(max(chromBin)));

chromBinOut = griddata(Cr(loc),Cb(loc),ZGood,Cr,Cb);
NaNLoc = isnan(chromBinOut)==1;
chromBinOut(NaNLoc) = 0;

% [locRow,locCol] = ind2sub(size(chromBin),loc);
% % [row,col] = meshgrid(locRow(1):locRow(end),locCol(1):locCol(end));
% [row,col] = meshgrid(1:size(chromBin,1),1:size(chromBin,2));
% chromBinOut = griddata(locRow,locCol,ZGood,row,col);
% 
% 
% [locRow,locCol] = ind2sub(size(chromBin),loc);
% locRow = locRow-1;
% locCol = locCol-1;
% % [row,col] = meshgrid(locRow(1):locRow(end),locCol(1):locCol(end));
% [row,col] = meshgrid(0:size(chromBin,1)-1,0:size(chromBin,2)-1);
% chromBinOut = griddata(locRow,locCol,ZGood,row,col);
% 
% 
% [locRow,locCol] = ind2sub(size(chromBin),loc);
% locRow = (locRow-1)./size(chromBin,1);
% locCol = (locCol-1)./size(chromBin,2);
% [row,col] = meshgrid(0:1/size(chromBin,1):1,0:1/size(chromBin,1):1);
% chromBinOut = griddata(locRow,locCol,ZGood,row,col);
% 
% 
% 
% [locRow,locCol] = ind2sub(size(chromBin),loc);
% locRow = (locRow-1).*(CrScale/size(chromBin,1));
% locCol = (locCol-1).*(CbScale/size(chromBin,2));
% [row,col] = meshgrid(0:(CrScale/size(chromBin,1)):CrScale,0:(CbScale/size(chromBin,2)):CbScale);
% chromBinOut = griddata(locRow,locCol,ZGood,row,col);

% save the output Rv, Gv, Bv, binOut, cA
save(strcat(dirName,'/Rv'),'Rv');
save(strcat(dirName,'/Gv'),'Gv');
save(strcat(dirName,'/Bv'),'Bv');
save(strcat(dirName,'/binOut'),'binOut');
save(strcat(dirName,'/cA'),'cA');
save(strcat(dirName,'/chromBin'),'chromBin');
save(strcat(dirName,'/LxyBin'),'LxyBin');

figure('Name','Bins','NumberTitle','off');
subplot(1,3,1)
imagesc(squeeze(sum(binOut,1)));
subplot(1,3,2)
imagesc(squeeze(sum(binOut,2)));
subplot(1,3,3)
imagesc(squeeze(sum(binOut,3)));

end

