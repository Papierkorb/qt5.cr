require "../spec_helper"

describe Qt::Line do
  describe "#p1" do
    context "on a null line" do
      line = Qt::Line.new
      it "returns (0,0)" do
        line.p1.should eq(Qt::Point.new(0, 0))
      end
    end

    context "on a non-null line" do
      line = Qt::Line.new(1, 2, 3, 4)
      it "returns the first point" do
        line.p1.should eq(Qt::Point.new(1, 2))
      end
    end
  end

  describe "#p2" do
    context "on a null line" do
      line = Qt::Line.new
      it "returns (0,0)" do
        line.p2.should eq(Qt::Point.new(0, 0))
      end
    end

    context "on a non-null line" do
      line = Qt::Line.new(1, 2, 3, 4)
      it "returns the second point" do
        line.p2.should eq(Qt::Point.new(3, 4))
      end
    end
  end
end
