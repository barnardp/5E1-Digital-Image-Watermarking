% Function to compare simulated Ernawan scheme with proposed Scheme
clear all
% close all
clc

nc_val_ernawan_no =    []; 
nc_val_proposed_no =   []; 
nc_val_ernawan_rot =    []; 
nc_val_proposed_rot =   [];




    % read in image, convert to grayscale if neccessary
     I = imread('Lena.ppm');
    if(ndims(I)>2)
        I = rgb2gray(I);
    end
    % read in watermark image 
    WM_in = imread('watermark.png');  
    % get optimal threshold value for Ernawan scheme           
    T = ernawan_threshold(I,WM_in);
    % Embed watermark using Ernawan Scheme
    [J_ernawan,embed_locs_ernawan,Wsize] = ernawan_embed(I,WM_in,T);

    % Get optimal threshold for Proposed Scheme
     Tl = levicky_threshold(I,WM_in);
    [J_proposed,embed_locs_proposed,Wsize] = levicky_embed(I,WM_in,Tl); 


    % ***************** Attacks on Ernawan scheme ****************


    for w = 0:360
        % rotate image
        J_proposed_rot = imresize(imrotate(J_proposed,w),[512 512]);
        % extract wm without any processing
        WM_out = ernawan_extract(J_proposed_rot,embed_locs_proposed,Wsize,T);
        nc_val_proposed_no(w+1) = NORM_CORR(WM_out,WM_in);  

        % process
        proposed_fixed = Extractor_Deskew(J_proposed_rot, J_proposed);
        % extract wm
        WM_out = ernawan_extract(proposed_fixed,embed_locs_proposed,Wsize,T);
        nc_val_proposed_rot(w+1) = NORM_CORR(WM_out,WM_in); 


         % rotate image
        J_ernawan_rot = imresize(imrotate(J_ernawan,w),[512 512]);
        % extract wm without any processing
        WM_out = ernawan_extract(J_ernawan_rot,embed_locs_ernawan,Wsize,T);
        nc_val_ernawan_no(w+1) = NORM_CORR(WM_out,WM_in);  

        % process
        ernawan_fixed = Extractor_Deskew(J_ernawan_rot, J_proposed);
        % extract wm without any processing
        WM_out = ernawan_extract(ernawan_fixed,embed_locs_ernawan,Wsize,T);
        nc_val_ernawan_rot(w+1) = NORM_CORR(WM_out,WM_in); 

    end
              
        
    



% ****************************** Display Graphs ****************************************


figure, plot(0:360,nc_val_ernawan_no, 0:360,nc_val_proposed_no)

title('Comparison of rotational attacks between Ernawan and proposed scheme with no pre-processing');
ylabel('NC Value');
legend({'Ernawan NC','Proposed NC'},'Location','northwest')
set(gca,'fontsize',20)
% ***************************************************************************************
figure, plot(0:360,nc_val_ernawan_rot, 0:360,nc_val_proposed_rot)

title('Comparison of rotational attacks between Ernawan and proposed scheme with pre-processing');
ylabel('NC Value');
legend({'Ernawan NC','Proposed NC'},'Location','northwest')
set(gca,'fontsize',20)
ave_proposed = mean(nc_val_proposed_rot)
ave_ernawan = mean(nc_val_ernawan_rot)

%% Functions: J = watermarked image, I = original image, WM_in/WM_out = Watermark in/out


% extractor post-processing using surf feateures to deskew image, where
% I = Original watermarked image before any noise etc.
% J = corrupted image
function out = Extractor_Deskew(J,I)

    
%     I  = imread('cameraman.tif');
%     J = imresize(I, 0.7); J = imrotate(J, 31);
%     figure; imshow(J); title('Transformed image');

    % Detect and extract features from both images
    ptsIn  = detectSURFFeatures(I);
    ptsOut = detectSURFFeatures(J);
    [featuresIn,   validPtsIn] = extractFeatures(I,  ptsIn);
    [featuresOut, validPtsOut] = extractFeatures(J, ptsOut);

    % Match feature vectors
    indexPairs = matchFeatures(featuresIn, featuresOut);
    matchedPtsIn  = validPtsIn(indexPairs(:,1));
    matchedPtsOut = validPtsOut(indexPairs(:,2));
%     figure; showMatchedFeatures(I,J,matchedPtsIn,matchedPtsOut);
%     title('Matched SURF points, including outliers');

    % Exclude the outliers and compute the transformation matrix
    [tform,inlierPtsOut,inlierPtsIn] = estimateGeometricTransform(...
    matchedPtsOut,matchedPtsIn,'similarity');
%     figure; showMatchedFeatures(I,J,inlierPtsIn,inlierPtsOut);
%     title('Matched inlier points');

    % Recover the original image 
    outputView = imref2d(size(I));
    out = imwarp(J, tform, 'OutputView', outputView);
%     figure; imshow(out); title('Recovered image');

%     figure, imshowpair(imresize(I,[100 100]),imresize(out,[100 100]),'montage')
    
    

end