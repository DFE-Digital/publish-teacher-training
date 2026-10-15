# frozen_string_literal: true

require "rails_helper"

module Find
  describe DistanceHelper do
    describe "#distance_in_miles" do
      it "says less than 1 mile when the school is under a mile away" do
        expect(distance_in_miles(0)).to eq("less than 1 mile")
        expect(distance_in_miles(0.2)).to eq("less than 1 mile")
      end

      it "says 1 mile when the school is exactly a mile away" do
        expect(distance_in_miles(1)).to eq("1 mile")
      end

      it "rounds up and pluralises a distance of more than a mile" do
        expect(distance_in_miles(1.1)).to eq("2 miles")
        expect(distance_in_miles(4.3)).to eq("5 miles")
      end
    end
  end
end
