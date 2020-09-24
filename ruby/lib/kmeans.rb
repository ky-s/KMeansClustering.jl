require 'matrix' # using Vector

module KMeans
  def clustering(original_points, nclusters, count_threashold = 5_000)
    points = original_points.map { |original_point| Point.elements(original_point, false) }

    points.each { |point| point.cluster_id = rand(1 .. nclusters) }

    continue = true, count = 0

    until continue
      continue = false

      points.group_by(&:cluster_id).each do |cluster_id, cluster_points|

        center = compute_center(cluster_points)

        nearest_point, _distance = cluster_points
          .map    { |point| [point, euclidean_distance(point, center)] }
          .min_by { |_, distance| distance }

        if nearest_point.cluster_id != cluster_id
          nearest_point.cluster_id = cluster_id
          continue = true
        end
      end

      count += 1
      count >= count_threashold and break
    end

    points.group_by(&:cluster_id).values
  end

  module_function :clustering

  private

  def euclidean_distance(point1, point2)
    Math.sqrt( (point1 - point2).map { |n| n ** 2 }.sum )
  end

  def compute_center(points)
    points.reduce(&:+) / points.size.to_r
  end

  class Point < Vector
    attr_accessor :cluster_id
  end
end
