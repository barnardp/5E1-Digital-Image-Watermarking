% function to implement Ernawan's scheme and compare against presented
% results

% Initialization of cover image and watermark image
clear all
close all
clc

% create object pointing to test image directory & initialize variables
image_dir = dir('images');
count = 0;
names = '';
ssim_val = [];
are_val = [];
psnr_val = [];
nc_val = []; 
ber_val = [];

for i = 3:length(image_dir) % for each image
             
        % read in image
        I = imread([image_dir(i).name]);
        if(ndims(I)>2)
            I = rgb2gray(I);
        end
        % read in watermark image 
        WM_in = imread('watermark.png'); 
        
        % get optimal threshold value 
        if(strcmp(image_dir(i).name(1:end-4),'Lena'))
            T = ernawan_threshold(I,WM_in,'Lena');
        else
            T = ernawan_threshold(I,WM_in);
        end
%       fprintf('%s:%f\n',sub_images(j).name(1:end-4),T);
        
        % Embed watermark 
        [J,Jwm,Wsize] = ernawan_embed(I,WM_in,T); 

        count = count + 1;
        % store name of current image
        names{count,1} =  image_dir(i).name(1:end-4);
        % compute SSIM of watermarked image
        ssim_val = [ssim_val; mssim(J,I)]; 
        % compute ARE of watermarked image
        are_val = [are_val; ARE(J,I)];
        % compute PSNR of watermarked image
        psnr_val = [psnr_val; PSNR(J,I)];
        
        % *************** Intermediate Processing (Attacks)   ***************

        % 3x3 average filter
        WM_out = ernawan_extract(imfilter(J,ones(3,3)/9),Jwm,Wsize,T);
        % compute NC, N.B nc_val vector shifted to next row for each image
        nc_val(count,1) = NORM_CORR(WM_out,WM_in);
        % compute BER, N.B nc_val vector shifted to next row for each image
        ber_val(count,1) = BER(WM_out,WM_in);
        
        % 3x3 wiener filter
        WM_out = ernawan_extract(wiener2(J,[3,3]),Jwm,Wsize,T);
        % compute NC
        nc_val(count,2) = NORM_CORR(WM_out,WM_in);
        % compute BER
        ber_val(count,2) = BER(WM_out,WM_in);
        
        % 3x3 median filter
        WM_out = ernawan_extract(medfilt2(J),Jwm,Wsize,T);
        % compute NC
        nc_val(count,3) = NORM_CORR(WM_out,WM_in);
        % compute BER
        ber_val(count,3) = BER(WM_out,WM_in);
        
        % gaussian low pass filter
        WM_out = ernawan_extract(imfilter(J,fspecial('gaussian',[3 3]),'same'),Jwm,Wsize,T);
        % compute NC
        nc_val(count,4) = NORM_CORR(WM_out,WM_in);
        % compute BER
        ber_val(count,4) = BER(WM_out,WM_in);
        
        % gaussian noise
        WM_out = ernawan_extract(imnoise(J,'gaussian',0,0.001),Jwm,Wsize,T);
        % compute NC
        nc_val(count,5) = NORM_CORR(WM_out,WM_in);
        % compute BER
        ber_val(count,5) = BER(WM_out,WM_in);
        
        % speckle noise
        WM_out = ernawan_extract(imnoise(J,'speckle',0.003),Jwm,Wsize,T);
        % compute NC
        nc_val(count,6) = NORM_CORR(WM_out,WM_in);
        % compute BER
        ber_val(count,6) = BER(WM_out,WM_in);
        
        % salt and pepper density(0.01)
        WM_out = ernawan_extract(imnoise(J,'salt & pepper',0.01),Jwm,Wsize,T);
        % compute NC
        nc_val(count,7) = NORM_CORR(WM_out,WM_in);
        % compute BER
        ber_val(count,7) = BER(WM_out,WM_in);
        
        % sharpening
        WM_out = ernawan_extract(imsharpen(J),Jwm,Wsize,T);
        % compute NC
        nc_val(count,8) = NORM_CORR(WM_out,WM_in);
        % compute BER
        ber_val(count,8) = BER(WM_out,WM_in);
        
        % poisson noise
        WM_out = ernawan_extract(imnoise(J,'poisson'),Jwm,Wsize,T);
        % compute NC
        nc_val(count,9) = NORM_CORR(WM_out,WM_in);
        % compute BER
        ber_val(count,9) = BER(WM_out,WM_in);
        
        % intensity adjust
        WM_out = ernawan_extract(imadjust(J),Jwm,Wsize,T);
        % compute NC
        nc_val(count,10) = NORM_CORR(WM_out,WM_in);
        % compute BER
        ber_val(count,10) = BER(WM_out,WM_in);
        
        % histogram equalization
        WM_out = ernawan_extract(histeq(J),Jwm,Wsize,T);
        % compute NC
        nc_val(count,11) = NORM_CORR(WM_out,WM_in);
        % compute BER
        ber_val(count,11) = BER(WM_out,WM_in);
        
        for k = 10:10:90
        % JPEG compression indexing 12-20
            imwrite(J,'JPEG.jpg','jpg','Quality',k);
            WM_out = ernawan_extract(imread('JPEG.jpg'),Jwm,Wsize,T);
            % compute NC
            nc_val(count,11+(k/10)) = NORM_CORR(WM_out,WM_in);
            % compute BER
            ber_val(count,11+(k/10)) = BER(WM_out,WM_in);
        end

        for k = 2:2:10
            % JPEG2000 compression indexing 21-25
            imwrite(J,'JPEG2000.jp2','jp2','CompressionRatio',k);
            WM_out = ernawan_extract(imread('JPEG2000.jp2'),Jwm,Wsize,T);
            % compute NC
            nc_val(count,11+9+(k/2)) = NORM_CORR(WM_out,WM_in);
            % compute BER
            ber_val(count,11+9+(k/2)) = BER(WM_out,WM_in);
        end
               
        % Combo attack 1: 3x3 (default) median filter followed by salt and pepper density(0.003)
        WM_out = ernawan_extract(imnoise(medfilt2(J),'salt & pepper',0.003),Jwm,Wsize,T);
        % compute NC
        nc_val(count,26) = NORM_CORR(WM_out,WM_in);
        % compute BER
        ber_val(count,26) = BER(WM_out,WM_in);
        
        % Combo attack 2
        imwrite(J,'JPEG.jpg','jpg','Quality',50);
        temp = imread('JPEG.jpg');
        temp(128:384,128:384)=0;
        WM_out = ernawan_extract(temp,Jwm,Wsize,T);
        % compute NC
        nc_val(count,27) = NORM_CORR(WM_out,WM_in);
        % compute BER
        ber_val(count,27) = BER(WM_out,WM_in);
       
        % geometrical attacks
        temp = J; temp(192:320,192:320)=0;
        WM_out = ernawan_extract(temp,Jwm,Wsize,T);
        nc_val(count,28) = NORM_CORR(WM_out,WM_in);
        ber_val(count,28) = BER(WM_out,WM_in);
        
        temp = J; temp(128:384,128:384)=0;
        WM_out = ernawan_extract(temp,Jwm,Wsize,T);
        nc_val(count,29) = NORM_CORR(WM_out,WM_in);
        ber_val(count,29) = BER(WM_out,WM_in);
        
        temp = J; temp(192:320,192:320)=255;
        WM_out = ernawan_extract(temp,Jwm,Wsize,T);
        nc_val(count,30) = NORM_CORR(WM_out,WM_in);
        ber_val(count,30) = BER(WM_out,WM_in);
        
        temp = J; temp(128:384,128:384)=255;
        WM_out = ernawan_extract(temp,Jwm,Wsize,T);
        nc_val(count,31) = NORM_CORR(WM_out,WM_in);
        ber_val(count,31) = BER(WM_out,WM_in);
        
        % cropping rows off
        temp = J; temp(1:256,1:end)=0;
        WM_out = ernawan_extract(temp,Jwm,Wsize,T);
        nc_val(count,32) = NORM_CORR(WM_out,WM_in);
        ber_val(count,32) = BER(WM_out,WM_in);
        
        temp = J; temp(1:128,1:end)=0;
        WM_out = ernawan_extract(temp,Jwm,Wsize,T);
        nc_val(count,33) = NORM_CORR(WM_out,WM_in);
        ber_val(count,33) = BER(WM_out,WM_in);
        
        temp = J; temp(1:64,1:end)=0;
        WM_out = ernawan_extract(temp,Jwm,Wsize,T);
        nc_val(count,34) = NORM_CORR(WM_out,WM_in);
        ber_val(count,34) = BER(WM_out,WM_in);
        
        temp = J; temp(1:256,1:end)=255;
        WM_out = ernawan_extract(temp,Jwm,Wsize,T);
        nc_val(count,35) = NORM_CORR(WM_out,WM_in);
        ber_val(count,35) = BER(WM_out,WM_in);
        
        temp = J; temp(1:128,1:end)=255;
        WM_out = ernawan_extract(temp,Jwm,Wsize,T);
        nc_val(count,36) = NORM_CORR(WM_out,WM_in);
        ber_val(count,36) = BER(WM_out,WM_in);
        
        temp = J; temp(1:64,1:end)=255;
        WM_out = ernawan_extract(temp,Jwm,Wsize,T);
        nc_val(count,37) = NORM_CORR(WM_out,WM_in);
        ber_val(count,37) = BER(WM_out,WM_in);
        
        % cropping columns
        temp = J; temp(1:end,1:256)=0;
        WM_out = ernawan_extract(temp,Jwm,Wsize,T);
        nc_val(count,38) = NORM_CORR(WM_out,WM_in);
        ber_val(count,38) = BER(WM_out,WM_in);
        
        temp = J; temp(1:end,1:128)=0;
        WM_out = ernawan_extract(temp,Jwm,Wsize,T);
        nc_val(count,39) = NORM_CORR(WM_out,WM_in);
        ber_val(count,39) = BER(WM_out,WM_in);
        
        temp = J; temp(1:end,1:64)=0;
        WM_out = ernawan_extract(temp,Jwm,Wsize,T);
        nc_val(count,40) = NORM_CORR(WM_out,WM_in);
        ber_val(count,40) = BER(WM_out,WM_in);
        
        temp = J; temp(1:end,1:256)=255;
        WM_out = ernawan_extract(temp,Jwm,Wsize,T);
        nc_val(count,41) = NORM_CORR(WM_out,WM_in);
        ber_val(count,41) = BER(WM_out,WM_in);
        
        temp = J; temp(1:end,1:128)=255;
        WM_out = ernawan_extract(temp,Jwm,Wsize,T);
        nc_val(count,42) = NORM_CORR(WM_out,WM_in);
        ber_val(count,42) = BER(WM_out,WM_in);
        
        temp = J; temp(1:end,1:64)=255;
        WM_out = ernawan_extract(temp,Jwm,Wsize,T);
        nc_val(count,43) = NORM_CORR(WM_out,WM_in);
        ber_val(count,43) = BER(WM_out,WM_in);
        
        % scaling
        WM_out = ernawan_extract(imresize(imresize(J,0.8),[512,512]),Jwm,Wsize,T);
        nc_val(count,44) = NORM_CORR(WM_out,WM_in);
        ber_val(count,44) = BER(WM_out,WM_in);
        
        WM_out = ernawan_extract(imresize(imresize(J,0.25),[512,512]),Jwm,Wsize,T);
        nc_val(count,45) = NORM_CORR(WM_out,WM_in);
        ber_val(count,45) = BER(WM_out,WM_in);
        
    
end

% ****************************** Display Graphs ****************************************
opt_dct_psnr = [45.926 44.546 45.495 45.945 45.689 45.465 45.3 45.533 45.742];
figure('name','PSNR Imperceptibility for Images')
% subplot(2,2,1);
bar(categorical(names),[psnr_val'; opt_dct_psnr]');
title('Comparison of PSNR values between Ernawans published scheme and Ernawans implemented scheme');
legend('Implemented scheme','Published scheme');
ylabel('PSNR (dB)');
ylim([0, max(psnr_val)+25]);
% Add values above each bar
for i = 1:numel(names)
    txt = text(i+0.1, opt_dct_psnr(i)+0.5,num2str(opt_dct_psnr(i)),'FontSize',10);
    set(txt,'Rotation',90);
    if(psnr_val(i)>=0)
        txt = text(i-0.2, psnr_val(i)+0.5,num2str(psnr_val(i)),'FontSize',10);
        set(txt,'Rotation',90);
    else
        txt = text(i-0.2, psnr_val(i)-3,num2str(psnr_val(i)),'FontSize',10);
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
opt_dct_attks = [421 419 416 423 396 384 360 422 337 421 421 422 415 415 420]/423;         
data = mean([nc_val(1:end,1:11) nc_val(1:end,16) nc_val(1:end,24) nc_val(1:end,26:27)])';        
bar(categorical(attacks'),[data'; opt_dct_attks]');
title(['Comparison of NC values against different attacks for ' newline ...
      'Ernawans published scheme and Ernawans implemented scheme']);
legend('Implemented scheme','Published scheme');
ylabel('Normalized Cross-Correlation (NC)');
ylim([0, 1.4]);
set(gca,'fontsize',24)
% ***************************************************************************************
figure
attacks2 = {'JPEG QF=10','JPEG QF=20','JPEG QF=30','JPEG QF=40','JPEG QF=50',...
                   'JPEG QF=60','JPEG QF=70','JPEG QF=80','JPEG QF=90'};
opt_attks_JPG = [0.6972 0.6985 0.7769 0.8733 0.999 1 1 1 1]; 
opt_attks_BER = [0.5 0.5 0.2832 0.1248 0.004 0 0 0 0];
bar(categorical(attacks2'),[mean(nc_val(1:end,12:20)); opt_attks_JPG; ...
    mean(ber_val(1:end,12:20)); opt_attks_BER]');
title('Average NC & BER values against JPEG Compression');
ylabel('Value');
legend({'Implemented NC','Ernawan NC','Implemented BER','Ernawan BER'},'Location','northwest')
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
opt_attks_geo = [361 354 361 353 278 310 318 279 311 318 323 332 332 323 331 333 362 219]/362;         
data_geo = mean(nc_val(1:end,28:45));        
bar(categorical(attacks3'),[data_geo; opt_attks_geo]');
title(['Comparison of NC values against different geomterical attacks for ' newline ...
       'Ernawans published scheme and Ernawans implemented scheme']);
legend('Proposed scheme','Ernawan scheme');
ylabel('Normalized Cross-Correlation (NC)');
ylim([0, 1.4]);
set(gca,'fontsize',24)
% ***************************************************************************************

% Display Tables 
% subplot(2,1,3)->[220 50 565 360];
tab1 = uitable(figure('name','Watermarked Image Quality'));
tab1.Position = [150 600 423 220];
tab1.ColumnName = {'Implemented|ARE','Ernawan|ARE','Implemented|SSIM','Ernawan|SSIM'};
tab1.RowName = [names;'Average'];
Opt_ssim= [0.993 0.995 0.995 0.994 0.994 0.996 0.995 0.994 0.994];
Opt_are = [0.303 0.351 0.318 0.303 0.312 0.319 0.321 0.317 0.31];
tab1.Data = [are_val Opt_are' ssim_val Opt_ssim';...
             mean(are_val) mean(Opt_are) mean(ssim_val) mean(Opt_ssim)];

tab2 = uitable('Position',[750 600 798 202]);
tab2.ColumnName = {'JPEG QF=10','JPEG QF=20','JPEG QF=30','JPEG QF=40','JPEG QF=50',...
                   'JPEG QF=60','JPEG QF=70','JPEG QF=80','JPEG QF=90'};
tab2.RowName = [names;'Average'];
tab2.Data = [nc_val(1:end,12:20);mean(nc_val(1:end,12:20))];

