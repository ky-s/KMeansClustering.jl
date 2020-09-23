include("lib/KMeansClusterings.jl")

points = map(_ -> (rand(-100:0.1:100), rand(-100:0.1:100), rand(-100:0.1:100)), 1:100)
@show points
@show clusters = KMeansClusterings.clustering(points, 5)

for i in eachindex(clusters)
    @show i, clusters[i]
end
