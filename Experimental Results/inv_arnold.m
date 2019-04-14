function Y = inv_arnold(A,iter)
    m = size(A,1);
    
    Y = zeros(m);
    
    for n=1:iter
        for y=0:m-1
            for x=0:m-1
                pos = mod([2 -1;-1 1]*[x;y],m)+1;
                Y(pos(2),pos(1)) = A(y+1,x+1);
            end
        end
        A = Y;
    end
end