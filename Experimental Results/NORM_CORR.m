% compute normalized correlation using equation given by ernawan
function out = NORM_CORR(A,ref)
    if(max(A(:)>0))
        out = (sum(sum(uint8(ref).*uint8(A))))/sqrt(sum(sum(uint8(ref).^2))*sum(sum(uint8(A).^2)));      
    else
        out = 0;
    end
% out = max(max(normxcorr2(ref,A)));
end