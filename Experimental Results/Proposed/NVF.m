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

