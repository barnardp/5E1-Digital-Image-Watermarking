% function implementing Levicky's HVS adapted to Ernawan's scheme. The
% following references have been used throughout:
% [1]   D. Levicky and P. Foris, "Implementations of HVS Models in Digital Image 
%       Watermarking," vol. 16, no. 1, pp. 45-50, Apr 2007.
% [2]   A. Ahumada, A. J, and H. A. Peterson, Luminance-model-based DCT quantization 
%       for color image compression. 1992.
% [3]   H. A. Peterson, A. Ahumada, and A. Watson, An Improved Detection Model for DCT 
%       Coefficient Quantization. 1993.
% [4]   A. Watson, DCT quantization matrices visually optimized for individual images. 
%       1993.
% [5]   S. Voloshynovskiy, A. Herrigel, N. Baumgaertner, and T. Pun, A Stochastic 
%       Approach to Content Adaptive Digital Image Watermarking. 1999, pp. 211-236.

function [J,Jwm,Wsize] = levicky_embed(I,WM_in,Thresh)

    [Jrows,Jcols] = size(I);
    [Wrows,Wcols] = size(WM_in);
    Wsize = Wrows*Wcols;
    
    % scramble watermark
    WM_in = arnold(WM_in,10);

    % Divide image into 8x8 pixel sub images of non-overlapping blocks
    block_size = 8;
    num_sub_rows = Jrows/block_size; num_sub_cols = Jcols/block_size;
    m_vec = block_size*ones(1,num_sub_rows); n_vec = block_size*ones(1,num_sub_cols);
    J = mat2cell(double(I),m_vec,n_vec);

% ******** Compute NVF to find most significantly percetual blocks for embedding *********
    nvf = mat2cell(NVF(I),m_vec,n_vec); % compute NVF map of image & divide into 8x8 blocks
%   figure, imshow(NVF(I))
%   a = NVF(I); a = sort(a(:)); figure, plot(a(1:1:end))
    Ep = zeros(num_sub_rows*num_sub_cols,3);
    pos = 1;
    % for each block record mean NVF value
    for m=1:num_sub_rows
        for n = 1:num_sub_cols
            Ep(pos,1) = m;      % save row location
            Ep(pos,2) = n;      % save col location
            Ep(pos,3) = mean2(nvf{m,n}); % mean NVF value
            pos = pos + 1;  
        end
    end
    %sort list in ascending order, lowest values indicate texture/edge regions
    Ep = sortrows(Ep,3,'ascend');
    
    % select n lowest blocks,where n = watermark size
%      Jwm = Ep(1:Wsize,[1 2]);
    
    start = (length(Ep)/2)-(Wsize/2); % NB report says to take lowest n, not center values
    Jwm = Ep(start:start+Wsize-1,[1 2]);
    

% ******************************** Watermark Embedding ********************************

    A = zeros(1,6);
    D = dctmtx(block_size);
    % calculate dc coefficient corresponding to luminance of image
    mean_dc = 8*mean2(I); 
    % calculate frequency sensitivity based JND matrix
    sensitivity_mask = freq_sense_HVS(); 
    %figure, surf(T),zlabel('Threshold'),ylabel('v-direction'),xlabel('u-direction'),set(gca,'fontsize',16)
    
 
    for n=1:Wsize

        %compute dct of each 8x8 block
        dct_mat = D*(J{Jwm(n,1),Jwm(n,2)})*D'; 
        % add in weighted freq sense JND matrix 
        luminance_mask = sensitivity_mask.*(dct_mat(1,1)/mean_dc).^0.649;
        % add in contrast masking effect JND matrix 
        contrast_mask_levicky = luminance_mask.*mask_effect_HVS(dct_mat,luminance_mask,nvf{Jwm(n,1),Jwm(n,2)});
           
       
        % create 'A' vector, A[n] -> DCT_COEFFS[11,12,13,14,17,16]
        A(1) = dct_mat(4,2); A(2) = dct_mat(3,3);
        A(3) = dct_mat(2,4); A(4) = dct_mat(1,5);
        A(5) = dct_mat(3,4); A(6) = dct_mat(2,5);
        
        
        Tb(1:2) = ((contrast_mask_levicky(4,2) + contrast_mask_levicky(3,3))/2)+Thresh;  
        Tb(3:4) = ((contrast_mask_levicky(2,4) + contrast_mask_levicky(1,5))/2)+Thresh;
        Tb(5:6) = ((contrast_mask_levicky(3,4) + contrast_mask_levicky(2,5))/2)+Thresh;
        
        for x = 1:2:length(A)
            % algorithm 1
            if(A(x)<0)
                alpha = -Tb(x);
            else
                alpha = Tb(x);
            end
            if(A(x+1)<0)
                beta = -Tb(x+1);
            else
                beta = Tb(x+1);
            end
            % algorithm 2
            if (WM_in(n) == 1)
                if(abs(A(x))<abs(A(x+1)))
                    C = A(x);
                    A(x) = A(x+1)+beta;
                    A(x+1) = C;
                else
                    A(x) = A(x)+alpha;
                end
            else
                if(abs(A(x))<abs(A(x+1)))
                    A(x+1) = A(x+1)+beta;
                else
                    C = A(x);
                    A(x) = A(x+1);
                    A(x+1) = C+alpha;
                end
            end
                
        end
        
        
        
        % set modified A values back into DCT coeffs
        dct_mat(4,2) = A(1);
        dct_mat(3,3) = A(2);
        dct_mat(2,4) = A(3);
        dct_mat(1,5) = A(4);
        dct_mat(3,4) = A(5);
        dct_mat(2,5) = A(6);
        % update sub image, logic shift back to range 0-255
        J{Jwm(n,1),Jwm(n,2)} = D'*dct_mat*D;
    end
    % convert modified image back to original uint8 matrix form
     J = uint8(cell2mat(J));

end









