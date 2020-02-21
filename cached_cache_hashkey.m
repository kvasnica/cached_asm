function hash = cached_cache_hashkey(key)

% hash = uint32(key(1)*key(2)+bitxor(key(1), key(2))+sum(key)+1);
sum1 = uint32(0);
sum2 = uint32(0);
for i = 1:length(key)
    sum1 = mod(sum1+key(i), 255);
    sum2 = mod(sum1+sum2, 255);
end
hash = uint32(bitor(bitshift(sum2, 8), sum1));

end
