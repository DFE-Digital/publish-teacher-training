# frozen_string_literal: true

require "rails_helper"

module Find
  module Subjects
    describe PrimaryForm do
      describe "validation" do
        subject { described_class.new(params) }

        context "when no primary subject is selected" do
          let(:params) { { subjects: [] } }

          it "is not valid" do
            expect(subject.valid?).to be(false)
            expect(subject.errors[:subjects]).to include("Select at least one type of primary course")
          end
        end

        context "when subjects are selected" do
          let(:params) { { subjects: %w[01 02] } }

          it "is valid" do
            expect(subject.valid?).to be(true)
          end
        end
      end
    end
  end
end
