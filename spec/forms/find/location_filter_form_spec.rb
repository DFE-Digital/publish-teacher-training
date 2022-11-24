# frozen_string_literal: true

require "rails_helper"

module Find
  describe LocationFilterForm, type: :model do
    subject { described_class.new(params) }

    describe "validations" do
      before { subject.valid? }

      context "no option selected" do
        let(:params) { { l: nil } }

        it "validates selected options" do
          expect(subject.errors).to include("Select an option to find courses")
        end
      end

      context "location is by_city_town_postcode" do
        context "query is blank" do
          let(:params) do
            {
              l: "1",
              lq: "",
            }
          end

          it "validates find_courses" do
            expect(subject.errors).to include("Enter a city, town or postcode")
          end
        end
      end

      context "location is by_school_uni_or_provider" do
        context "query is blank" do
          let(:params) do
            {
              l: "3",
              "provider.provider_name" => "",
            }
          end

          it "validates find_courses" do
            expect(subject.errors).to include("Enter a school, university or other training provider")
          end
        end
      end
    end
  end
end
