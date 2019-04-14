% function to compute Bit Error Rate
function out = BER(A,ref)
    bermap = xor(uint8(A),uint8(ref)); %  A ~= ref
    out = sum(bermap(:))/numel(A);
end
