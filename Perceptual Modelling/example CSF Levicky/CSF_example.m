% Generate the normalized CSF as given by the equation in Levicky's paper
%[1]    P. Foris and D. Levicky, "Human Visual System Models in Digital Image Watermarking,
%       " vol. 13, no. 4, 13, pp. 38-43, Dec 2004.

CSF = zeros(60,1);
for f = 1:1:60
    CSF(f) = 2.6*(0.0192+0.114*f)*exp(-(0.114*f)^1.1);
end

figure, plot(CSF), title('Normalized Contrast Sensitivity Function')
ylabel('Sensitivity'), xlabel('Frequency [cycles/degree]')
set(gca,'fontsize',24)