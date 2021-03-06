function [neg] = negGet( img1_in, img2_in, pp1, pp2 )

if isa(img1_in,'float')
    img1 = double(img1_in)./max(max(max(img1_in)));
elseif isa(img1_in,'uint8')
    img1 = double(img1_in)./255.;
end
    
if isa(img2_in,'float')
    img2 = double(img2_in) ./ max(max(max(img2_in)));
elseif isa(img2_in,'uint8')
    img2 = double(img2_in) ./ 255.;
end

if nargin<=2
    p1 = [1, 1];
    p2 = [min(size(img1,2),size(img2,2)), min(size(img1,1),size(img2,1))];
else
    p1 = [min(pp1(1),pp2(1)), min(pp1(2),pp2(2))];
    p2 = [max(pp1(1),pp2(1)), max(pp1(2),pp2(2))];
end

%neg = img1(p1(2):p2(2),p1(1):p2(1),:) - img2(p1(2):p2(2),p1(1):p2(1),:) +1 ;
neg = abs(img1(p1(2):p2(2),p1(1):p2(1),:) - img2(p1(2):p2(2),p1(1):p2(1),:)) ;

% neg(:,:,1) = neg(:,:,1) ./ 2.;
% neg(:,:,2) = neg(:,:,2) ./ 2.;
% neg(:,:,3) = neg(:,:,3) ./ 2.;

%dImg1 = im2double(img1);
%dImg2 = im2double(img2);

%neg = dImg1(p1(2):p2(2),p1(1):p2(1),:) - dImg2(p1(2):p2(2),p1(1):p2(1),:);


%cutFig1 = figure('Name','Cut Fig Min/Max','NumberTitle','off');
%imageChannels(neg,cutFig1);

%edgeFilter = fspecial('gaussian');
%smoothNeg = imfilter(neg,edgeFilter,'same');

%cutFig2 = figure('Name','Cut Fig Smooth','NumberTitle','off');
%imageChannels(smoothNeg,cutFig2);

%negPressureEdge = zeros(size(smoothNeg));
%negPressureEdge(:,:,1) = edge(smoothNeg(:,:,1),'canny',0.6);
%negPressureEdge(:,:,2) = edge(smoothNeg(:,:,2),'canny',0.6);
%negPressureEdge(:,:,3) = edge(smoothNeg(:,:,3),'canny',0.6);

%cutFig3 = figure('Name','Cut Fig Edge','NumberTitle','off');
%imageChannels(negPressureEdge,cutFig3);

end
