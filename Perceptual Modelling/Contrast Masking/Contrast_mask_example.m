
% example for computing watson's contrast mask, including prior CSF and luminance adaption models
%[1]    A. J. Ahumada and H. A. Peterson, "Luminance-model-based DCT quantization 
%       for color image compression," in Human vision, visual processing, and digital 
%       display III, 1992, vol. 
% [2]   A. B. Watson, "DCT quantization matrices visually optimized for individual images,
%       " in Human vision, visual processing, and digital display IV, 1993,
%       vol. 1913: International Society for Optics and Photonics, pp. 202-217.

close all
clear all

I = imread('Lena.ppm');
if(ndims(I)>2)
    I = rgb2gray(I);
end

% create vectors to segment an image into non-overlapping blocks of size 8
block_size = 8;
[Jrows,Jcols] = size(I);
num_sub_rows = Jrows/block_size; num_sub_cols = Jcols/block_size;
m_vec = block_size*ones(1,num_sub_rows); n_vec = block_size*ones(1,num_sub_cols);

% create segmented images 
J = mat2cell(double(I),m_vec,n_vec);
luminance_mask = mat2cell(zeros(size(I)),m_vec,n_vec);
contrast_mask_watson = mat2cell(zeros(size(I)),m_vec,n_vec);
error_dct = mat2cell(zeros(size(I)),m_vec,n_vec);
masked_sensitivity = mat2cell(zeros(size(I)),m_vec,n_vec);
contrast_mask_levicky = mat2cell(zeros(size(I)),m_vec,n_vec);

% create watsons mask for controlling weber effect
w_watson = ones(8)*0.7; w_watson(1,1) = 0;
 % calculate dc coefficient corresponding to luminance of image
mean_dc = 8*mean2(I); 

% create freq sensitivity mask
sensitivity_mask = freq_sense_ahumada_original(I); 

for m=1:num_sub_rows
    for n = 1:num_sub_cols
         dct_mat = dct2(J{m,n});
         % create luminance adaption mask using watsons formula
         luminance_mask{m,n} = sensitivity_mask.*(dct_mat(1,1)/mean_dc).^0.649;
         % create contrast maskk using watson formula
         contrast_mask_watson{m,n} = max(luminance_mask{m,n},(abs(dct_mat).^w_watson).*luminance_mask{m,n}.^(1-w_watson));
         masked_sensitivity{m,n} = 1./contrast_mask_watson{m,n}; % corresponds to graph 3 of watsons paper  
    end
end


luminance_mask = cell2mat(luminance_mask);
figure, imshow(luminance_mask,[])
title('Relative luminance adaption thresholds for Lena image')
set(gca,'fontsize',18)

contrast_mask_watson = cell2mat(contrast_mask_watson);
figure, imshow(contrast_mask_watson,[])
title('Relative contrast masking thresholds using Watsons formula')
set(gca,'fontsize',18)



% function to compute Ahumada and Peterson's CSF given in [1].
%[1]    A. J. Ahumada and H. A. Peterson, "Luminance-model-based DCT quantization 
%       for color image compression," in Human vision, visual processing, and digital 
%       display III, 1992, vol. 
% [2]   A. B. Watson, "DCT quantization matrices visually optimized for individual images,
%       " in Human vision, visual processing, and digital display IV, 1993,
%       vol. 1913: International Society for Optics and Photonics, pp. 202-217.
% [3]   P. Foris and D. Levicky, "Human Visual System Models in Digital Image 
%       Watermarking," vol. 13, no. 4, 13, pp. 38-43, Dec 2004.

% output 'T' corresponds the JND matrix
function T = freq_sense_ahumada_original(image)

if(nargin<1)
    L_i = 128;
else
    L_i = mean2(image);  % cd/m^2 luminance of image
end


L_0 = 65;           % cd/m^2 background luminance of screen,  used in [2] 
L_tot = L_0 + L_i;  % cd/m^2
L_T = 13.45;        % cd/m^2
S_0 = 94.7;         
a_T = 0.649;        
f_0 = 6.78;         % cylces/degree
a_f = 0.182; 
L_f = 300;          % cd/m^2
K_0 = 3.125;
a_K = 0.0706;
L_K = 300;          % cd/m^2
Eta = 0.6;          % obliqness factor, used in [3]
Wx = 7.1527/256;    % pixels/degree horizontal height of pixel, used in [2]
Wy = 7.1527/256;    % pixels/degree vertical height of pixel, used in [2]

% calculate Tmin, Fmin and K value as shown in [2]
if(L_tot<=L_T)
    T_min = (L_tot/S_0)*((L_T/L_tot)^(1-a_T));
else
    T_min = L_tot/S_0;
end

if(L_tot<=L_f)
    f_min = f_0*(L_tot/L_f)^a_f;
else
    f_min = f_0;
end

if(L_tot<=L_K)
    K = K_0*((L_tot/L_K)^a_K);
else
    K = K_0;
end



% ********************* calculate min threshold for 2-orientation case *********************

% calculate spatial frequency matrix associated with dct
f_spat = (1/16)*sqrt(repmat(((0:7)/Wx).^2,8,1)' + repmat(((0:7)/Wy).^2,8,1) ); 
% calculate C(u)*C(v) normalization term from in [1]
C_u = repmat([(sqrt(1/8)) sqrt(2/8)*ones(1,7)],8,1)';
C_uv = C_u.*C_u';
% note that(f(u,0)^2 + f(0,v)^2)^2 term equivilant to fuv^4 as  in [3]
t1 = f_spat.^4;
% calculate f(u,0)^2 * f(0,v)^2 term as (f_mn(:,1).^2.*f_mn(1,:).^2)
t2 = (f_spat(:,1).^2).*(f_spat(1,:).^2);

% combine terms to calculate frequency sensitivity function as in [1]
T = ((T_min*t1)./(C_uv.*(t1-4*(1-Eta)*t2))).*(10.^(K*(log10(f_spat)-log10(f_min*ones(8))).^2));
T(1) =  min(T(1,2),T(2,1));

% NB normalization term aleardy included in function, only need to scale
% according to change in luminance/quantization to get JND:
T = T*(255-0)/256;

% plot result
figure, subplot(2,3,1), surf(0:7,0:7,T)
zlabel('JND');
ylabel('J-Freq');
xlabel('I-Freq');
title('Ahumada & Petersons JND')
xticks(0:7), yticks(0:7), zticks(0:20:max(max(T)))
set(gca,'fontsize',18)

subplot(2,3,2), surf(f_spat(1:end,1)',f_spat(1:end,1),1./T)
zlabel('Contrast Sensitivity');
ylabel(['J-Freq' newline '[Cycles/Deg]']);
xlabel(['I-Freq' newline '[Cycles/Deg]']);
title('Ahumada & Petersons CSF')
xticks(0:4:max(max(f_spat))), yticks(0:4:max(max(f_spat))), zticks(0:.1:max(max(1./T)))
set(gca,'fontsize',18)

% ************* Isolate CSF for a single Orientation, NB, CSF = L/T_min, let j = 0 ************* 


T_single = T(2:end,1); % i.e for j = 0, only model for i>0
% get CSF
CSF = 1./T_single';

% fit line to points
p = polyfit(f_spat(2:end,1)',CSF,5);   % fit line of order 5
x1 = linspace(1,max(f_spat(2:8)));
y1 = polyval(p,x1);
% plot
figure, plot(f_spat(2:end,1),CSF,'X','Markersize',16)
hold on
plot(x1,y1)
hold off
ylabel('Contrast Sensitivity L/T')
xlabel('Frequency [cycles/degree]')
title('Ahumada & Peterson CSF')
legend('Data Points', 'Fitted Line')
set(gca,'fontsize',26)


end

