function transformMatrix = transformationMatrixLABRot(theta)
% Matrix multiplication with RGB 0:1 gives YCbCr 0:1 -0.5:0.5 -0.5:0.5
transformMatrix = ...
[1,0,0;...
 0,cos(theta)*sec(pi/6. - mod((-pi/6. + theta), pi/3.)),(sqrt(3)*sec(pi/6. - mod((-pi/6. + theta), pi/3.))*sin(theta))/2.;...
 0,-(sec(pi/6. - mod(theta, pi/3.))*sin(theta)),(sqrt(3)*cos(theta)*sec(pi/6. - mod(theta, pi/3.)))/2.];
end