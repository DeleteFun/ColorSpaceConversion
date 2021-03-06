
classdef transform
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        T;
        iT;
        shift;
        range;
        unscaledAxisLength;
        axisLength;
        intIndx;
        discreteRange = 256;
    end
    
    methods
        function obj = transform(theta, norm)
            if nargin <= 1 || strcmp(norm,'no')
            obj.T = [1/sqrt(3), 1/sqrt(3), 1/sqrt(3) ;...
                -(sqrt(2./3.)*sin(pi/6. + theta)),   sqrt(2./3.)*cos(theta), -(sqrt(2./3.)*sin(pi/6. - theta)) ; ...
                -(sqrt(2./3.)*cos(pi/6. + theta)), -(sqrt(2./3.)*sin(theta)),  sqrt(2./3.)*cos(pi/6. - theta)];
            
            obj.range = [0,3.^(1/2); ...
                (-1).*2.^(-1/2).*cos(mod((-1/6).*pi+theta,(1/3).*pi))+(-1).*6.^(-1/2).*sin(mod((-1/6).*pi+theta,(1/3).*pi)), ...
                      2.^(-1/2).*cos(mod((-1/6).*pi+theta,(1/3).*pi))+      6.^(-1/2).*sin(mod((-1/6).*pi+theta,(1/3).*pi)); ...
                (-1).*2.^(-1/2).*cos(mod(theta,(1/3).*pi))+(-1).*6.^(-1/2).*sin(mod(theta,(1/3).*pi)), ...
                      2.^(-1/2).*cos(mod(theta,(1/3).*pi))+      6.^(-1/2).*sin(mod(theta,(1/3).*pi))];
            
            obj.axisLength = [3.^(1/2), ...
                (2.).*(2.^(-1/2).*cos(mod((-1/6).*pi+theta,(1/3).*pi))+6.^(-1/2).*sin(mod((-1/6).*pi+theta,(1/3).*pi))), ...
                (2.).*(2.^(-1/2).*cos(mod(theta,(1/3).*pi))           +6.^(-1/2).*sin(mod(theta,(1/3).*pi)))];
            
            obj.intIndx = ceil(obj.axisLength.*(obj.discreteRange-1))+1;
            
            obj.shift = [0; ...
                2.^(-1/2).*cos(mod((-1/6).*pi+theta,(1/3).*pi))+      6.^(-1/2).*sin(mod((-1/6).*pi+theta,(1/3).*pi)); ...
                2.^(-1/2).*cos(mod(theta,(1/3).*pi))+      6.^(-1/2).*sin(mod(theta,(1/3).*pi))];
            else
            
            obj.unscaledAxisLength = [3.^(1/2), ...
                (2.).*(2.^(-1/2).*cos(mod((-1/6).*pi+theta,(1/3).*pi))+6.^(-1/2).*sin(mod((-1/6).*pi+theta,(1/3).*pi))), ...
                (2.).*(2.^(-1/2).*cos(mod(theta,(1/3).*pi))+6.^(-1/2).*sin(mod(theta,(1/3).*pi)))];    
                
            uR = [1/sqrt(3), 1/sqrt(3), 1/sqrt(3) ;...
                -(sqrt(2./3.)*sin(pi/6. + theta)),sqrt(2./3.)*cos(theta), -(sqrt(2./3.)*sin(pi/6. - theta)) ; ...
                -(sqrt(2./3.)*cos(pi/6. + theta)), -(sqrt(2./3.)*sin(theta)), sqrt(2./3.)*cos(pi/6. - theta)];
            
            obj.T = [(1/3),(1/3),(1/3); ...
                uR(2,1)./obj.unscaledAxisLength(2), uR(2,2)./obj.unscaledAxisLength(2),uR(2,3)./obj.unscaledAxisLength(2); ...
                uR(3,1)./obj.unscaledAxisLength(3), uR(3,2)./obj.unscaledAxisLength(3),uR(3,3)./obj.unscaledAxisLength(3)];
            
            obj.range = [0,1; -0.5,0.5; -0.5,0.5];
            
            obj.axisLength = [1, 1, 1];
            
            obj.intIndx = floor([obj.discreteRange,obj.discreteRange,obj.discreteRange]);
            
            obj.shift = [0, 0.5, 0.5];
            end
            
            obj.iT = inv(obj.T);
            
        end % function
        
        
        function outImage = toRot(obj, pixelList)
            outImage = pixelList * obj.T';
            %# Shift each color plane (stored in each column of the N-by-3 matrix):
            outImage(:,1) = (outImage(:,1) + obj.shift(1));
            outImage(:,2) = (outImage(:,2) + obj.shift(2));
            outImage(:,3) = (outImage(:,3) + obj.shift(3));
        end % function
        
        
        function outImage = toRotImg(obj, img)
            sizeImg = size(img);
            outImage = reshape(double(img),[],sizeImg(end));
            outImage = obj.toRot(outImage);
            outImage = reshape(outImage,sizeImg);
        end % function
        
        function outImage = fromRotImg(obj, img)
            sizeImg = size(img);
            outImage = reshape(double(img),[],sizeImg(end));
            outImage = obj.fromRot(outImage);
            outImage = reshape(outImage,sizeImg);
        end % function
        
            
        function outImage = fromRot(obj, pixelList)
            %# Shift each color plane (stored in each column of the N-by-3 matrix):
            outImage(:,1) = (pixelList(:,1) - obj.shift(1));
            outImage(:,2) = (pixelList(:,2) - obj.shift(2));
            outImage(:,3) = (pixelList(:,3) - obj.shift(3));
            outImage = outImage * obj.iT';
        end % function
        
        function indx = toRotIndx(obj, indx, scale)
            if nargin < 3
                scale = obj.discreteRange;
            end
            pixelIndx = reshape(indx,3,[]);
            indx = round(obj.T * (pixelIndx-1) + (scale .* obj.shift)) + 1;
        end % function
        
        function indx = fromRotIndx(obj, indx, scale)
            if nargin < 3
                scale = obj.discreteRange;
            end
            pixelIndx = reshape(indx,3,[]);
            indx = round(obj.T' * ((pixelIndx-1) - scale .* obj.shift)) + 1;
        end % function
        
    end
    
end
