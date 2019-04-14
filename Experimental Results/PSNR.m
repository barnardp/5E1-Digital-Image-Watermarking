% function to compute PSNR
function out = PSNR(A,ref)
[M,N] = size(ref);
out = 10*log10(M*N*(255^2)/sum(sum((uint8(ref)-uint8(A)).^2)));
end
