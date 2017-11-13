
require 'priority_queue'

class Octree
  def initialize points, depth=0
    @depth = depth
    @center = Octree.center(points)
    @size = points.size

    branch_points = 8.times.map { [] }
    points.each { |pt| branch_points[octant(pt)] << pt }

    if points.size <= 4
      # Assuming all points are distinct (no 2 points are the same)
      # and there are at most 4 points, then there is at most 1 point in each
      # octant from the center point
      @leaf = true
      @branches = branch_points
    else
      @leaf = false
      @branches = branch_points.reject(&:empty?).map { |pts| Octree.new(pts, depth+1) }
    end
  end

  attr_reader :size, :center, :depth

  def empty?
    @size == 0
  end

  def leaf?
    @leaf
  end

  # Recursively finds the k nearest points to pt
  # WARNING: Not quite working right now
  def nearest k, pt, acc_nearest=nil
    if acc_nearest.nil?
      acc_nearest = PriorityQueue.new(k) do |x|
        pt.zip(x).reduce(0) do |dist, (a, b)|
          dist + (a - b) ** 2
        end
      end
    end

    if leaf?
      @branches.reject(&:empty?).each do |pts|
        pts.each do |pt|
          acc_nearest.add pt
        end
      end
    else
      # Search matching index
      pt_octant = octant pt
      closest_branch = @branches[pt_octant]
      if !closest_branch.empty?
        closest_branch.nearest k, pt, acc_nearest
      end

      # If the index sufficients fulfilled requesnt, then there is nothing left
      # to do, otherwise, search other octants
      if !acc_nearest.full?
        # Attempt to find alternative closest results at this branch
        @branches.each.with_index do |branch, i|
          next if branch.empty? || i == pt_octant
          branch.nearest k, pt, acc_nearest
        end
      end
    end

    acc_nearest.items
  end

  def octant pt
    Octree.octant(@center, pt)
  end

  # Calculate the center of an array of points
  def self.center points
    points.reduce([0, 0, 0]) do |acc, pt|
      acc.zip(pt).map do |a, b|
        a + b
      end
    end.map do |coor|
      coor / points.size
    end
  end

  #
  # Returns which octant 0-7 point b belongs to relative to point a
  # This mapping is done using binary arithmetic with the following rules:
  # * x, y, z dimension corresponds to 0th, 1st, 2nd powers of 2 respectively
  # * Along each dimension, if that value for b is less than or equal to that
  #   value for a, that dimension receives a 0 value, otherwise a 1 value
  # * Sum up values for each dimension to get the octant value
  #
  def self.octant a, b
    a.zip(b).each.with_index.reduce(0) do |octant, (pair, i)|
      octant + (pair[0] < pair[1] ? 1 : 0) * 2 ** i
    end
  end
end
