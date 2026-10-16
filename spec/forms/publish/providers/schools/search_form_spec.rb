# frozen_string_literal: true

require "rails_helper"

module Publish
  module Providers
    module Schools
      describe SearchForm, type: :model do
        subject { described_class.new }

        it { is_expected.to validate_presence_of(:query).on(:query) }

        it { is_expected.to validate_length_of(:query).on(:query).is_at_least(2) }

        describe "choosing a school" do
          let(:provider) { create(:provider) }
          let(:gias_school) { create(:gias_school) }

          it "is valid for a school the provider does not have" do
            expect(described_class.new(school: gias_school, provider:)).to be_valid(:school)
          end

          it "is invalid for a school the provider already has, even with no legacy site" do
            create(:provider_school, provider:, gias_school:)
            form = described_class.new(school: gias_school, provider:)

            expect(form).not_to be_valid(:school)
            expect(form.errors[:query]).to include("This school has already been added")
          end
        end
      end
    end
  end
end
