%%
% function to compare block selection schemes of Ernawan, Lai, Maity,
% Voloshynovskiy (proposed NVF method)

% [1]   F. Ernawan and M. N. Kabir, "A Robust Image Watermarking Technique With an Optimal 
%       DCT-Psychovisual Threshold," IEEE Access, vol. 6, pp. 20464-20480, 2018.
% [2]   S. P. Maity and M. K. Kundu, "DHT domain digital watermarking with low loss in 
%       image informations," AEU-International Journal of Electronics and Communications,
%       vol. 64, no. 3, pp. 243-257, 2010.
% [3]   C.-C. Lai, "An improved SVD-based watermarking scheme using human visual 
%       characteristics," Optics Communications, vol. 284, no. 4, pp. 938-944, 2011.
% [4]   S. Voloshynovskiy, A. Herrigel, N. Baumgaertner, and T. Pun, A Stochastic 
%       Approach to Content Adaptive Digital Image Watermarking. 1999, pp. 211-236.

close all, clear all,

I = rgb2gray(imread('Lena.ppm'));

% define watermark size
Wsize = 1024;

% define blocksize and calulate the neccessary vectors to segment image 
block_size = 8;
[Jrows,Jcols] = size(I);
num_sub_rows = Jrows/block_size; num_sub_cols = Jcols/block_size;
m_vec = block_size*ones(1,num_sub_rows); 
n_vec = block_size*ones(1,num_sub_cols);
% segment image into 8 x 8 blocks
J = mat2cell(I,m_vec,n_vec);


% Ep_' ' used to store entropy values of each block for each method, as well the row,col
% location of each block
Ep_Ernawan  = zeros(num_sub_rows*num_sub_cols,3);
Ep_Lai      = zeros(num_sub_rows*num_sub_cols,3);
Ep_Maity    = zeros(num_sub_rows*num_sub_cols,3);
Ep_nvf      = zeros(num_sub_rows*num_sub_cols,3);

%% Implement Ernawan's Original block selection process

pos = 1;
for m=1:num_sub_rows
    for n = 1:num_sub_cols              % for each block within image
        
        p = imhist((J{m,n}));      % create PDF for pixels in each block
        p(p==0) = [];                   % discard pixels with zero probability 
        p = p ./(block_size*block_size);% normalize PDF
        Ep_Ernawan(pos,1) = m;          % save row location of block
        Ep_Ernawan(pos,2) = n;          % save col location of block
        % compute modified entropy as given straight from eq 1 in Ernawan's paper
        Ep_Ernawan(pos,3) = -sum(p.*exp(1-p) + p.*log2(p))/2; 
        pos = pos + 1;                  % update position counter
        
    end
end

% sort into ascending order
Ep_Ernawan = sortrows(Ep_Ernawan,3);
% save locations of n lowest blocks,where n = watermark size
Jwm_Ernawan = Ep_Ernawan(1:Wsize,[1 2]);
% show selected blocks
figure, subplot(2,3,1), imshow(show_embed_regs(I,Jwm_Ernawan,Wsize)), title('Ernawan embedding locations');

%% Implement Lai's block selection process


pos = 1;
for m=1:num_sub_rows
    for n = 1:num_sub_cols              % for each block within image
        
        p = imhist((J{m,n}));      % create PDF for pixels in each block
        p(p==0) = [];                   % discard pixels with zero probability 
        p = p ./(block_size*block_size);% normalize PDF
        Ep_Lai(pos,1) = m;              % save row location of block
        Ep_Lai(pos,2) = n;              % save col location of block
        % compute modified entropy as given in eq's 5 & 6 in Lai's paper
        Ep_Lai(pos,3) = sum(p.*exp(1-p)) - sum(p.*log2(p)); 
        pos = pos + 1;                  % update position counter
        
    end
end

% sort into ascending order
Ep_Lai = sortrows(Ep_Lai,3);
% save locations of n lowest blocks,where n = watermark size
Jwm_Lai = Ep_Lai(1:Wsize,[1 2]);
% show selected blocks
subplot(2,3,2), imshow(show_embed_regs(I,Jwm_Lai,Wsize)), title('Lai embedding locations');

%% Implement Maity's block selection process

 
% create edge map 
I_edge = edge(I); % create edge map
% figure, imshow(Imag);

% segment edge map into 8 x 8 blocks
J_edge = mat2cell(I_edge,m_vec,n_vec);

pos = 1;
for m=1:num_sub_rows
    for n = 1:num_sub_cols              % for each block within image
        
        p = imhist(J_edge{m,n});       % create PDF for edge pixels in each block
        p(p==0) = [];                       % discard edge pixels with zero probability 
        p = p ./(block_size*block_size);    % normalize PDF
        edge_entropy = -sum(p.*log2(p));    % calculate edge entropy

        p = imhist(J{m,n});          % create PDF for grayscal pixels in each block
        p(p==0) = [];                       % discard pixels with zero probability 
        p = p ./(block_size*block_size);    % normalize PDF
        gray_entropy = sum(p.*exp(1-p));    % calculate visual entropy

        Ep_Maity(pos,1) = m;                      % save row location of block
        Ep_Maity(pos,2) = n;                      % save col location of block
        Ep_Maity(pos,3) = edge_entropy + gray_entropy; % combine entropies
        pos = pos + 1;                      % update position counter
        
    end
end

% sort into ascending order
Ep_Maity = sortrows(Ep_Maity,3);
% Maity embeds the watermark twice in to the same image, once in the lowest
% entropy blocks, and again in the mid range entropy blocks

% save locations of lowest N blocks
Jwm_Maity_1 = Ep_Maity(1:Wsize,[1 2]);
% show selected blocks
subplot(2,3,3), imshow(show_embed_regs(I,Jwm_Maity_1,Wsize)), title('Maity low range embedding locations');

% save locations of mid range blocks
min = round((length(Ep_Maity)/2)-Wsize/2);
max = min + Wsize;
Jwm_Maity_2 = Ep_Maity(min:max,[1 2]);
% show selected blocks
subplot(2,3,4), imshow(show_embed_regs(I,Jwm_Maity_2,Wsize)), title('Maity mid range embedding locations');


%%  Implement NVF block selection process

% ******** Compute NVF to find most significantly percetual blocks for embedding *********
    nvf = mat2cell(NVF(I),m_vec,n_vec); % compute NVF map of image & divide into 8x8 blocks
%   figure, imshow(NVF(I))
%   a = NVF(I); a = sort(a(:)); figure, plot(a(1:1:end))
    Ep_nvf = zeros(num_sub_rows*num_sub_cols,3);
    pos = 1;
    % for each block record mean NVF value
    for m=1:num_sub_rows
        for n = 1:num_sub_cols
            Ep_nvf(pos,1) = m;      % save row location
            Ep_nvf(pos,2) = n;      % save col location
            Ep_nvf(pos,3) = mean2(nvf{m,n}); % mean NVF value
            pos = pos + 1;  
        end
    end
    %sort list in ascending order, lowest values indicate texture/edge regions
    Ep_nvf = sortrows(Ep_nvf,3,'ascend');
    % select n lowest blocks,where n = watermark size
     Jwm_nvf_1 = Ep_nvf(1:Wsize,[1 2]);
    
  Ep_nvf = sortrows(Ep_nvf,3,'descend');
    % select n highest blocks,where n = watermark size
     Jwm_nvf_2 = Ep_nvf(1:Wsize,[1 2]);
    
subplot(2,3,5), imshow(show_embed_regs(I,Jwm_nvf_1,Wsize)), title('NVF lowest range embedding locations (proposed locations)');
   
subplot(2,3,6), imshow(show_embed_regs(I,Jwm_nvf_2,Wsize)), title('NVF highest range embedding locations');
figure, imshow(NVF(I)), title('NVF of Lena')

%%  functions


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


