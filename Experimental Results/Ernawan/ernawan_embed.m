% function implementing Ernawans watermarking embedding procedure from:
% [1]   F. Ernawan and M. N. Kabir, "A Robust Image Watermarking Technique With an Optimal 
%       DCT-Psychovisual Threshold," IEEE Access, vol. 6, pp. 20464-20480, 2018.

function [J,Jwm,Wsize] = ernawan_embed(I,WM_in,T)

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

% ******************* Compute modified entropy for each sub-block ********************
% N.B the equation used here to compute the modified entropy assumes that
% there is a typo in the original paper and adopts similar formula used by Lai
    Ep = zeros(num_sub_rows*num_sub_cols,3);
    pos = 1;
    for m=1:num_sub_rows
        for n = 1:num_sub_cols
            p = imhist(uint8(J{m,n}));                  % create pdf for pixels in each sub block
            p(p==0) = [];                               % isolate non-zero pixels
            p = p ./(block_size*block_size);            % normalize pdf
            Ep(pos,1) = m;                              % save row location
            Ep(pos,2) = n;                              % save col location
            Ep(pos,3) = sum(p.*exp(1-p) - p.*log2(p));  % modified entropy
            pos = pos + 1;  
        end
    end
    
    %sort list in ascending order of Entropy values
    Ep = sortrows(Ep,3,'ascend');
    % select n lowest blocks,where n = watermark size
    Jwm = Ep(1:Wsize,[1 2]);
%     show_embed_regs(I,Ep,Wsize);

% ******************************** Watermark Embedding ********************************

    A = zeros(1,6);
    D = dctmtx(block_size);
    
    for n=1:Wsize

        %compute dct of each 8x8 sub image
        dct_mat = D*(J{Jwm(n,1),Jwm(n,2)})*D';

        % create 'A' vector, from fig.3, A[n] -> DCT_COEFFS[11,12,13,14,17,16]
        A(1) = dct_mat(4,2);
        A(2) = dct_mat(3,3);
        A(3) = dct_mat(2,4);
        A(4) = dct_mat(1,5);
        A(5) = dct_mat(3,4);
        A(6) = dct_mat(2,5);

        for x = 1:2:length(A)
            % algorithm 1: strength parameter
            if(A(x)<0)
                alpha = -T;
            else
                alpha = T;
            end
            if(A(x+1)<0)
                beta = -T;
            else
                beta = T;
            end
            % algorithm 2: coefficicent modify
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
        % update sub image
        J{Jwm(n,1),Jwm(n,2)} = D'*dct_mat*D;
    end
    % convert modified image back to original uint8 matrix form
     J = uint8(cell2mat(J));

end