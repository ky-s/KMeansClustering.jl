require_relative 'lib/kmeans'

npoints = 10_000
dims = 3

points = npoints.times.map do
  dims.times.map { rand(-100.0..100.0) }
end

cl1, cl2, cl3, cl4, cl5 = KMeans.clustering(points, 5)

p cl1
p cl2
p cl3
p cl4
p cl5


