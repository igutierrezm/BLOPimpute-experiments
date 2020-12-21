# Load all relevant packages
using Pkg
Pkg.activate(".")
Pkg.instantiate()
Pkg.build("CPLEX")
using CPLEX, CSV, DataFrames, Distributed, OffsetArrays, Random, DataFramesMeta
nworkers() == 8 || addprocs(8, exeflags = "--project")
@everywhere using BLOPimpute, CPLEX, NearestNeighbors

# Simulate a sample of size N from the DGP determined by (d, l, σ)
function simulate_sample(N, d, l, σ)
    K = [2, 4, 6, 10, 2]
    X = Random.rand(K[d], N)
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
    return BLOPimpute.Model(; 
        y = y, 
        X = X, 
        leafsize = size(X[1], 2),
        optimizer = CPLEX.Optimizer
    )
end

# Compute all combinations of the form θ = (N, d, l, σ, r), r => sample id
Ns = [1, 5, 10, 20] * 100;
ls = [0.5, 1, 2, 3];
σs = [1, √2];
rs = 1:400;
ds = 1:5;
θs = collect(Iterators.product(Ns, ds, ls, σs, rs))[:];

# Set a seed
Random.seed!(1);

# For each θ, ...
samples = [simulate_sample(x[1:4]...) for x ∈ θs]; # create a sample
models  = [generate_model(x) for x ∈ samples];     # create a model

# Impute ȳ for each `S` <= `Smax`, given a model (knn)
@everywhere function ȳknn(model, Smax)
    y = model.y
    X = model.X
    ŷb = zeros(Smax)
    K, N0 = size(X[0])
    kdtree = KDTree(X[1]; leafsize = size(X[1], 2))
    for S ∈ K+1:Smax
        for i ∈ 1:N0
            ν = knn(kdtree, X[0][:, i], S)[1]
            y[0][i] = mean(y[1][ν])
        end
        ŷb[S] = mean([y[0]; y[1]])
    end
    return ŷb
end
ȳknn(models[1], 11); # for jit compilation

# Impute ȳ for each `S` <= `Smax`, given a model (blop)
@everywhere function ȳblop(model, Smax)
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
ȳblop(models[1], 11); # for jit compilation

# Run the experiments
Smax = 50;
ȳh = Dict(
    :knn => pmap(model -> ȳknn(model, Smax), models),
    :blop => pmap(model -> ȳblop(model, Smax), models)
);

# Arrange the results as dataframes
df = map([:knn, :blop]) do m
    DataFrame((θs[i]..., m, ȳh[m][i]...) for i ∈ 1:length(θs)) |>
    x -> rename!(x, [:N, :d, :l, :o, :r, :m, Symbol.(1:Smax)...]) |>
    x -> stack(x, 7:(6 + Smax), value_name = :estimate, variable_name = :S) |>
    x -> @linq x |>
    transform(S = levelcode.(:S), target = 0.0) |>
    where(
        ((:d .== 1) .& (:S .>  2)) .|
        ((:d .== 2) .& (:S .>  4)) .|
        ((:d .== 3) .& (:S .>  6)) .|
        ((:d .== 4) .& (:S .> 10)) .|
        ((:d .== 5) .& (:S .>  2))
    )
end;
CSV.write("data/exp-01.csv", vcat(df...))