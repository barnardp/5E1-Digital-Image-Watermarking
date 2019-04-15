
% Implementation of Zhang's HVS modelled as outlined in :
% "spatial jnd profile for image in dct domain"
% inputs: img = 8x8 input block from spatial domain of image

close all
clear all
clc

I = imread('Lena.ppm');
if(ndims(I)>2)
    I = rgb2gray(I);
end

% create vectors to segment an image into non-overlapping blocks of size 8
block_size = 8;
[Jrows,Jcols] = size(I);
num_sub_rows = Jrows/block_size; num_sub_cols = Jcols/block_size;
m_vec = block_size*ones(1,num_sub_rows); n_vec = block_size*ones(1,num_sub_cols);

% create edge map for contrast mask stage
edge_map = edge(I,'canny');

% create segmented images 
J = mat2cell(double(I),m_vec,n_vec);
luminance_mask = mat2cell(zeros(size(I)),m_vec,n_vec);
F_contrast = mat2cell(zeros(size(I)),m_vec,n_vec);
T_JND = mat2cell(zeros(size(I)),m_vec,n_vec);
edge_map = mat2cell(double(edge_map),m_vec,n_vec);
edge_type = zeros(num_sub_rows);

% create freq sensitivity mask
T_basic = freq_sense_zhang(); 
% figure, surf(T_basic),zlabel('Threshold'),ylabel('v-direction'),xlabel('u-direction'),set(gca,'fontsize',16)
% xticks(0:7), yticks(0:7);
% title('Zhangs CSF')

for m=1:num_sub_rows
    for n = 1:num_sub_cols
        % implement luminance adaption effect as given in eq 18 of paper:
        blck_mean = mean2(J{m,n});
        F_lumin = ((60-blck_mean)/150 + 1)*(blck_mean<=60) + ...
                   1*(60<blck_mean && blck_mean<170) + ...
                  ((blck_mean-170)/425 + 1)*(blck_mean>=170);
        
         % create contrast mask and multiply according to eq 2 for final JND mask
         [F_contrast{m,n},edge_type(m,n)] = contrast_zhang(J{m,n},edge_map{m,n},T_basic,F_lumin);
         
         luminance_mask{m,n} = ones(8)*F_lumin;
         T_JND{m,n} = T_basic*F_lumin.*F_contrast{m,n};

    end
end

figure, imshow(edge_type,[])
title('Zhang block classificaion for Lena image newline')
xlabel('black - plain, gray - edge, white - texture')
set(gca,'fontsize',18)

luminance_mask = cell2mat(luminance_mask);
figure, imshow(luminance_mask,[])
title('Relative luminance adaption factor for Lena image using Zhang HVS model')
set(gca,'fontsize',18)


figure, surf(T_JND{25,25})
title('JND for block at position 25,25');
xticks(0:7),yticks(0:7)

T_JND = cell2mat(T_JND);
figure, imshow(T_JND,[])
title('Relative contrast masking (JND) thresholds using Zhangs HVS model')
set(gca,'fontsize',18)


% Implementation of Zhang's HVS modelled as outlined in :
% "spatial jnd profile for image in dct domain"
% inputs: img = 8x8 input block from spatial domain of image
function [f_contrast, block_type] = contrast_zhang(img,edge_map,T_basic,F_lumin)

    block_size = length(img);
    
    % implement contrast masking as given in eq's 19-22 of paper:
    p_edge = sum(sum(edge_map))/block_size^2;       
    block_type = 0*(p_edge<=0.1) + ...
                 0.5*(0.1<p_edge && p_edge<=0.2) + ...
                 1*(0.2<p_edge); 
             
    elevation_factor = zeros(block_size); 
    f_contrast = zeros(block_size); 
    dct_mat = dct2(img);
    for i = 0:7
        for j = 0:7
            elevation_factor(i+1,j+1) = 1*(block_type==0 || block_type==0.5) + ...
                                    2.25*(block_type==1 && (i^2+j^2)<=16) + ...
                                    1.25*(block_type==1 && (i^2+j^2)>16);
                                
            if( (i^2+j^2)<=16 && (block_type==0 || block_type==0.5) )
                f_contrast(i+1,j+1) = elevation_factor(i+1,j+1)*((i^2+j^2)<=16)*(block_type==0 || block_type==0.5);
            else
                f_contrast(i+1,j+1) = elevation_factor(i+1,j+1)*min(4,max(1, ...
                                  (abs(dct_mat(i+1,j+1))./(T_basic(i+1,j+1).*F_lumin)).^0.36));
            end
            
        end
    end  

end




