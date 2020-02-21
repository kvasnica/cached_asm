function [I, F, R, CACHE, x0] = cached_sim_multi(CACHE_TYPE, MAX_ITEMS, FB_WARMSTART) %#codegen

data = load('data_cache');
A = data.sysStruct.A;
B = data.sysStruct.B;
M = data.M;
X0 = data.X0;
Nsim = data.Nsim;

% MAX_ITEMS = 500;
% CACHE_TYPE = 1; % least frequently used
% CACHE_TYPE = 2; % most frequenty used
% CACHE_TYPE = 3; % least recently used
% CACHE_TYPE = 4; % most recently used
% CACHE_TYPE = 5; % random replacement
% CACHE_TYPE = 6; % first in first out
% CACHE_TYPE = 7; % last in first out
% CACHE_TYPE = 8; % smallest cardinality
% CACHE_TYPE = 9; % largest cardinality
CACHE = cached_cache_new(MAX_ITEMS, M, CACHE_TYPE);
Hinv = inv(M.H);
HinvFT = Hinv*M.F';
Ain = M.G;

I = 0;
R = 0;
F = 0;

for i = 1:size(X0, 1)
    x0 = X0(i, :)';
    W0 = false(length(M.W), 1);
    for k = 1:Nsim
        % start timing 2
        bin = M.W+M.E*x0;
        [U, Wn, it, r, f, CACHE] = cached_asm(Hinv, HinvFT, Ain, bin, x0, W0, CACHE);
        if FB_WARMSTART
            % reuse the previous active set
            W0 = Wn;
        end
        % end timing 2
        % print [k, it, time2]
        I = I+it;
        R = R+r;
        F = F+f;
        u = U(1);
        xn = A*x0 + B*u;
        x0 = xn;
    end
end

end
