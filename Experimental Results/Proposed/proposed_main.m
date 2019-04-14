% Function to compare simulated Ernawan scheme with proposed Scheme
clear all
close all
clc

% create object pointing to test image directory & initialize variables
image_dir = dir('images');
count =     0;
names =     '';
ssim_val_ernawan =  [];
are_val_ernawan =   [];
psnr_val_ernawan =  [];
nc_val_ernawan =    []; 
ber_val_ernawan =   [];
ssim_val_proposed = [];
are_val_proposed =  [];
psnr_val_proposed = [];
nc_val_proposed =   []; 
ber_val_proposed =  [];


for i = 3:length(image_dir) % for each image in the folder

        % read in image, convert to grayscale if neccessary
         I = imread([image_dir(i).name]);
        if(ndims(I)>2)
            I = rgb2gray(I);
        end
        % read in watermark image 
        WM_in = imread('watermark.png');  
        % get optimal threshold value for Ernawan scheme           
        if(strcmp(image_dir(i).name(1:end-4),'Lena'))
            T = ernawan_threshold(I,WM_in,'Lena');
        else
            T = ernawan_threshold(I,WM_in);
        end
           
        % Embed watermark using Ernawan Scheme
        [J_ernawan,embed_locs_ernawan,Wsize] = ernawan_embed(I,WM_in,T);
        
        % Get optimal threshold for Proposed Scheme
        if(strcmp(image_dir(i).name(1:end-4),'Lena'))
            Tl = levicky_threshold(I,WM_in,'Lena');
        else
            Tl = levicky_threshold(I,WM_in);
        end
        
        [J_proposed,embed_locs_proposed,Wsize] = levicky_embed(I,WM_in,Tl); 
        
        
        % if Lena image, output watermarked image
        if(strcmp(image_dir(i).name(1:end-4),'Lena'))
            figure,subplot(1,2,1),imshow(I),title('Original')
            subplot(1,2,2),imshow(J_proposed),title('Watermarked using proposed scheme')
            figure,subplot(1,2,1),imshow(I),title('Original')
            subplot(1,2,2),imshow(J_ernawan),title('Watermarked using Ernawan implemented scheme')
        end
        

        count = count + 1;
        % store name of current image
        names{count,1} = image_dir(i).name(1:end-4);
        
        % compute SSIM of watermarked image
        ssim_val_ernawan = [ssim_val_ernawan; mssim(J_ernawan,I)]; 
        % compute ARE of watermarked image
        are_val_ernawan = [are_val_ernawan; ARE(J_ernawan,I)];
        % compute PSNR of watermarked image
        psnr_val_ernawan = [psnr_val_ernawan; PSNR(J_ernawan,I)];
        
        % compute SSIM of watermarked image
        ssim_val_proposed = [ssim_val_proposed; mssim(J_proposed,I)]; 
        % compute ARE of watermarked image
        are_val_proposed = [are_val_proposed; ARE(J_proposed,I)];
        % compute PSNR of watermarked image
        psnr_val_proposed = [psnr_val_proposed; PSNR(J_proposed,I)];

        
        % ***************** Attacks on Ernawan scheme ****************

        % 3x3 average filter
        WM_out = ernawan_extract(imfilter(J_ernawan,ones(3,3)/9),embed_locs_ernawan,Wsize,T);
        % compute NC, N.B nc_val vector shifted to next row for each image
        nc_val_ernawan(count,1) = NORM_CORR(WM_out,WM_in);
        % compute BER, N.B nc_val vector shifted to next row for each image
        ber_val_ernawan(count,1) = BER(WM_out,WM_in);
        
        % 3x3 wiener filter
        WM_out = ernawan_extract(wiener2(J_ernawan,[3,3]),embed_locs_ernawan,Wsize,T);
        % compute NC
        nc_val_ernawan(count,2) = NORM_CORR(WM_out,WM_in);
        % compute BER
        ber_val_ernawan(count,2) = BER(WM_out,WM_in);
        
        % 3x3 median filter
        WM_out = ernawan_extract(medfilt2(J_ernawan),embed_locs_ernawan,Wsize,T);
        % compute NC
        nc_val_ernawan(count,3) = NORM_CORR(WM_out,WM_in);
        % compute BER
        ber_val_ernawan(count,3) = BER(WM_out,WM_in);
        
        % gaussian low pass filter
        WM_out = ernawan_extract(imfilter(J_ernawan,fspecial('gaussian',[3 3]),'same'),embed_locs_ernawan,Wsize,T);
        % compute NC
        nc_val_ernawan(count,4) = NORM_CORR(WM_out,WM_in);
        % compute BER
        ber_val_ernawan(count,4) = BER(WM_out,WM_in);
        
        % gaussian noise
%         var = (0.001)/(255)^2;%(since the image was of uint8 type)
        WM_out = ernawan_extract(imnoise(J_ernawan,'gaussian',0,0.001),embed_locs_ernawan,Wsize,T);
        % compute NC
        nc_val_ernawan(count,5) = NORM_CORR(WM_out,WM_in);
        % compute BER
        ber_val_ernawan(count,5) = BER(WM_out,WM_in);
        
        % speckle noise
        WM_out = ernawan_extract(imnoise(J_ernawan,'speckle',0.003),embed_locs_ernawan,Wsize,T);
        % compute NC
        nc_val_ernawan(count,6) = NORM_CORR(WM_out,WM_in);
        % compute BER
        ber_val_ernawan(count,6) = BER(WM_out,WM_in);
        
        % salt and pepper density(0.01)
        WM_out = ernawan_extract(imnoise(J_ernawan,'salt & pepper',0.01),embed_locs_ernawan,Wsize,T);
        % compute NC
        nc_val_ernawan(count,7) = NORM_CORR(WM_out,WM_in);
        % compute BER
        ber_val_ernawan(count,7) = BER(WM_out,WM_in);
        
        % sharpening
        WM_out = ernawan_extract(imsharpen(J_ernawan),embed_locs_ernawan,Wsize,T);
        % compute NC
        nc_val_ernawan(count,8) = NORM_CORR(WM_out,WM_in);
        % compute BER
        ber_val_ernawan(count,8) = BER(WM_out,WM_in);
        
        % poisson noise
        WM_out = ernawan_extract(imnoise(J_ernawan,'poisson'),embed_locs_ernawan,Wsize,T);
        % compute NC
        nc_val_ernawan(count,9) = NORM_CORR(WM_out,WM_in);
        % compute BER
        ber_val_ernawan(count,9) = BER(WM_out,WM_in);
        
        % intensity adjust
        WM_out = ernawan_extract(imadjust(J_ernawan),embed_locs_ernawan,Wsize,T);
        % compute NC
        nc_val_ernawan(count,10) = NORM_CORR(WM_out,WM_in);
        % compute BER
        ber_val_ernawan(count,10) = BER(WM_out,WM_in);
        
        % histogram equalization
        WM_out = ernawan_extract(histeq(J_ernawan),embed_locs_ernawan,Wsize,T);
        % compute NC
        nc_val_ernawan(count,11) = NORM_CORR(WM_out,WM_in);
        % compute BER
        ber_val_ernawan(count,11) = BER(WM_out,WM_in);
        
        for k = 10:10:90
        % JPEG compression indexing 12-20
            imwrite(J_ernawan,'JPEG.jpg','jpg','Quality',k);
            WM_out = ernawan_extract(imread('JPEG.jpg'),embed_locs_ernawan,Wsize,T);
            % compute NC
            nc_val_ernawan(count,11+(k/10)) = NORM_CORR(WM_out,WM_in);
            % compute BER
            ber_val_ernawan(count,11+(k/10)) = BER(WM_out,WM_in);
        end

        for k = 2:2:10
            % JPEG2000 compression indexing 21-25
            imwrite(J_ernawan,'JPEG2000.jp2','jp2','CompressionRatio',k);
            WM_out = ernawan_extract(imread('JPEG2000.jp2'),embed_locs_ernawan,Wsize,T);
            % compute NC
            nc_val_ernawan(count,11+9+(k/2)) = NORM_CORR(WM_out,WM_in);
            % compute BER
            ber_val_ernawan(count,11+9+(k/2)) = BER(WM_out,WM_in);
        end
        
        % Combo attack 1: 3x3 (default) median filter followed by salt and pepper density(0.003)
        WM_out = ernawan_extract(imnoise(medfilt2(J_ernawan),'salt & pepper',0.003),embed_locs_ernawan,Wsize,T);
        % compute NC
        nc_val_ernawan(count,26) = NORM_CORR(WM_out,WM_in);
        % compute BER
        ber_val_ernawan(count,26) = BER(WM_out,WM_in);
        
        % Combo attack 2
        imwrite(J_ernawan,'JPEG.jpg','jpg','Quality',50);
        temp = imread('JPEG.jpg');
        temp(128:384,128:384)=0;
        WM_out = ernawan_extract(temp,embed_locs_ernawan,Wsize,T);
        % compute NC
        nc_val_ernawan(count,27) = NORM_CORR(WM_out,WM_in);
        % compute BER
        ber_val_ernawan(count,27) = BER(WM_out,WM_in);
       
        % geometrical attacks
        temp = J_ernawan; temp(192:320,192:320)=0;
        WM_out = ernawan_extract(temp,embed_locs_ernawan,Wsize,T);
        nc_val_ernawan(count,28) = NORM_CORR(WM_out,WM_in);
        ber_val_ernawan(count,28) = BER(WM_out,WM_in);
        
        temp = J_ernawan; temp(128:384,128:384)=0;
        WM_out = ernawan_extract(temp,embed_locs_ernawan,Wsize,T);
        nc_val_ernawan(count,29) = NORM_CORR(WM_out,WM_in);
        ber_val_ernawan(count,29) = BER(WM_out,WM_in);
        
        temp = J_ernawan; temp(192:320,192:320)=255;
        WM_out = ernawan_extract(temp,embed_locs_ernawan,Wsize,T);
        nc_val_ernawan(count,30) = NORM_CORR(WM_out,WM_in);
        ber_val_ernawan(count,30) = BER(WM_out,WM_in);
        
        temp = J_ernawan; temp(128:384,128:384)=255;
        WM_out = ernawan_extract(temp,embed_locs_ernawan,Wsize,T);
        nc_val_ernawan(count,31) = NORM_CORR(WM_out,WM_in);
        ber_val_ernawan(count,31) = BER(WM_out,WM_in);
        
        % cropping rows off
        temp = J_ernawan; temp(1:256,1:end)=0;
        WM_out = ernawan_extract(temp,embed_locs_ernawan,Wsize,T);
        nc_val_ernawan(count,32) = NORM_CORR(WM_out,WM_in);
        ber_val_ernawan(count,32) = BER(WM_out,WM_in);
        
        temp = J_ernawan; temp(1:128,1:end)=0;
        WM_out = ernawan_extract(temp,embed_locs_ernawan,Wsize,T);
        nc_val_ernawan(count,33) = NORM_CORR(WM_out,WM_in);
        ber_val_ernawan(count,33) = BER(WM_out,WM_in);
        
        temp = J_ernawan; temp(1:64,1:end)=0;
        WM_out = ernawan_extract(temp,embed_locs_ernawan,Wsize,T);
        nc_val_ernawan(count,34) = NORM_CORR(WM_out,WM_in);
        ber_val_ernawan(count,34) = BER(WM_out,WM_in);
        
        temp = J_ernawan; temp(1:256,1:end)=255;
        WM_out = ernawan_extract(temp,embed_locs_ernawan,Wsize,T);
        nc_val_ernawan(count,35) = NORM_CORR(WM_out,WM_in);
        ber_val_ernawan(count,35) = BER(WM_out,WM_in);
        
        temp = J_ernawan; temp(1:128,1:end)=255;
        WM_out = ernawan_extract(temp,embed_locs_ernawan,Wsize,T);
        nc_val_ernawan(count,36) = NORM_CORR(WM_out,WM_in);
        ber_val_ernawan(count,36) = BER(WM_out,WM_in);
        
        temp = J_ernawan; temp(1:64,1:end)=255;
        WM_out = ernawan_extract(temp,embed_locs_ernawan,Wsize,T);
        nc_val_ernawan(count,37) = NORM_CORR(WM_out,WM_in);
        ber_val_ernawan(count,37) = BER(WM_out,WM_in);
        
        % cropping columns
        temp = J_ernawan; temp(1:end,1:256)=0;
        WM_out = ernawan_extract(temp,embed_locs_ernawan,Wsize,T);
        nc_val_ernawan(count,38) = NORM_CORR(WM_out,WM_in);
        ber_val_ernawan(count,38) = BER(WM_out,WM_in);
        
        temp = J_ernawan; temp(1:end,1:128)=0;
        WM_out = ernawan_extract(temp,embed_locs_ernawan,Wsize,T);
        nc_val_ernawan(count,39) = NORM_CORR(WM_out,WM_in);
        ber_val_ernawan(count,39) = BER(WM_out,WM_in);
        
        temp = J_ernawan; temp(1:end,1:64)=0;
        WM_out = ernawan_extract(temp,embed_locs_ernawan,Wsize,T);
        nc_val_ernawan(count,40) = NORM_CORR(WM_out,WM_in);
        ber_val_ernawan(count,40) = BER(WM_out,WM_in);
        
        temp = J_ernawan; temp(1:end,1:256)=255;
        WM_out = ernawan_extract(temp,embed_locs_ernawan,Wsize,T);
        nc_val_ernawan(count,41) = NORM_CORR(WM_out,WM_in);
        ber_val_ernawan(count,41) = BER(WM_out,WM_in);
        
        temp = J_ernawan; temp(1:end,1:128)=255;
        WM_out = ernawan_extract(temp,embed_locs_ernawan,Wsize,T);
        nc_val_ernawan(count,42) = NORM_CORR(WM_out,WM_in);
        ber_val_ernawan(count,42) = BER(WM_out,WM_in);
        
        temp = J_ernawan; temp(1:end,1:64)=255;
        WM_out = ernawan_extract(temp,embed_locs_ernawan,Wsize,T);
        nc_val_ernawan(count,43) = NORM_CORR(WM_out,WM_in);
        ber_val_ernawan(count,43) = BER(WM_out,WM_in);
        
        % scaling
        WM_out = ernawan_extract(imresize(imresize(J_ernawan,0.8),[512,512]),embed_locs_ernawan,Wsize,T);
        nc_val_ernawan(count,44) = NORM_CORR(WM_out,WM_in);
        ber_val_ernawan(count,44) = BER(WM_out,WM_in);
        
        WM_out = ernawan_extract(imresize(imresize(J_ernawan,0.25),[512,512]),embed_locs_ernawan,Wsize,T);
        nc_val_ernawan(count,45) = NORM_CORR(WM_out,WM_in);
        ber_val_ernawan(count,45) = BER(WM_out,WM_in);
        
        
        % ***************** Attacks on proposed scheme ****************
        % 3x3 average filter
        WM_out = ernawan_extract(imfilter(J_proposed,ones(3,3)/9),embed_locs_proposed,Wsize,T);
        % compute NC, N.B nc_val vector shifted to next row for each image
        nc_val_proposed(count,1) = NORM_CORR(WM_out,WM_in);
        % compute BER, N.B nc_val vector shifted to next row for each image
        ber_val_proposed(count,1) = BER(WM_out,WM_in);
        
        % 3x3 wiener filter
        WM_out = ernawan_extract(wiener2(J_proposed,[3,3]),embed_locs_proposed,Wsize,T);
        % compute NC
        nc_val_proposed(count,2) = NORM_CORR(WM_out,WM_in);
        % compute BER
        ber_val_proposed(count,2) = BER(WM_out,WM_in);  

        % 3x3 median filter
        WM_out = ernawan_extract(medfilt2(J_proposed),embed_locs_proposed,Wsize,T);
        % compute NC
        nc_val_proposed(count,3) = NORM_CORR(WM_out,WM_in);
        % compute BER
        ber_val_proposed(count,3) = BER(WM_out,WM_in);
        
        % gaussian low pass filter
        WM_out = ernawan_extract(imfilter(J_proposed,fspecial('gaussian',[3 3]),'same'),embed_locs_proposed,Wsize,T);
        % compute NC
        nc_val_proposed(count,4) = NORM_CORR(WM_out,WM_in);
        % compute BER
        ber_val_proposed(count,4) = BER(WM_out,WM_in);
        
        % gaussian noise
%         var = (0.001)/(255)^2;%(since the image was of uint8 type)
        WM_out = ernawan_extract(imnoise(J_proposed,'gaussian',0,0.001),embed_locs_proposed,Wsize,T);
        % compute NC
        nc_val_proposed(count,5) = NORM_CORR(WM_out,WM_in);
        % compute BER
        ber_val_proposed(count,5) = BER(WM_out,WM_in);
        
        % speckle noise
        WM_out = ernawan_extract(imnoise(J_proposed,'speckle',0.003),embed_locs_proposed,Wsize,T);
        % compute NC
        nc_val_proposed(count,6) = NORM_CORR(WM_out,WM_in);
        % compute BER
        ber_val_proposed(count,6) = BER(WM_out,WM_in);
        
        % salt and pepper density(0.01)
        WM_out = ernawan_extract(imnoise(J_proposed,'salt & pepper',0.01),embed_locs_proposed,Wsize,T);
        % compute NC
        nc_val_proposed(count,7) = NORM_CORR(WM_out,WM_in);
        % compute BER
        ber_val_proposed(count,7) = BER(WM_out,WM_in);
        
        % sharpening
        WM_out = ernawan_extract(imsharpen(J_proposed),embed_locs_proposed,Wsize,T);
        % compute NC
        nc_val_proposed(count,8) = NORM_CORR(WM_out,WM_in);
        % compute BER
        ber_val_proposed(count,8) = BER(WM_out,WM_in);
        
        % poisson noise
        WM_out = ernawan_extract(imnoise(J_proposed,'poisson'),embed_locs_proposed,Wsize,T);
        % compute NC
        nc_val_proposed(count,9) = NORM_CORR(WM_out,WM_in);
        % compute BER
        ber_val_proposed(count,9) = BER(WM_out,WM_in);
        
        % intensity adjust
        WM_out = ernawan_extract(imadjust(J_proposed),embed_locs_proposed,Wsize,T);
        % compute NC
        nc_val_proposed(count,10) = NORM_CORR(WM_out,WM_in);
        % compute BER
        ber_val_proposed(count,10) = BER(WM_out,WM_in);
        
        % histogram equalization
        WM_out = ernawan_extract(histeq(J_proposed),embed_locs_proposed,Wsize,T);
        % compute NC
        nc_val_proposed(count,11) = NORM_CORR(WM_out,WM_in);
        % compute BER
        ber_val_proposed(count,11) = BER(WM_out,WM_in);
        
        for k = 10:10:90
        % JPEG compression indexing 12-20
            imwrite(J_proposed,'JPEG.jpg','jpg','Quality',k);
            WM_out = ernawan_extract(imread('JPEG.jpg'),embed_locs_proposed,Wsize,T);
            % compute NC
            nc_val_proposed(count,11+(k/10)) = NORM_CORR(WM_out,WM_in);
            % compute BER
            ber_val_proposed(count,11+(k/10)) = BER(WM_out,WM_in);
        end

        for k = 2:2:10
            % JPEG2000 compression indexing 21-25
            imwrite(J_proposed,'JPEG2000.jp2','jp2','CompressionRatio',k);
            WM_out = ernawan_extract(imread('JPEG2000.jp2'),embed_locs_proposed,Wsize,T);
            % compute NC
            nc_val_proposed(count,11+9+(k/2)) = NORM_CORR(WM_out,WM_in);
            % compute BER
            ber_val_proposed(count,11+9+(k/2)) = BER(WM_out,WM_in);
        end
        
        % Combo attack 1: 3x3 (default) median filter followed by salt and pepper density(0.003)
        WM_out = ernawan_extract(imnoise(medfilt2(J_proposed),'salt & pepper',0.003),embed_locs_proposed,Wsize,T);
        % compute NC
        nc_val_proposed(count,26) = NORM_CORR(WM_out,WM_in);
        % compute BER
        ber_val_proposed(count,26) = BER(WM_out,WM_in);
        
        % Combo attack 2
        imwrite(J_proposed,'JPEG.jpg','jpg','Quality',50);
        temp = imread('JPEG.jpg');
        temp(128:384,128:384)=0;
        WM_out = ernawan_extract(temp,embed_locs_proposed,Wsize,T);
        % compute NC
        nc_val_proposed(count,27) = NORM_CORR(WM_out,WM_in);
        % compute BER
        ber_val_proposed(count,27) = BER(WM_out,WM_in);
       
        % geometrical attacks
        temp = J_proposed; temp(192:320,192:320)=0;
        WM_out = ernawan_extract(temp,embed_locs_proposed,Wsize,T);
        nc_val_proposed(count,28) = NORM_CORR(WM_out,WM_in);
        ber_val_proposed(count,28) = BER(WM_out,WM_in);
        
        temp = J_proposed; temp(128:384,128:384)=0;
        WM_out = ernawan_extract(temp,embed_locs_proposed,Wsize,T);
        nc_val_proposed(count,29) = NORM_CORR(WM_out,WM_in);
        ber_val_proposed(count,29) = BER(WM_out,WM_in);
        
        temp = J_proposed; temp(192:320,192:320)=255;
        WM_out = ernawan_extract(temp,embed_locs_proposed,Wsize,T);
        nc_val_proposed(count,30) = NORM_CORR(WM_out,WM_in);
        ber_val_proposed(count,30) = BER(WM_out,WM_in);
        
        temp = J_proposed; temp(128:384,128:384)=255;
        WM_out = ernawan_extract(temp,embed_locs_proposed,Wsize,T);
        nc_val_proposed(count,31) = NORM_CORR(WM_out,WM_in);
        ber_val_proposed(count,31) = BER(WM_out,WM_in);
        
        % cropping rows off
        temp = J_proposed; temp(1:256,1:end)=0;
        WM_out = ernawan_extract(temp,embed_locs_proposed,Wsize,T);
        nc_val_proposed(count,32) = NORM_CORR(WM_out,WM_in);
        ber_val_proposed(count,32) = BER(WM_out,WM_in);
        
        temp = J_proposed; temp(1:128,1:end)=0;
        WM_out = ernawan_extract(temp,embed_locs_proposed,Wsize,T);
        nc_val_proposed(count,33) = NORM_CORR(WM_out,WM_in);
        ber_val_proposed(count,33) = BER(WM_out,WM_in);
        
        temp = J_proposed; temp(1:64,1:end)=0;
        WM_out = ernawan_extract(temp,embed_locs_proposed,Wsize,T);
        nc_val_proposed(count,34) = NORM_CORR(WM_out,WM_in);
        ber_val_proposed(count,34) = BER(WM_out,WM_in);
        
        temp = J_proposed; temp(1:256,1:end)=255;
        WM_out = ernawan_extract(temp,embed_locs_proposed,Wsize,T);
        nc_val_proposed(count,35) = NORM_CORR(WM_out,WM_in);
        ber_val_proposed(count,35) = BER(WM_out,WM_in);
        
        temp = J_proposed; temp(1:128,1:end)=255;
        WM_out = ernawan_extract(temp,embed_locs_proposed,Wsize,T);
        nc_val_proposed(count,36) = NORM_CORR(WM_out,WM_in);
        ber_val_proposed(count,36) = BER(WM_out,WM_in);
        
        temp = J_proposed; temp(1:64,1:end)=255;
        WM_out = ernawan_extract(temp,embed_locs_proposed,Wsize,T);
        nc_val_proposed(count,37) = NORM_CORR(WM_out,WM_in);
        ber_val_proposed(count,37) = BER(WM_out,WM_in);
        
        % cropping columns
        temp = J_proposed; temp(1:end,1:256)=0;
        WM_out = ernawan_extract(temp,embed_locs_proposed,Wsize,T);
        nc_val_proposed(count,38) = NORM_CORR(WM_out,WM_in);
        ber_val_proposed(count,38) = BER(WM_out,WM_in);
        
        temp = J_proposed; temp(1:end,1:128)=0;
        WM_out = ernawan_extract(temp,embed_locs_proposed,Wsize,T);
        nc_val_proposed(count,39) = NORM_CORR(WM_out,WM_in);
        ber_val_proposed(count,39) = BER(WM_out,WM_in);
        
        temp = J_proposed; temp(1:end,1:64)=0;
        WM_out = ernawan_extract(temp,embed_locs_proposed,Wsize,T);
        nc_val_proposed(count,40) = NORM_CORR(WM_out,WM_in);
        ber_val_proposed(count,40) = BER(WM_out,WM_in);
        
        temp = J_proposed; temp(1:end,1:256)=255;
        WM_out = ernawan_extract(temp,embed_locs_proposed,Wsize,T);
        nc_val_proposed(count,41) = NORM_CORR(WM_out,WM_in);
        ber_val_proposed(count,41) = BER(WM_out,WM_in);
        
        temp = J_proposed; temp(1:end,1:128)=255;
        WM_out = ernawan_extract(temp,embed_locs_proposed,Wsize,T);
        nc_val_proposed(count,42) = NORM_CORR(WM_out,WM_in);
        ber_val_proposed(count,42) = BER(WM_out,WM_in);
        
        temp = J_proposed; temp(1:end,1:64)=255;
        WM_out = ernawan_extract(temp,embed_locs_proposed,Wsize,T);
        nc_val_proposed(count,43) = NORM_CORR(WM_out,WM_in);
        ber_val_proposed(count,43) = BER(WM_out,WM_in);
        
        % scaling
        WM_out = ernawan_extract(imresize(imresize(J_proposed,0.8),[512,512]),embed_locs_proposed,Wsize,T);
        nc_val_proposed(count,44) = NORM_CORR(WM_out,WM_in);
        ber_val_proposed(count,44) = BER(WM_out,WM_in);
        
        WM_out = ernawan_extract(imresize(imresize(J_proposed,0.25),[512,512]),embed_locs_proposed,Wsize,T);
        nc_val_proposed(count,45) = NORM_CORR(WM_out,WM_in);
        ber_val_proposed(count,45) = BER(WM_out,WM_in);
              
        
    
end

% ****************************** Display Graphs ****************************************
figure('name','PSNR Imperceptibility for Images')
bar(categorical(names),[psnr_val_ernawan'; psnr_val_proposed']');
title('Comparison of PSNR values between the Proposed scheme and Ernawans Scheme (Simulated)');
legend('Ernawan Scheme (Simulated)','Proposed scheme');
ylabel('PSNR (dB)');
ylim([0, max(psnr_val_ernawan)+15]);
% Add values above each bar
for i = 1:numel(names)
    txt = text(i+0.1, psnr_val_proposed(i)+0.5,num2str(psnr_val_proposed(i)),'FontSize',10);
    set(txt,'Rotation',90);
    if(psnr_val_ernawan(i)>=0)
        txt = text(i-0.2, psnr_val_ernawan(i)+0.5,num2str(psnr_val_ernawan(i)),'FontSize',10);
        set(txt,'Rotation',90);
    else
        txt = text(i-0.2, psnr_val_ernawan(i)-3,num2str(psnr_val_ernawan(i)),'FontSize',10);
        set(txt,'Rotation',-90);
    end
end
set(gca,'fontsize',24)
% ***************************************************************************************
figure
attacks = {'Average Filter (3,3)','Wiener Filter (3,3)','Median Filter (3,3)',...
           'Gaussian Low Pass (3,3)','Gaussian noise (var=0.001)','Speckle noise (var=0.003)',...
           'Salt & Pepper (density=0.01)','Sharpening','Poisson noise','Adjust',...
           'Histogram Equalization','JPEG QF=50','JPEG2000 CR=8','Combination 1','Combination 2'
            };  
        
data_ernawan = mean([nc_val_ernawan(1:end,1:11) nc_val_ernawan(1:end,16) nc_val_ernawan(1:end,24) nc_val_ernawan(1:end,26:27)])';  
data_proposed = mean([nc_val_proposed(1:end,1:11) nc_val_proposed(1:end,16) nc_val_proposed(1:end,24) nc_val_proposed(1:end,26:27)])';

bar(categorical(attacks'),[data_ernawan'; data_proposed']');
title('Comparison of NC values against different attacks for Proposed scheme and Ernawans Scheme (Simulated)');
legend('Ernawan scheme (Simulated)','Proposed scheme');
ylabel('Normalized Cross-Correlation (NC)');
ylim([0, 1.4]);
set(gca,'fontsize',24)
% ***************************************************************************************
figure
attacks2 = {'JPEG QF=10','JPEG QF=20','JPEG QF=30','JPEG QF=40','JPEG QF=50',...
                   'JPEG QF=60','JPEG QF=70','JPEG QF=80','JPEG QF=90'};

bar(categorical(attacks2'),[mean(nc_val_ernawan(1:end,12:20)); mean(nc_val_proposed(1:end,12:20)); ...
    mean(ber_val_ernawan(1:end,12:20)); mean(ber_val_proposed(1:end,12:20));]');
title('Average NC & BER values against JPEG Compression for Proposed scheme and Ernawans Scheme (Simulated)');
ylabel('Value');
legend({'Ernawan NC','Proposed NC','Ernawan BER','Proposed BER'},'Location','northwest')
set(gca,'fontsize',24)
% ***************************************************************************************
%   Geometrical attacks
figure
attacks3 = {'center crop 25% black','center crop 50% black','center crop 25% white','center crop 50% white',...
           'crop rows 50% black','crop rows 25% black','crop rows 12.5% black',...
           'crop rows 50% white','crop rows 25% white','crop rows 12.5% white',...
           'crop cols 50% black','crop cols 25% black','crop cols 12.5% black',...
           'crop cols 50% white','crop cols 25% white','crop cols 12.5% white',...
           'scaling 0.8','scaling 0.25'
            };  
        
data_geo_ernawan = mean(nc_val_ernawan(1:end,28:45));    
data_geo_proposed = mean(nc_val_proposed(1:end,28:45));

bar(categorical(attacks3'),[data_geo_ernawan; data_geo_proposed;]');
title(['Comparison of NC values against different geomterical' ...
       'attacks for Proposed scheme and Ernawan scheme (Simulated)']);
legend('Ernawan scheme','Proposed scheme');
ylabel('Normalized Cross-Correlation (NC)');
ylim([0, 1.4]);
set(gca,'fontsize',24)
% ***************************************************************************************

% Display Tables 
% subplot(2,1,3)->[220 50 565 360];
tab1 = uitable(figure('name','Watermarked Image Quality'));
tab1.Position = [150 600 423 220];
tab1.ColumnName = {'Proposed|ARE','Ernawan|ARE','Proposed|SSIM','Ernawan|SSIM'};
tab1.RowName = [names;'Average'];

tab1.Data = [are_val_proposed are_val_ernawan ssim_val_proposed ssim_val_ernawan;...
             mean(are_val_proposed) mean(are_val_ernawan) mean(ssim_val_proposed) ...
             mean(ssim_val_ernawan)];
         
         

%