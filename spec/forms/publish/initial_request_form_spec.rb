# frozen_string_literal: true

require "rails_helper"

module Publish
  RSpec.describe InitialRequestForm do
    describe "validations" do
      context "when no radio button selected" do
        it "returns an error" do
          subject.valid?
          expect(subject.errors[:training_provider_code]).to be_present
        end
      end

      context "when no search query provided" do
        subject do
          described_class.new(training_provider_code: "-1")
        end

        it "returns an error" do
          subject.valid?
          expect(subject.errors[:training_provider_query]).to be_present
        end
      end

      context "when search query contains only one character" do
        subject do
          described_class.new(training_provider_code: "-1", training_provider_query: "x")
        end

        it "returns an error" do
          subject.valid?
          expect(subject.errors[:training_provider_query]).to be_present
        end
      end

      context "when search query contains more than one character" do
        subject do
          described_class.new(training_provider_code: "-1", training_provider_query: "ox")
        end

        it "is valid" do
          expect(subject.valid?).to be(true)
        end
      end

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

      context "when all valid parameters are passed in" do
        subject do
          described_class.new(training_provider_code: "-1", training_provider_query: "ox", number_of_places: "2")
        end

        it "is valid" do
          expect(subject.valid?).to be(true)
        end
      end
    end
  end
end
