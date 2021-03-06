
% Load the images and perform the statistics for a histogram with theta = 0
dirName = 'SelfSkinSamples2';
% Initialize the variables for the iteration over angle.
nMax=12; tol = 10^-6;
ang = zeros(nMax+1,1);
c = zeros(nMax+1,3);
sigma = zeros(nMax+1,3);
x = zeros(nMax+1,6);
sigma(1,:) = [20, 20.5,20.5];
for i=1:nMax
 [YOut, BOut, ROut, binOut, AOut] = colorStats(dirName, ang(i), 0, 255, 256, 0, 255, 256, 0, 255, 256);
 binOutBR=squeeze(sum(binOut,1));
 binOutBR=binOutBR/max(max(binOutBR));
 %   x = [Amp,x0,wx,y0,wy,fi]
 x(i,:) = GaussianFit( BOut, ROut, binOutBR, [1,AOut(3),sigma(i,3),AOut(2),sigma(i,2),0], 'spline', 0);
 ang(i+1) = ang(i) + x(i,6);
 c(i+1,:) = [128, x(i,4),x(i,2)];
 sigma(i+1,:) = [255/sqrt(2), x(i,5), x(i,3)];
 if abs(x(i,6)) < tol 
     break
 end
end

theta = ang(i+1);
g = [ 1, 255/(sqrt(2) .* sigma(i+1,2)), 255/(sqrt(2) .* sigma(i+1, 3))];
sigma = sigma(1:i+1,:);
c = c(1:i+1,:);

C = zeros(1,3); C = c(end,:);
Sigma = sigma(end,:); Sigma = sigma(end,:);

skin = colorSpace(theta, C, Sigma, [3,3,3], 0, 255, 0, 255, 1, 0);

 % Plot angle convergence
 angIterFig = figure('Name','Convergence of the skin space chromatic angle with itteration.','NumberTitle','off');
 plot(ang(:,1)); xlabel({'Iteration'}); ylabel({'Angle'}); title({'Convergence of the skin space chromatic angle with itteration.'});
 
 % Example
 
 img = imread('hand_skin_test_3_back_1.jpg');
 rgbFig = figure('Name','RGB','NumberTitle','off');
 imageChannels(img,rgbFig);
 