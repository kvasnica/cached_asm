function [u, W, iters, reused, factored, CACHE] = cached_asm(Hinv, HinvFT, Ain, bin, theta, W, CACHE) %#codegen
% primal active set method with caching

% verbose = true;
nu = size(Ain, 2);
nx = length(theta);
% bk = 2.^(1:nc);


% one_at_a_time = false; % only add one constraint at a time
MaxIterations = 1000;
ZeroTolerance = 1e-10;
SmallTolerance = 1e-6;
reused = 0;
factored = 0;

% phase 1: determine initial feasible solution
Aidx = find(W);
u = Ain(Aidx, :)\bin(Aidx, :);
Inu = eye(nu);

% Phase 2: build active set
for iters = 1:MaxIterations
    
    % QP with update:
    %   min  1/2*(u+du)'*Q*(u+du) + c'*(u+du)
    %   s.t. A_W*(u+du) = b_W
    Aidx = find(W)';
    Z1 = zeros(nu);
    Z2 = zeros(nu, nx);
    if isempty(Aidx)
        % no active constraints -> use inverted hessian
        factors.Dual = [Z1, Z2];
        factors.Primal = [-Inu, -HinvFT];
        factors.cardinality = 0;
    else
        % active constraints -> use cache
        key = zeros(1, nu);
        key(1:length(Aidx)) = Aidx;
        [in_cache, factors, CACHE] = cached_cache_getbykey(CACHE, key);
        if in_cache
            reused = reused+1;
        else
            % compute new factors and cache them
            G_A = Ain(Aidx, :);
            HinvGt = Hinv*G_A';
            M = inv(G_A*HinvGt);
            %factors.L1 = -M*G_A;
            %factors.L2 = -M*G_A*Hinv*F';
            %factors.D1 = -(Hinv*G_A'*factors.L1 + eye(nu));
            %factors.D2 = -Hinv*(G_A'*factors.L2+F');
            nA = nnz(W);
            M1 = -M*G_A;
            NM = -HinvGt*M1;
            D = NM-Inu;
            Z1(1:nA, :) = M1;
            Z2(1:nA, :) = M1*HinvFT;
            factors.Dual = [Z1, Z2];
            factors.Primal = [D, D*HinvFT];
            factors.cardinality = length(Aidx);
            CACHE = cached_cache_insert(CACHE, key, factors);
            factored = factored+1;
        end
    end
    u_theta = [u; theta];
    du = factors.Primal*u_theta;
    if norm(du) < SmallTolerance
        L = factors.Dual*u_theta;
        if all(L > -ZeroTolerance)
            % primal-dual feasible and optimal
            return
        else
            % remove the constraint associated to the smallest (negative)
            % Lagrange multilplier
            [~, to_remove_idx] = min(L);
            W(Aidx(to_remove_idx)) = false;
        end
        
    else
        % compute step length and identify the constraint which will become
        % active
        NAidx2 = find(~W);
        dens = Ain(NAidx2, :)*du;
        idx = dens>ZeroTolerance;
        NAidx = NAidx2(idx);
        nums = bin(NAidx)-Ain(NAidx, :)*u;
        alphas = nums./dens(idx);
        [min_alpha, min_alpha_idx] = min(alphas);
        if min_alpha>1
            % unit step length, no constraint will be activated
            alpha = 1;
        else
            to_add = NAidx(min_alpha_idx);
            W(to_add) = true;
            alpha = min_alpha;
        end
        un = u + alpha*du;
        u = un;
    end
end
u = NaN(nu, 1);

end
