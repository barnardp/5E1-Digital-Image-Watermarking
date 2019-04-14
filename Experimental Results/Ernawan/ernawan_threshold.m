% function to compute optimal embedding strength using SSIM and NC as described in:
% [1]   F. Ernawan and M. N. Kabir, "A Robust Image Watermarking Technique With an Optimal 
%       DCT-Psychovisual Threshold," IEEE Access, vol. 6, pp. 20464-20480, 2018.

function thresh = ernawan_threshold(I,WM_in,~)

    thresh = 10;  
    span_thresh = 1:30;
    
    if(nargin == 2)    
        for T = span_thresh
            % Embed watermark
            [J,Jwm,Wsize] = ernawan_embed(I,WM_in,T);
            % JPEG compress Watermarked Image 
            imwrite(J,'JPEG.jpg','jpg','Quality',50);
            J_jpeg = imread('JPEG.jpg'); 
            % Extract Watermark
            WM_out = ernawan_extract(J_jpeg,Jwm,Wsize,T);

            if(NORM_CORR(WM_out,WM_in)>mssim(J,I))
                thresh = T;   
    %             figure, imshowpair(uint8(I),uint8(J),'montage')
            return
            end
        end  
    end
    
    % if 3 arguments are specified function will also plot a graph of the
    % corresponding relationship between the SSIM and NC tradeoff values
    if(nargin == 3) 
        span_thresh = 1:30;
        nc_val = zeros(1,length(span_thresh));
        ssim_val = zeros(1,length(span_thresh));
        found = false;
        counter = 1;
        for T = span_thresh
            % Embed watermark
            [J,Jwm,Wsize] = ernawan_embed(I,WM_in,T);
            % JPEG compress Watermarked Image 
            imwrite(J,'JPEG.jpg','jpg','Quality',50);
            J_jpeg = imread('JPEG.jpg'); 
            % Extract Watermark
            WM_out = ernawan_extract(J_jpeg,Jwm,Wsize,T);
            ssim_val(counter) = mssim(J,I);
            nc_val(counter) = NORM_CORR(WM_out,WM_in);
            if(nc_val(counter)>ssim_val(counter)&&~found)
                thresh = T;   
                found = true;
            end
            counter = counter + 1;
        end
        figure(), hold on
        plot(span_thresh,ssim_val,'r-o')
        plot(span_thresh,nc_val,'g-s')
        title('Trade of between MSSIM and NC values for Ernawans Scheme')
        ylabel('Value')
        xlabel('Threshold against JPEG with Quality 50%')
        legend('MSSIM','NC','Location','East')
    end

end
