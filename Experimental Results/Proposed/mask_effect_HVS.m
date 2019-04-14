% function to implement contrast masking effect from Levicky paper
% Inputs: I = 8x8 dct matrix, T_in = current quantization matrix to be
% compared against. Contrast effect is applied to each pixel at location
% u,v within the input 8x8 dct matrix. For each location, the contrasting
% signal to be applied is determined from the two position matrices u_m and
% v_m. i.e. indicating the element positions to use from either the input
% dct matrix or a seperately given matrix when contrasting against the u,v
% elements from the input matrix. By default, self contrasting is
% implemented. If for example, each u,v element is to be contrasted against
% the DC coefficient of the input matrix, u_m and v_m must be set to an 8x8 all
% ones matrix. 
function T = mask_effect_HVS(I,T_in,nvf,I_m)

    phi = 1;
    strength = 1;
    
    if(nargin<4)
        I_m = I;        % contrast matrix set as input matrix
    end
    
    block_size = length(I); % should be 8x8
    total_nvf = sum(nvf,'all');
    
    % for each element within the weight block
    if(total_nvf<block_size^2)     
        w = ones(block_size)*(strength/(3*block_size^2))*(64-total_nvf); 
    else
        w = ones(block_size)*(strength/(block_size^2))*(64-total_nvf);   
    end
    
    % create matrices which indicate u,v position as their values at each element
    u = repmat(0:7,8,1)';
    v = u';
    % define contrast positions, in this case assume self-contrasting
    u_m = u;
    v_m = v;
    
    % create masking dct matrix, as defined by indexing matrices u_m and v_m
    for i = 1:8
        for j = 1:8
            I_m(i,j) = I_m(u_m(i,j)+1,v_m(i,j)+1);
        end
    end
    
    T = max(1,(exp(-pi*((u-u_m).^2 + (v-v_m).^2)./(phi*max(ones(8),sqrt(u.^2 + v.^2))).^2).*...
               abs(I_m)./T_in).^w);
               

end
