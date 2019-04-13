
% Program to demonstrate bit plane (spatial) embedding
% Requires Lena image and logo512 image to be in same directory

clear all, close all,

% read in host image
host = rgb2gray(imread('Lena.ppm'));
figure(1), subplot(1,2,1), imshow(host); title('Lena');

% For reference, extract each of the 8 bit planes and plot
figure(2);
B1 = bitget(host,1); subplot(2,4,1), imshow(logical(B1));  title('Lena bit plane 1');
B2 = bitget(host,2); subplot(2,4,2), imshow(logical(B2));  title('Lena bit plane 2'); 
B3 = bitget(host,3); subplot(2,4,3), imshow(logical(B3));  title('Lena bit plane 3'); 
B4 = bitget(host,4); subplot(2,4,4), imshow(logical(B4));  title('Lena bit plane 4');
B5 = bitget(host,5); subplot(2,4,5), imshow(logical(B5));  title('Lena bit plane 5');
B6 = bitget(host,6); subplot(2,4,6), imshow(logical(B6));  title('Lena bit plane 6');
B7 = bitget(host,7); subplot(2,4,7), imshow(logical(B7));  title('Lena bit plane 7');
B8 = bitget(host,8); subplot(2,4,8), imshow(logical(B8));  title('Lena bit plane 8');

% read in binary watermark image, must be same size as host
WM = logical(imread('logo512.png'));
figure(1), subplot(1,2,2), imshow(WM); title('Watermark');

% replace each of the bit planes with the watermark image and plot result
% for each plane
figure(3),
OUT1 = bitset(host,1,WM); subplot(2,4,1), imshow(OUT1), title('Plane 1 watermarked');
OUT2 = bitset(host,2,WM); subplot(2,4,2), imshow(OUT2), title('Plane 2 watermarked');
OUT3 = bitset(host,3,WM); subplot(2,4,3), imshow(OUT3), title('Plane 3 watermarked');
OUT4 = bitset(host,4,WM); subplot(2,4,4), imshow(OUT4), title('Plane 4 watermarked');
OUT5 = bitset(host,5,WM); subplot(2,4,5), imshow(OUT5), title('Plane 5 watermarked');
OUT6 = bitset(host,6,WM); subplot(2,4,6), imshow(OUT6), title('Plane 6 watermarked');
OUT7 = bitset(host,7,WM); subplot(2,4,7), imshow(OUT7), title('Plane 7 watermarked');
OUT8 = bitset(host,8,WM); subplot(2,4,8), imshow(OUT8), title('Plane 8 watermarked');


% For reference, extract the 1,3,5,8 bit planes from Lena
figure(4);
B1 = bitget(host,1); subplot(2,4,1), imshow(logical(B1)); title('Lena bit plane 1'); 
B3 = bitget(host,3); subplot(2,4,2), imshow(logical(B3)); title('Lena bit plane 3'); 
B6 = bitget(host,6); subplot(2,4,3), imshow(logical(B6)); title('Lena bit plane 6');
B8 = bitget(host,8); subplot(2,4,4), imshow(logical(B8)); title('Lena bit plane 8');

% replace each of the bit planes with the watermark image and plot result
% for each plane

OUT1 = bitset(host,1,WM); subplot(2,4,5), imshow(OUT1), title('Plane 1 watermarked');
OUT3 = bitset(host,3,WM); subplot(2,4,6), imshow(OUT3), title('Plane 3 watermarked');
OUT6 = bitset(host,6,WM); subplot(2,4,7), imshow(OUT6), title('Plane 6 watermarked');
OUT8 = bitset(host,8,WM); subplot(2,4,8), imshow(OUT8), title('Plane 8 watermarked');




