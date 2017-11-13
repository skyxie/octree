
require 'priority_queue'

class Octree
  def initialize points, depth=0
    @depth = depth
    @center = Octree.center(points)
    @size = points.size

    branch_points = 8.times.map { [] }
    points.each { |pt| branch_points[octant(pt)] << pt }

    if size <= 4
      # Assuming all points are distinct (no 2 points are the same)
      # and there are at most 4 points, then there is at most 1 point in each
      # octant from the center point
      @leaf = true
      @branches = branch_points
    else
      @leaf = false
      @branches = branch_points.map do |pts|
        pts.empty? ? [] : Octree.new(pts, depth+1)
      end
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
  def nearest k, pt, acc_nearest=nil
    if acc_nearest.nil?
      acc_nearest = PriorityQueue.new(k) do |x|
        pt.zip(x).reduce(0) do |dist, (a, b)|
          dist + (a - b) ** 2
        end
      end
    end

    if leaf?
      # On a leaf octree, add all points to the priority queue
      @branches.reject(&:empty?).each do |pts|
        pts.each do |pt|
          acc_nearest.add pt
        end
      end
    else
      each_octant(pt) do |octant, dist|
        # If nearest neighbors are insufficient or
        # if neighbors may overlap into another octant,
        # then continue processing octants
        next if acc_nearest.full? && acc_nearest.max_weight < dist
        branch = @branches[octant]
        next if branch.nil? || branch.empty?
        branch.nearest k, pt, acc_nearest
      end
    end

    acc_nearest
  end

  # Finds the correct octant for a point relative to the center
  def octant pt
    Octree.octant(center, pt)
  end

  def each_octant pt
    Octree.each_octant(center, pt) do |octant, dist|
      yield octant, dist
    end
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
    bit_array_to_octant(bit_array(a, b))
  end

  # Indicates the octant for point b relative to a described by an array of bits
  def self.bit_array a, b
    a.zip(b).map { |pair| (pair[0] < pair[1]) ? 1 : 0 }
  end

  # Iterate through each octant around center in order by distance from pt
  def self.each_octant center, pt
    octant_idx = (0..7).to_a # Array of octant numbers
    pt_bit_array = bit_array(center, pt) # Find octant for pt (as bit array)

    octant_idx.map do |octant|
      # Calc distance from point to octant as a projection of point on octant
      # XOR bits to calculate projection vector
      # [0, 1, 0] ^ [1, 1, 0] = [1, 0, 0] Different along x
      # [0, 0, 0] ^ [1, 1, 0] = [1, 1, 0] Different along x and y
      # [1, 1, 0] ^ [1, 1, 0] = [0, 0, 0] Same octant
      # [0, 0, 0] ^ [1, 1, 1] = [1, 1, 1] Opposite, same as distance to center
      # Square distance = projection * (center - point) ** 2
      bit_pairs = octant_to_bit_array(octant).zip(pt_bit_array)
      dist = bit_pairs.each.with_index.reduce(0) do |acc_dist, (bits, i)|
        acc_dist + (bits[0] ^ bits[1]) * (center[i] - pt[i]) ** 2
      end

      [octant, dist]
    end.sort_by do |(octant, dist)|
      dist # Sort octants by distance from pt
    end.each do |(octant, dist)|
      yield octant, dist  # Iterate through each octant
    end
  end

  # Transform an array of bits to an integer
  def self.bit_array_to_octant bits
    bits.each.with_index.reduce(0) do |octant, (bit, i)|
      octant + bit * 2 ** i
    end
  end

  # Transform an integer to a bit array
  def self.octant_to_bit_array octant, pow=2, bits=[0,0,0]
    if octant >= 2 ** pow
      bits[pow] = 1
    end

    if pow > 0
      octant_to_bit_array(octant - bits[pow] * 2 ** pow, pow - 1, bits)
    else
      bits
    end
  end
end
