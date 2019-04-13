
close all
clear all

I = imread('Lena.ppm');
if(ndims(I)>2)
    I = rgb2gray(I);
end

% create vectors to segment an image into non-overlapping blocks of size 8
block_size = 8;
[Jrows,Jcols] = size(I);
num_sub_rows = Jrows/block_size; num_sub_cols = Jcols/block_size;
m_vec = block_size*ones(1,num_sub_rows); n_vec = block_size*ones(1,num_sub_cols);

% create segmented images 
J = mat2cell(double(I),m_vec,n_vec);
luminance_mask = mat2cell(zeros(size(I)),m_vec,n_vec);
contrast_mask_levicky = mat2cell(zeros(size(I)),m_vec,n_vec);

% define embedding locs, (4,2),(3,3),(2,4),(1,5) = [12,19,26,33,27,34]
embed_locs = [12,19,26,33,27,34];
% create list to store JND's at the embedding location freq's
Ep = zeros(num_sub_rows*num_sub_cols,3);
pos = 1;

% create watsons mask for controlling weber effect
w_watson = ones(8)*0.7; w_watson(1,1) = 0;
% calculate dc coefficient corresponding to luminance of image
mean_dc = 8*mean2(I); 

% create freq sensitivity mask
sensitivity_mask = freq_sense_HVS(); 
% compute NVF map of image & divide into 8x8 blocks
nvf = mat2cell(NVF(I),m_vec,n_vec); 

for m=1:num_sub_rows
    for n = 1:num_sub_cols
        dct_mat = dct2(J{m,n});
        % create luminance adaption mask using watsons formula
        luminance_mask{m,n} = sensitivity_mask.*(dct_mat(1,1)/mean_dc).^0.649;
        % create contrast maskk using watson formula
        contrast_mask_levicky{m,n} = luminance_mask{m,n}.*mask_effect_HVS(dct_mat,luminance_mask{m,n},nvf{m,n});  

        % can use contrast mask to deterine best embedding locations, i.e. those
        % with the largest JND's at the specific embeddinf freq's
        Ep(pos,1) = m;      % save row location
        Ep(pos,2) = n;      % save col location
        Ep(pos,3) = mean2(contrast_mask_levicky{m,n}); 
        pos = pos + 1;          
         
    end
end


luminance_mask = cell2mat(luminance_mask);
figure, imshow(luminance_mask,[])
title('Relative luminance adaption thresholds for Lena image')
set(gca,'fontsize',18)

contrast_mask_levicky = cell2mat(contrast_mask_levicky);
figure, imshow(contrast_mask_levicky,[])
title('Relative contrast masking thresholds using Levickys formula')
set(gca,'fontsize',18)


%sort embedding locs list in ascending order select highest n
Ep = sortrows(Ep,3,'descend');
Jwm = Ep(1:1024,[1 2]);
figure, imshow(show_embed_regs(I,Jwm));
title('Best embedding blocks accoring to highest JNDs at the embedding frequencies')



%% functions

% function to calculate frequency sensitivity matrix for 8x8 block based on [1].
% NB The parameter values used here have been set to result in a similar
% sensitivity table as that shown in [2], however a similar table for this
% implementation is also given in pg 271 of [3], in which the choosen
% paramters in this case result in a slighly less conservative matrix
% 
%
% [1]   H. A. Peterson, A. Ahumada, and A. Watson, An Improved Detection Model for DCT 
%       Coefficient Quantization. 1993.
% [2]   P. Foris and D. Levicky, "Human Visual System Models in Digital Image 
%       Watermarking," vol. 13, no. 4, 13, pp. 38-43, Dec 2004.
% [3]   I. Cox, M. Miller, J. Bloom, J. Fridrich, and T. Kalker, Digital Watermarking and
%       Steganography. Morgan Kaufmann Publishers Inc., 2008, p. 624.

function T = freq_sense_HVS()

    Eta = 0.6;                  % obliqness factor, used in [3]
    Wx = 7.1527/256;            % NB. implies viewing dist of 8 image heights here
    Wy = 7.1527/256;            % pixels/degree vertical height of pixel, 
      
    % use parameters from 'Y' row in table 1, from [3]
    % T min = s*b, with s = 0.25, b = 1.000 (value of white in Y channel of CEI 1931)
    T_min = 0.25; 
    f_min = 3.1;
    K = 1.34;
    
    % calculate spatial frequency matrix associated with dct, using formula (4) from [3]
    f_spat = (1/16)*sqrt(repmat(((0:7)/Wx).^2,8,1)' + repmat(((0:7)/Wy).^2,8,1) ); 
    % calculate C(u)*C(v) term used to normalize T and convert to quantization matrix, from eq (2) in [1]
    C_u = repmat([(sqrt(1/8)) sqrt(2/8)*ones(1,7)],8,1)';
    C_uv = C_u.*C_u';
    % note that(f(u,0)^2 + f(0,v)^2)^2 term equivilant to fuv^4 as seen from eq (7) in [2]
    t1 = f_spat.^4;
    % calculate f(u,0)^2 * f(0,v)^2 term as (f_mn(:,1).^2.*f_mn(1,:).^2)
    t2 = (f_spat(:,1).^2).*(f_spat(1,:).^2);
    
    % combine terms to calculate frequency sensitivity function as in [1],
    % which gives a modified version of the log-based expression from eq 3
    % in [3], and avoids calculation of angle from eq 5 in [3]
    T = ((T_min*t1)./(C_uv.*(t1-4*(1-Eta)*t2))).*(10.^(K*(log10(f_spat)-log10(f_min*ones(8))).^2));
    T(1) =  min(T(1,2),T(2,1));
    
    figure, surf(T)
    zlabel('Threshold');
    ylabel('J-Freq');
    xlabel('I-Freq');
    xticks(0:7), yticks(0:7)
    title('Levicky and Peterson JND ')
    set(gca,'fontsize',16)
        
end


% function to compute NVF map of input image I, as described by 
% [1]   S. Voloshynovskiy, A. Herrigel, N. Baumgaertner, and T. Pun, A Stochastic 
%       Approach to Content Adaptive Digital Image Watermarking. 1999, pp. 211-236.
function nvf_map = NVF(I,win_size)
    
    if(nargin<2)
        window = true(13); % estimated value used by levicky
    else
        window = true(win_size);
    end
    % compute local variance of each pixel, using sliding window
    nvf_map = stdfilt(I,window).^2;
    % compute theta paramter, D = 100 estimated from levicky
    theta = 100/max(max(nvf_map));
    % compute NVF map
    nvf_map = 1./(1 + theta*nvf_map);
%     figure, imshow(nvf_map)
    
end


% function to show embedded block positions as black areas within the image
% where, 'I' refers to the unwatermarked image
% 'Ep' refers to the [row,col] locations of each selected block
% 'wm_size' refers to the watermark size, 
% 'block_size' refers to the segmentated block size
% 'out' is the output image

function out = show_embed_regs(I,Ep,wm_size,block_size)
    
    % default parameters
    if(nargin<3) 
        wm_size = 1024;        
        block_size = 8;
    elseif(nargin<4)
        block_size = 8;  
    end
    

     % Divide image into 8x8 pixel sub images of non-overlapping blocks
    [Jrows,Jcols] = size(I);
    num_sub_rows = Jrows/block_size; num_sub_cols = Jcols/block_size;
    m_vec = block_size*ones(1,num_sub_rows); n_vec = block_size*ones(1,num_sub_cols);
    J = mat2cell(double(I),m_vec,n_vec);
    
    % for each block, set image balck at that location
    for m=1:wm_size
        J{Ep(m,1),Ep(m,2)} = zeros(block_size);
    end
    
    out = uint8(cell2mat(J));
   

end



