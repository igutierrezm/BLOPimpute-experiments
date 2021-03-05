# Load all relevant packages
using Pkg; Pkg.activate(".")
using CPLEX, CSV, DataFrames, Distributed, OffsetArrays, Random, DataFramesMeta
nworkers() == 8 || addprocs(8, exeflags = "--project")
@everywhere using BLOPimpute, CPLEX, NearestNeighbors

# Simulate a sample of size N from the DGP determined by (d, l, σ)
function simulate_sample(N, d, l, σ)
    K = [2, 6, 10, 2]
    X = Random.randn(K[d], N)
    y = σ * Random.randn(N)
    for j ∈ 1:K[d]
        @. y += X[j, :] * (-1)^(j - 1)
    end
    d == 4 && @. y += X[1, :]^2 - X[2, :]^2 - X[1, :] * X[2, :]
    P = @. 0.7 / (1 + exp(1 + 1.1X[1, :] - 0.8X[2, :])) + l / 10
    M = Random.rand(N) .>= P
    X = [X[:, M .== h] for h = 0:1] |> x -> OffsetArrays.OffsetVector(x, 0:1)
    y = [y[M .== h]    for h = 0:1] |> x -> OffsetArrays.OffsetVector(x, 0:1)
    return y, X
end

# Generate a imputation problem from a sample
function generate_model(sample)
    y, X = sample
    return BLOPimpute.Model(; 
        y = y, 
        X = X, 
        leafsize = size(X[1], 2),
        optimizer = CPLEX.Optimizer
    )
end

# Compute all combinations of the form θ = (N, d, l, σ, r), r => sample id
Ns = [5] * 100;
ls = [3, 7] / 4;
σs = [1, √2];
rs = 1:100;
ds = 1:4;
θs = collect(Iterators.product(Ns, ds, ls, σs, rs))[:];

# Set a seed
Random.seed!(1);

# For each θ, ...
samples = [simulate_sample(x[1:4]...) for x ∈ θs]; # create a sample
models  = [generate_model(x) for x ∈ samples];     # create a model

# Impute ȳ for each `S` <= `Smax`, given a model (blop)
scorefun(x, y) = sum((x - y).^2)
@everywhere function ȳblopS(model)
    ŷb = 0.0
    try
        model.S̄[1] = select_s_naive(model, 20 .* (1:5), scorefun; nruns = 10)
        ŷb = mean(impute!(model))
    catch
        ŷb = Inf
    end
    return ŷb
end
ȳblopS(models[1]) # for jit compilation

# Impute ȳ for each `S` <= `Smax`, given a model (blop)
@everywhere function ȳblopN(model)
    ŷb = 0.0
    try
        model.S̄[1] = size(model.X[1], 2)
        ŷb = mean(impute!(model))
    catch
        ŷb = Inf
    end
    return ŷb
end
ȳblopN(models[1]) # for jit compilation

# Run the experiments
ȳh = Dict(
    :knn => pmap(model -> ȳknnS(model), models),
    :blop => pmap(model -> ȳblopN(model), models)
);

# Arrange the results as dataframes
df = map([:knn, :blop]) do m
    DataFrame((θs[i]..., m, ȳh[m][i]...) for i ∈ 1:length(θs)) |>
    x -> rename!(x, [:N, :d, :l, :o, :r, :m, Symbol.(1:Smax)...]) |>
    x -> stack(x, 7:(6 + Smax), value_name = :estimate, variable_name = :S) |>
    x -> @linq x |>
    transform(S = parse.(Ref(Int), :S), target = 0.0) |>
    where(
        ((:d .== 1) .& (:S .>  2)) .|
        ((:d .== 2) .& (:S .>  6)) .|
        ((:d .== 3) .& (:S .> 10)) .|
        ((:d .== 4) .& (:S .>  2))
    )
end;
CSV.write("data/exp-01.csv", vcat(df...))

# for l ∈ ls
#     y, x = simulate_sample(1000000, 1, l, 1)
#     println(length(y[0]) / sum(length.(y)))
# end

# Try this (later)
# df = DataFrame(a = [0, 0, 1, 1], b = [2, 4, 0, 1])
# filter(df) do row 
#     row.a > 0 && row.b >= 2
# end
