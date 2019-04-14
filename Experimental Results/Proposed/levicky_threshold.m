function thresh = levicky_threshold(I,WM_in,image)

    thresh = 99;
    span_thresh = [0:0.2:5 6:20];
    
    if(nargin == 2)    
        for T = span_thresh
            % Embed watermark
            [J,Jwm,Wsize] = levicky_embed(I,WM_in,T);
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
    
    
    if(nargin == 3) 
        span_thresh = 1:30;
        nc_val = zeros(1,length(span_thresh));
        ssim_val = zeros(1,length(span_thresh));
        found = false;
        counter = 1;
        for T = span_thresh
            % Embed watermark
            [J,Jwm,Wsize] = levicky_embed(I,WM_in,T);
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
        title(['Trade of between MSSIM and NC values for' newline ...
               ' Proposed Scheme for ' image ' image'])
        ylabel('Value')
        xlabel('Threshold against JPEG with Quality 50%')
        legend('MSSIM','NC','Location','East')
        set(gca,'fontsize',18)
    end

end
