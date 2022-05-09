require "rails_helper"

module Publish
  module Allocations
    module EditInitial
      describe NumberOfPlacesForm do
        context "when number_of_places is empty" do
          subject do
            described_class.new(number_of_places: "")
          end

          it "returns an error" do
            subject.valid?
            expect(subject.errors[:number_of_places]).to be_present
          end
        end

        context "when number_of_places is less than 1" do
          subject do
            described_class.new(number_of_places: "0")
          end

          it "returns an error" do
            subject.valid?
            expect(subject.errors[:number_of_places]).to be_present
          end
        end

        context "when number_of_places contains a letter" do
          subject do
            described_class.new(number_of_places: "3a")
          end

          it "returns an error" do
            subject.valid?
            expect(subject.errors[:number_of_places]).to be_present
          end
        end

        context "when number of places is a float" do
          subject do
            described_class.new(number_of_places: "1.1")
          end

          it "returns an error" do
            subject.valid?
            expect(subject.errors[:number_of_places]).to be_present
          end
        end
      end
    end
  end
end
