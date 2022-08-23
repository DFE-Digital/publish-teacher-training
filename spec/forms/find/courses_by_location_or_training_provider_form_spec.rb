# frozen_string_literal: true

require "rails_helper"

module Find
  describe CoursesByLocationOrTrainingProviderForm, type: :model do
    subject { described_class.new(params:) }

    describe "validations" do
      before { subject.valid? }

      context "find_course is blank" do
        let(:params) { { find_courses: "" } }

        it "validates find_courses" do
          expect(subject.errors[:find_courses]).to include("Select an option to find courses")
        end
      end

      context "find_course is by_city_town_postcode" do
        context "city_town_postcode_query is blank" do
          let(:params) do
            {
              find_courses: "by_city_town_postcode",
              city_town_postcode_query: "",
            }
          end

          it "validates find_courses" do
            expect(subject.errors[:city_town_postcode_query]).to include("Enter a city, town or postcode")
          end
        end
      end

      context "find_course is by_school_uni_or_provider" do
        context "school_uni_or_provider_query is blank" do
          let(:params) do
            {
              find_courses: "by_school_uni_or_provider",
              city_town_postcode_query: "",
            }
          end

          it "validates find_courses" do
            expect(subject.errors[:school_uni_or_provider_query]).to include("Enter a school, university or other training provider")
          end
        end
      end
    end
  end
end
