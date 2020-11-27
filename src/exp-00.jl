# Load all relevant packages
using Pkg
Pkg.activate(".")
Pkg.instantiate()
using BenchmarkTools, BLOPimpute, CPLEX, CSV, DataFrames
using OffsetArrays, Random, Statistics
1+1
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

# Simulate a sample from the most complex variant
Random.seed!(1);
y, X = simulate_sample(2000, 4, 0.5, 1.0);

# Perform a first imputation (just for jit purposes)
m = Model(; y = y, X = X, S̄ = [11], optimizer = CPLEX.Optimizer)
impute!(m);

# Estimate the cost of 1 imputation, for selected values of `S`
Svalues = [20, 30, 50, 100, 200, 400, 600, length(y[1])]
Scosts = zeros(Float64, length(Svalues))
for (index, value) ∈ enumerate(Svalues)
    m.S̄[1] = value
    bmk = @benchmark impute!($m)
    Scosts[index] = Statistics.median(bmk.times) / 1e9
end
df = DataFrames.DataFrame(S = Svalues, cost = Scosts)
CSV.write("data/exp-00.csv", df)
