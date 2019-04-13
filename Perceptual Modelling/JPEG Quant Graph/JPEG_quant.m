
clear all, close all

tb_75 = JPEG_quant(75);
tb_50 = JPEG_quant(50);
tb_25 = JPEG_quant(25);


subplot(2,3,1), surf(tb_25), 
title(['Baseline Quantization' newline 'Table in JPEG (Q = 25)'])
ylabel('J-Freq'), xlabel('I-Freq'), zlabel('Quantization Value')
set(gca,'fontsize',24)
xticks(0:7), yticks(0:7), zticks(0:40:max(max(tb_25)))


subplot(2,3,2), surf(tb_50), 
title(['Baseline Quantization' newline 'Table in JPEG (Q = 50)'])
ylabel('J-Freq'), xlabel('I-Freq'), zlabel('Quantization Value')
set(gca,'fontsize',24)
xticks(0:7), yticks(0:7), zticks(0:20:max(max(tb_50)))


subplot(2,3,3), surf(tb_75), 
title(['Baseline Quantization' newline 'Table in JPEG (Q = 75)'])
ylabel('J-Freq'), xlabel('I-Freq'), zlabel('Quantization Value')
set(gca,'fontsize',24)
xticks(0:7), yticks(0:7), zticks(0:20:max(max(tb_75)))



function Ts = JPEG_quant(Q)

    % JPEG base quantization matrix
    Tb = [16 11 10 16 24 40 51 61; 12 12 14 19 26 58 60 55; ...
         14 13 16 24 40 57 69 56; 14 17 22 29 51 87 80 62; ...
         18 22 37 56 68 109 103 77; 24 35 55 64 81 104 113 92; ...
         49 64 78 87 103 121 120 101; 72 92 95 98 112 100 103 99];
     

    if (Q < 50)
    S = 5000/Q;
    else
        S = 200 - 2*Q;
    end

    Ts = floor((S*Tb + 50) / 100);
    Ts(Ts == 0) = 1; % if quality set to 100

    
end



