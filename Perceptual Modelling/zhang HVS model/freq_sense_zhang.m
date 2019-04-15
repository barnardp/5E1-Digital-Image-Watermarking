
% Implementation of Zhang's CSF model as outlined in :
% "spatial jnd profile for image in dct domain"

function T_basic = freq_sense_zhang()

  % implement base threshold as given in eq 8:
    a = 1.33; b = 0.11; c = 0.18; r = 0.6; s = 0.25; 
    % dct normalization factor, calculated using eq 7
    dct_norm = repmat([(sqrt(1/8)) sqrt(2/8)*ones(1,7)],8,1).*repmat([(sqrt(1/8)) sqrt(2/8)*ones(1,7)],8,1)';
    % spatial frequency, calculated using eq 5,6,7
    Wx = 7.1527/256;            % pixels/degree horizontal height of pixel
    Wy = 7.1527/256;            % pixels/degree vertical height of pixel
    spatial_freq = (1/16)*sqrt(repmat(((0:7)/Wx).^2,8,1)' + repmat(((0:7)/Wy).^2,8,1) );
    % directional angle, calculated using eq 10
    dir_angle = asin((2*spatial_freq(:,1).*spatial_freq(1,:))./spatial_freq.^2);
    % base threshold, calculated using eq 10
    base_threshold = (1./dct_norm).*((exp(c*spatial_freq)./(a + b*spatial_freq))./...
                     (r + (1-r)*cos(dir_angle).^2));
    T_basic = s*base_threshold;
    T_basic(1,1) = min(T_basic(1,2),T_basic(2,1));
%     figure, surf(T_basic),zlabel('Threshold'),ylabel('v-direction'),xlabel('u-direction'),set(gca,'fontsize',16)
%     xticks(0:7), yticks(0:7);
%     title('Zhangs CSF')
    
end
