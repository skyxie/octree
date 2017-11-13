
require 'octree'

RSpec.describe Octree do
  describe 'nearest' do
    let(:points) do
      [
        [219.740502,0.003449,4.177065],
        [45.210918,0.003365,-16.008996],
        [344.552785,0.030213,277.614965],
        [82.835513,0.012476,-105.61954],
        [195.714261,0.034068,-167.695291],
        [54.905296,0.017912,3.787796],
        [54.367897,0.020886,19.827115],
        [180.654532,0.086213,87.668389]
      ]
    end

    let(:octree) { Octree.new(points) }
    let(:sol) { [5.0e-06,0.0,0.0] }

    xit 'should find k closest locations to sol' do
      expect(octree.nearest(3, sol)).to eql([
        [54.367897,0.020886,19.827115],
        [54.905296,0.017912,3.787796],
        [45.210918,0.003365,-16.008996]
      ])
    end
  end

  describe 'octant' do
    it 'should work as a class method' do
      expect(Octree.octant([0,0,0], [0,0,0])).to eql(0)
      expect(Octree.octant([0,0,0], [1,0,0])).to eql(1)
      expect(Octree.octant([0,0,0], [0,1,0])).to eql(2)
      expect(Octree.octant([0,0,0], [1,1,0])).to eql(3)
      expect(Octree.octant([0,0,0], [0,0,1])).to eql(4)
      expect(Octree.octant([0,0,0], [1,0,1])).to eql(5)
      expect(Octree.octant([0,0,0], [0,1,1])).to eql(6)
      expect(Octree.octant([0,0,0], [1,1,1])).to eql(7)
    end

    it 'should be binary and work the same for higher magnitudes' do
      expect(Octree.octant([0,0,0], [-15,-12,0])).to eql(0)
      expect(Octree.octant([0,0,0], [1,-22,0])).to eql(1)
      expect(Octree.octant([0,0,0], [0,12,-1])).to eql(2)
      expect(Octree.octant([0,0,0], [1,2,-231])).to eql(3)
      expect(Octree.octant([0,0,0], [-0.1,-0.3,400])).to eql(4)
      expect(Octree.octant([0,0,0], [0.1,-23,0.2])).to eql(5)
      expect(Octree.octant([0,0,0], [-0.21,0.05,0.005])).to eql(6)
      expect(Octree.octant([0,0,0], [0.3, 0.45, 100])).to eql(7)
    end

    it 'should work as an instance method' do
      octree = Octree.new([
        [1, 1, 0],
        [-1, -1, 0],
        [0, 1, 1],
        [0, -1, -1],
      ])

      expect(octree).to be_leaf
      expect(octree.center).to eql([0, 0, 0])
      expect(octree.octant([0,0,0])).to eql(0)
      expect(octree.octant([1,0,0])).to eql(1)
      expect(octree.octant([0,1,0])).to eql(2)
      expect(octree.octant([1,1,0])).to eql(3)
      expect(octree.octant([0,0,1])).to eql(4)
      expect(octree.octant([1,0,1])).to eql(5)
      expect(octree.octant([0,1,1])).to eql(6)
      expect(octree.octant([1,1,1])).to eql(7)
    end
  end
end
