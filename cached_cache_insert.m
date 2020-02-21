function CACHE = cached_cache_insert(CACHE, key, value) %#codegen
% inserts a new key/value pair to the chache

i = double(CACHE.n_items);
if i < CACHE.max_items
    cache_entry = i+1;
    CACHE.n_items = uint32(i+1);
else
    % select index of item to be replaced
    switch CACHE.cache_type
        case 1
            % least frequently used
            [~, cache_entry] = min(CACHE.hits);
        case 2
            % most frequently used
            [~, cache_entry] = max(CACHE.hits);
        case 3
            % least recently used
            [~, cache_entry] = min(CACHE.ages);
        case 4
            % most recently used
            [~, cache_entry] = max(CACHE.ages);
        case 5
            % random replacement
            cache_entry = ceil(rand(1)*double(CACHE.max_items));
        case 6
            % first in first out
            cache_entry = double(CACHE.fifo_head);
        case 7
            % last in first out
            cache_entry = double(CACHE.max_items);
        case 8
            % smallest cardinality
            [~, cache_entry] = min(CACHE.cardinalities);
        case 9
            % largest cardinality
            [~, cache_entry] = max(CACHE.cardinalities);
        otherwise
            cache_entry = 1;
    end
end
% replace the otem
CACHE.items(cache_entry).key = key;
CACHE.items(cache_entry).value = value;
CACHE.hashes(cache_entry) = cached_cache_hashkey(key);

% update cache info
switch CACHE.cache_type
    case 6
        % first in first out - updated fifo_head
        if CACHE.fifo_head==CACHE.max_items
            CACHE.fifo_head = uint32(1);
        else
            CACHE.fifo_head = CACHE.fifo_head + 1;
        end
    case {8, 9}
        % record cardinality
        CACHE.cardinalities(cache_entry) = value.cardinality;
end

end
