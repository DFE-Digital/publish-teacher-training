# frozen_string_literal: true

require "rails_helper"

module Find
  describe AgeGroupsForm do
    describe "validation" do
      subject { described_class.new(**args) }
      let(:args) { { params: } }

      context "when no option is selected" do
        let(:params) { {} }

        it "is not valid" do
          expect(subject.valid?).to be(false)
          expect(subject.errors[:age_group]).to include("Select an age group")
        end
      end

      context "when selected option is not one of the accepted age groups" do
        let(:params) { { age_group: "foo" } }

        it "is not valid" do
          expect(subject.valid?).to be(false)
        end
      end

      shared_examples "valid option" do |age_group|
        context "when option selected is #{age_group}" do
          let(:params) { { age_group: } }

          it "is valid" do
            expect(subject.valid?).to be(true)
          end
        end
      end

      include_examples "valid option", "primary"
      include_examples "valid option", "secondary"
      include_examples "valid option", "further_education"
    end
  end
end
