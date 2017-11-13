
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

    it 'should not be a leaf' do
      expect(octree).to_not be_leaf
    end

    it 'should have center(0,0,0)' do
      expect(octree.center).to_not eql([0,0,0])
    end

    it 'should return expected items' do
      expect(octree.nearest(3, sol).items.reverse).to eql([
        [45.210918,0.003365,-16.008996],
        [54.905296,0.017912,3.787796],
        [54.367897,0.020886,19.827115]
      ])
    end
  end

  2.times.each do |x|
  2.times.each do |y|
  2.times.each do |z|
    octant = x + y*2 + z*4
    point = [x, y, z]

    describe "point=(#{point.join(',')}) octant=#{octant}" do
      it "should map bit_array_to_octant" do
        expect(Octree.bit_array_to_octant(point)).to eql(octant)
      end

      it "should map octant_to_bit_array" do
        expect(Octree.octant_to_bit_array(octant)).to eql(point)
      end

      it "should calculate octant from origin" do
        expect(Octree.octant([0,0,0], point)).to eql(octant)
      end

      it "should use instance to calculate octant from origin" do
        octree = Octree.new([[1, 1, 0], [-1, -1, 0], [0, 1, 1], [0, -1, -1]])
        expect(octree.octant(point)).to eql(octant)
      end
    end
  end
  end
  end

  describe 'octant with higher magnitude points' do
    describe 'class method' do
      subject { Octree.octant([0,0,0], point) }

      describe 'with point (-15,-12,0)' do
        let(:point) { [-15,-12,0] }
        it { is_expected.to eql(0) }
      end

      describe 'with point (-15,-12,0)' do
        let(:point) { [-0.00001,-0.000004,0.0000001] }
        it { is_expected.to eql(4) }
      end
    end

    describe 'with instance' do
      let(:octree) { Octree.new(points) }
      let(:points) { [[1, 1, 0], [-1, -1, 0], [0, 1, 1], [0, -1, -1]] }
      subject { octree.octant(point) }

      it 'should be leaf' do
        expect(octree).to be_leaf
      end

      it 'should have center(0,0,0)' do
        expect(octree.center).to eql([0,0,0])
      end

      describe 'with point (-15,-12,0)' do
        let(:point) { [-15, -12, 0] }
        it { is_expected.to eql(0) }
      end

      describe 'with point (-15,-12,0)' do
        let(:point) { [-0.00001, -0.000004, 0.0000001] }
        it { is_expected.to eql(4) }
      end
    end
  end
end
