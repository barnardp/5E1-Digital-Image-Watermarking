% function to compute Abs Reconstruction Error
function out = ARE(A,ref)
[M,N] = size(ref);
out = sum(sum(abs(uint8(ref)-uint8(A))))/(M*N); % sqrt(sum(sum((ref-A).^2)))/sqrt(sum(sum(ref.^2)));
end