% MATLAB for figure 4, demonstrating DCT embedding
clear all, close all

% create and plot cosine matrix
cos_mat = dctmtx(4);
x1 = subplot(3,4,1);
image(cos_mat);                                    
colormap(x1,[]);                   
textStrings = num2str(cos_mat(:), '%0.4f');                   
textStrings = strtrim(cellstr(textStrings));       
[x, y] = meshgrid(1:4);                          
hStrings = text(x(:), y(:), textStrings(:),'HorizontalAlignment', 'center');           
xlabel(['C' newline '(Float 4-Point Precision)']), grid on;
set(gca,'xtick',[1.5:1:4])
set(gca,'ytick',[1.5:1:4])
set(gca,'yticklabel',[],'xticklabel',[]);
ax=gca;
ax.GridAlpha=1;
ax.FontSize = 16;


% create and plot image 
% spat_img = round(rand(4)*255);                   % A 4 x 4  matrix of random values from 0 to 1
spat_img_orig = [10,245,83,86;165,217,254,36;50,80,116,65;252,160,119,2];
x2 = subplot(3,4,2);
imagesc(spat_img_orig);                                 % Create a colored plot of the matrix values
colormap(x2,flipud(flipud(gray)));                   
textStrings = num2str(spat_img_orig(:));                % Create strings from the matrix values
textStrings = strtrim(cellstr(textStrings));       % Remove any space padding
[x, y] = meshgrid(1:4);                            % Create x and y coordinates for the strings
hStrings = text(x(:), y(:), textStrings(:),'HorizontalAlignment', 'center');
midValue = mean(get(gca, 'CLim'));                 % Get the middle value of the color range
textColors = repmat(spat_img_orig(:) < midValue, 1, 3); % Choose white or black for the                                                 
set(hStrings, {'Color'}, num2cell(textColors, 2)); % Change the text colors
xlabel('I')
xlabel(['I' newline '(8-bit Precision)'])
set(gca,'xtick',[],'ytick',[],'fontsize',16)


% plot cosine matrix transposed
cos_mat_trans = cos_mat';
x1 = subplot(3,4,3);
image(cos_mat_trans);                                    
colormap(x1,[]);                   
textStrings = num2str(cos_mat_trans(:), '%0.4f');                   
textStrings = strtrim(cellstr(textStrings));      
[x, y] = meshgrid(1:4);                            
hStrings = text(x(:), y(:), textStrings(:),'HorizontalAlignment', 'center');
midValue = mean(get(gca, 'CLim'));                 
grid on;
set(gca,'xtick',[1.5:1:4])
set(gca,'ytick',[1.5:1:4])
set(gca,'yticklabel',[],'xticklabel',[]);
ax=gca;
ax.GridAlpha=1;
xlabel(['C`' newline '(Float 4-Point Precision)'])
ax.FontSize = 16;


% create and plot dct matrix
dct_orig = cos_mat*spat_img_orig*cos_mat_trans;                          
x2 = subplot(3,4,4);
imagesc(dct_orig);                                     
colormap(x2,flipud(flipud(gray)));                   
textStrings = num2str(dct_orig(:), '%0.4f');                     
textStrings = strtrim(cellstr(textStrings));      
[x, y] = meshgrid(1:4);                            
hStrings = text(x(:), y(:), textStrings(:),'HorizontalAlignment', 'center');
midValue = mean(get(gca, 'CLim'));                
textColors = repmat(dct_orig(:) < midValue, 1, 3);                                                  
set(hStrings, {'Color'}, num2cell(textColors, 2)); 
xlabel(['F' newline '(Float 4-Point Precision)'])
set(gca,'xtick',[],'ytick',[],'fontsize',16)



% embedd watermark and plot
dct_embed = dct_orig;                        
dct_embed(2,1) = dct_embed(2,1)*(1-0.5); % embedding
dct_embed(1,2) = dct_embed(1,2)*(1+0.5); % embedding
x2 = subplot(3,4,12);
imagesc(dct_embed);                                    
colormap(x2,flipud(flipud(gray)));                   
textStrings = num2str(dct_embed(:), '%0.4f');                  
textStrings = strtrim(cellstr(textStrings));      
[x, y] = meshgrid(1:4);                            
hStrings = text(x(:), y(:), textStrings(:),'HorizontalAlignment', 'center');
midValue = mean(get(gca, 'CLim'));                
textColors = repmat(dct_embed(:) < midValue, 1, 3);                                                  
set(hStrings, {'Color'}, num2cell(textColors, 2)); 
xlabel(['F Watermarked' newline '(Float 4-Point Precision)'])
set(gca,'xtick',[],'ytick',[],'fontsize',16)
     
     
% convert back to spatial domain
spat_wm_float = cos_mat_trans*dct_embed*cos_mat;                        
x2 = subplot(3,4,11);
imagesc(spat_wm_float);                                      
colormap(x2,flipud(flipud(gray)));                   
textStrings = num2str(spat_wm_float(:), '%0.4f');                 
textStrings = strtrim(cellstr(textStrings));      
[x, y] = meshgrid(1:4);                          
hStrings = text(x(:), y(:), textStrings(:),'HorizontalAlignment', 'center');
midValue = mean(get(gca, 'CLim'));                
textColors = repmat(spat_wm_float(:) < midValue, 1, 3);                                                
set(hStrings, {'Color'}, num2cell(textColors, 2)); 
xlabel(['I Watermarked' newline '(Float 4-Point Precision)'])
set(gca,'xtick',[],'ytick',[],'fontsize',16)


% quantize
spat_quant = uint8(spat_wm_float);                          
x2 = subplot(3,4,10);
imagesc(spat_quant);                                      
colormap(x2,flipud(flipud(gray)));                   
textStrings = num2str(spat_quant(:));                    
textStrings = strtrim(cellstr(textStrings));      
[x, y] = meshgrid(1:4);                        
hStrings = text(x(:), y(:), textStrings(:),'HorizontalAlignment', 'center');
midValue = mean(get(gca, 'CLim'));                
textColors = repmat(spat_quant(:) < midValue, 1, 3);                                                 
set(hStrings, {'Color'}, num2cell(textColors, 2)); 
xlabel(['I Watermarked' newline '(8-bit Precision)'])
set(gca,'xtick',[],'ytick',[],'fontsize',16)


% convert back to dct
dct_quant = dct2(spat_quant);                        
x2 = subplot(3,4,9);
imagesc(dct_quant);                                   
colormap(x2,flipud(flipud(gray)));                   
textStrings = num2str(dct_quant(:), '%0.4f');                    
textStrings = strtrim(cellstr(textStrings));    
[x, y] = meshgrid(1:4);                           
hStrings = text(x(:), y(:), textStrings(:),'HorizontalAlignment', 'center');
midValue = mean(get(gca, 'CLim'));                
textColors = repmat(dct_quant(:) < midValue, 1, 3);                                               
set(hStrings, {'Color'}, num2cell(textColors, 2)); 
xlabel(['F Watermarked' newline '(Following Quantization)'])
set(gca,'xtick',[],'ytick',[],'fontsize',16)

   