# Load all relevant packages
using Pkg
Pkg.activate(".")
Pkg.instantiate()
using CPLEX, CSV, DataFrames, Distributed, OffsetArrays, Random, Statistics
nworkers() == 4 || addprocs(4, exeflags="--project") 
@everywhere using BLOPimpute, CPLEX

# Simulate a sample of size N from the DGP determined by (d, l, σ)
function simulate_sample(N, d, l, σ)
    K = [2, 4, 6, 10, 2]
    X = -log.(Random.rand(K[d], N)) # re-evaluate
    y = σ * Random.randn(N)
    for j ∈ 1:K[d]
        @. y += X[j, :] * (-1)^(j - 1)
    end
    d == 5 && @. y += X[1, :]^2 - X[2, :]^2 - X[1, :] * X[2, :]
    P = @. 0.7 / (1 + exp(1 + 1.1X[1, :] - 0.8X[2, :])) + l / 10
    M = Random.rand(N) .>= P
    X = [X[:, M .== h] for h = 0:1] |> x -> OffsetArrays.OffsetVector(x, 0:1)
    y = [y[M .== h]    for h = 0:1] |> x -> OffsetArrays.OffsetVector(x, 0:1)
    return y, X
end

# Generate a imputation problem from a sample
function generate_model(sample)
    y, X = sample
    return BLOPimpute.Model(; y = y, X = X, optimizer = CPLEX.Optimizer)
end

# Compute all combinations of the form θ = (N, d, l, σ, r), r => sample id
Ns = [1, 2] * 1000;
ls = [0.5, 1, 2, 3];
σs = [1, √2];
rs = 1:10
ds = 1:5;
θs = collect(Iterators.product(Ns, ds, ls, σs, rs))[:];

# Set a seed
Random.seed!(1);

# For each θ, ...
samples = [simulate_sample(x[1:4]...) for x ∈ θs]; # create a sample
models  = [generate_model(x) for x ∈ samples];     # create a model
means   = [mean(x[1][0])     for x ∈ samples];     # compute the sample mean

# Impute ȳ for each variant, for a given sample and `S`
@everywhere function foo(model, Smax)
    ŷb = zeros(Smax)
    for S ∈ (size(model.X[1], 1) + 1):Smax
        try
            model.S̄[1] = S
            ŷb[S] = mean(impute!(model))
        catch
            ŷb[S] = Inf
        end
    end
    return ŷb
end
pmap(model -> foo(model, 11), models[1:2]); # for jit compilation

# XXX
Smax = 50
ŷbs = pmap(model -> foo(model, Smax), models);

# Save the results
df = 
    DataFrame((θs[i]..., means[i], ŷbs[i]...) for i ∈ 1:length(θs)) |>
    x -> rename!(x, [:N, :d, :l, :o, :r, :target, Symbol.(1:Smax)...]) |>
    x -> stack(x, 7:(6 + Smax), value_name = :estimate, variable_name = :S)
CSV.write("data/exp-01.csv", df)
