# k平均法の実装
#
# ===
# import KMeansClusterings
#
# points = [ (1,0), (0,1), ... ]
# KMeansClusterings.clustering(points, 3)
#
module KMeansClusterings

export clustering

# 内部データ
mutable struct KMeansData
    point     :: Tuple
    clusterid :: Int
end

# ユークリッド距離
#   2点間の直線距離を算出して返却します。
euclidean_distance(point1::Tuple, point2::Tuple) =
    foldl(+, (point2 .- point1).^2) |> sqrt
euclidean_distance(data1::KMeansData, data2::KMeansData) =
    euclidean_distance(data1.point, data2.point)

# 重心を計算する
compute_center(points::AbstractArray) = .+(points...) ./ length(points)
compute_center(datalist::AbstractArray{KMeansData}) =
    map(data -> data.point, datalist) |> compute_center

# 最近傍点を探します。
# (data, distance, index) の3値を返却します。
function find_nearest_neighbor(datalist::AbstractArray{KMeansData}, center::Tuple)
    distances = map(data -> euclidean_distance(data.point, center), datalist)
    distance, index = findmin(distances)

    datalist[index], distance, index
end

# 対象のクラスタに属するものだけを抽出して返却します。
filter_by_cluster(datalist::AbstractArray{KMeansData}, clusterid::Integer) =
    filter(data -> data.clusterid == clusterid, datalist)

# KMeansData の配列を、クラスタ順の配列の配列に変換します。
# KMeansData は内部操作用のデータ型なので、隠蔽します。
function to_cluster_list(datalist::AbstractArray{KMeansData}, nclusters::Integer)
    map(1:nclusters) do clusterid
        clusterdatalist = filter_by_cluster(datalist, clusterid)

        map(data -> data.point, clusterdatalist)
    end
end

# ランダムでクラスタ ID を作成する
generate_clusterid(nclusters::Integer) = rand(1:nclusters)

"""
clustering(points, nclusters, distance_threashold = nclusters, count_threashold = 5_000)

do K-means clustering.

e.g.
===
```julia
points = [ (0,0), (1,0), (1,1), (0,1),.. ]
cluster1, cluster2, cluster3 = clustering(points, 3)
```
"""
# クラスタリングを行います。メイン機能です。
function clustering(
    points              :: AbstractArray, # AbstractArray{Tuple, 1},
    nclusters           :: Integer,
    distance_threashold :: Real = 0.0,
    count_threashold    :: Integer = 5_000,  # 無限ループ回避
)

    # ランダムで cluster を割り当てる. KMeansData に変換もする
    datalist = map(point -> KMeansData(point, generate_clusterid(nclusters)), points)

    continues = true
    count = 0

    while continues && count < count_threashold
        continues = false

        for clusterid in 1:nclusters
            clusterdatalist = filter_by_cluster(datalist, clusterid)
            isempty(clusterdatalist) && continue

            # クラスターの重心を求める
            center = compute_center(clusterdatalist)

            nearest_data, distance, _ = find_nearest_neighbor(datalist, center)

            # クラスターの重心と近傍点の距離がしきい値を超えていて、
            # かつ近傍点のクラスターが異なっていたら、今のクラスターに移動します。
            # これが行われたら、次回も試行します。
            #
            if distance >= distance_threashold && nearest_data.clusterid != clusterid
                nearest_data.clusterid = clusterid
                continues = true
            end
        end

        count += 1
    end

    to_cluster_list(datalist, nclusters)
end

end # module
