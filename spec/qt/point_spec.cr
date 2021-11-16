require "../spec_helper"

describe Qt::Point do
  describe "#+" do
    p = Qt::Point.new(1, 2)
    q = Qt::Point.new(3, 4)
    it "returns the sum of the two points" do
      r = p + q
      r.should eq(Qt::Point.new(4, 6))
    end
  end

  describe "#transposed" do
    p = Qt::Point.new(1, 2)
    it "should return a new point with x and y swapped" do
      r = p.transposed
      r.should eq(Qt::Point.new(2, 1))
    end

    it "should not change the point itself" do
      p.should eq(Qt::Point.new(1, 2))
    end
  end
end
