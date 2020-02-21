function [has_key, value, CACHE] = cached_cache_getbykey(CACHE, key) %#codegen
% returns item indexed by a given key

items = CACHE.items;
hash = cached_cache_hashkey(key);
for i = 1:CACHE.n_items
    % first check the key hash - fast
    if CACHE.hashes(i)==hash
        % now check if the key matches
        if isequal(items(i).key, key)
            % if so, get the item
            value = items(i).value;
            has_key = true;
            % update cache info
            switch CACHE.cache_type
                case {1, 2}
                    % least/most frequently used - update hits
                    CACHE.hits(i) = CACHE.hits(i)+1;
                case {3, 4}
                    % least/most recently used - update age and time
                    CACHE.ages(i) = CACHE.time;
                    CACHE.time = CACHE.time+1;
            end
            return
        end
    end
end
has_key = false;
value = items(1).value;

end
