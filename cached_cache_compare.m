% codegen cached_sim_multi -args {1, 100, true}

% cache sizes (max number of stored items)
cs = [10:10:100 120:20:200 250:50:500];
% use warmstart or not (start next active set method from the optimal
% active set from the previous step)
fb_warmstart = true;

% cache type:
% 1: least frequently used
% 2: most frequently used
% 3: least recently used
% 4: most recently used
% 5: random replacement
% 6: first in first out (FIFO)
% 7: last in first out (LIFO)
% 8: smallest cardinality
% 9: largest cardinality

RES = {};
for cache_type = 1:9
    res = [];
    for cache_size = cs
        fprintf('type: %d, size: %d\n', cache_type, cache_size);
        tic; 
        [I,F,R,C]=cached_sim_multi_mex(cache_type, cache_size, fb_warmstart); 
        t=toc;
        eff = sum(F)/(sum(R)+sum(F))*100;
        res = [res; cache_type cache_size eff t sum(I) sum(F) sum(R)];
    end
    RES{cache_type} = res;
end
if fb_warmstart
    save compare_data_fb_true RES
else
    save compare_data_fb_false RES
end

% close all 
figure
hold on
markers = 'ox+s*<v>^hp';
for i = 1:length(RES)
    if ~isempty(RES{i})
        plot(cs, RES{i}(:, 3), 'marker', markers(i), 'markersize', 12);
    end
end
ax=axis;
xlabel('Cache size'); ylabel('Miss rate percent');
h=legend({'LFU', 'MFU', 'LRU', 'MRU', 'RR', 'FIFO', 'LIFO', 'SC', 'LC'}, 'location', 'northeast');
set(gca, 'fontsize', 14);
set(h, 'fontsize', 14);
grid on
