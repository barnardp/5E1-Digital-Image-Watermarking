% function to calculate frequency sensitivity matrix for 8x8 block based on [1].
% NB The parameter values used here have been set to result in a similar
% sensitivity table as that shown in [2], however a similar table for this
% implementation is also given in pg 271 of [3], in which the choosen
% paramters in this case result in a slighly less conservative matrix
% 
%
% [1]   H. A. Peterson, A. Ahumada, and A. Watson, An Improved Detection Model for DCT 
%       Coefficient Quantization. 1993.
% [2]   P. Foris and D. Levicky, "Human Visual System Models in Digital Image 
%       Watermarking," vol. 13, no. 4, 13, pp. 38-43, Dec 2004.
% [3]   I. Cox, M. Miller, J. Bloom, J. Fridrich, and T. Kalker, Digital Watermarking and
%       Steganography. Morgan Kaufmann Publishers Inc., 2008, p. 624.

function T = freq_sense_HVS()

    Eta = 0.6;                  % obliqness factor, used in [3]
    Wx = 7.1527/256;            % NB. implies viewing dist of 8 image heights here
    Wy = 7.1527/256;            % pixels/degree vertical height of pixel, 
      
    % use parameters from 'Y' row in table 1, from [3]
    % T min = s*b, with s = 0.25, b = 1.000 (value of white in Y channel of CEI 1931)
    T_min = 0.25; 
    f_min = 3.1;
    K = 1.34;
    
    
    % calculate spatial frequency matrix associated with dct, using formula (4) from [3]
    f_spat = (1/16)*sqrt(repmat(((0:7)/Wx).^2,8,1)' + repmat(((0:7)/Wy).^2,8,1) ); 
    % calculate C(u)*C(v) term used to normalize T and convert to quantization matrix, from eq (2) in [1]
    C_u = repmat([(sqrt(1/8)) sqrt(2/8)*ones(1,7)],8,1)';
    C_uv = C_u.*C_u';
    % note that(f(u,0)^2 + f(0,v)^2)^2 term equivilant to fuv^4 as seen from eq (7) in [2]
    t1 = f_spat.^4;
    % calculate f(u,0)^2 * f(0,v)^2 term as (f_mn(:,1).^2.*f_mn(1,:).^2)
    t2 = (f_spat(:,1).^2).*(f_spat(1,:).^2);
    
    % combine terms to calculate frequency sensitivity function as in [1],
    % which gives a modified version of the log-based expression from eq 3
    % in [3], and avoids calculation of angle from eq 5 in [3]
    T = ((T_min*t1)./(C_uv.*(t1-4*(1-Eta)*t2))).*(10.^(K*(log10(f_spat)-log10(f_min*ones(8))).^2));
    T(1) =  min(T(1,2),T(2,1));
%     figure, surf(T)
%     zlabel('Threshold');
%     ylabel('J-Freq');
%     xlabel('I-Freq');
%     xticks(0:7), yticks(0:7)
%     title('Levicky and Peterson JND ')
%     set(gca,'fontsize',16)
        
end