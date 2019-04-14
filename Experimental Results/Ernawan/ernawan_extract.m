% function implementing Ernawans watermarking extracting procedure from:
% [1]   F. Ernawan and M. N. Kabir, "A Robust Image Watermarking Technique With an Optimal 
%       DCT-Psychovisual Threshold," IEEE Access, vol. 6, pp. 20464-20480, 2018.

function WM_out = ernawan_extract(I,Jwm,Wsize,T)
    
    [Irows,Icols] = size(I);
    block_size = 8;
    num_sub_rows = Irows/block_size; num_sub_cols = Icols/block_size;
    m_vec=block_size*ones(1,num_sub_rows); n_vec=block_size*ones(1,num_sub_cols);
    WM_out = zeros(1,Wsize);
    Ak = zeros(1,6);
    D = dctmtx(block_size);
    % convert watermarked image back to cell with 8x8 sub blocks
    J=mat2cell(double(I),m_vec,n_vec); %J=mat2cell(J,m_vec,n_vec); % J=mat2cell(uint8(J*255),m_vec,n_vec);
    for n=1:Wsize

        %compute dct of each 8x8 sub image
        dct_mat = D*(J{Jwm(n,1),Jwm(n,2)})*D';

        % create A vector, from fig.3
        Ak(1) = dct_mat(4,2);
        Ak(2) = dct_mat(3,3);
        Ak(3) = dct_mat(2,4);
        Ak(4) = dct_mat(1,5);
        Ak(5) = dct_mat(3,4);
        Ak(6) = dct_mat(2,5);

        % Extraction function assumes typo in Ernawan's paper,
        % the following function compares each coefficient pair and 
        % takes the majority as indicating the watermark bit
       if(sum(abs(Ak(1:2:end))>abs(Ak(2:2:end)))>1)
          WM_out(1,n) = 1;
          % else wm = 0, as aready initiated 
       end

    end

    % remap watermark vector to image
    WM_out = inv_arnold(reshape(WM_out,sqrt(Wsize),[]),10);

end