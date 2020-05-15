# == Schema Information
#
# Table name: allocation
#
#  accredited_body_code :text
#  accredited_body_id   :bigint
#  created_at           :datetime         not null
#  id                   :bigint           not null, primary key
#  number_of_places     :integer
#  provider_code        :text
#  provider_id          :bigint
#  recruitment_cycle_id :integer
#  request_type         :integer          default("initial")
#  updated_at           :datetime         not null
#
# Indexes
#
#  index_allocation_on_accredited_body_id  (accredited_body_id)
#  index_allocation_on_provider_id         (provider_id)
#  index_allocation_on_request_type        (request_type)
#
require "rails_helper"

RSpec.describe Allocation do
  describe "validations" do
    before do
      subject.valid?
    end

    it "requires accredited_body" do
      expect(subject.errors["accredited_body"]).to include("can't be blank")
    end

    it "requires provider" do
      expect(subject.errors["provider"]).to include("can't be blank")
    end

    it "requires the accredited_body to be an accredited_body" do
      subject.accredited_body = create(:provider)
      subject.valid?
      expect(subject.errors["accredited_body"]).to include("must be an accredited body")
    end

    it "required number_of_places to be a number" do
      subject.number_of_places = "dave"
      subject.valid?
      expect(subject.errors["number_of_places"]).to include("is not a number")
    end
  end

  describe "number_of_places" do
    subject { create(:allocation, number_of_places: nil, request_type: request_type).number_of_places }

    context "when request type is initial (default)" do
      context "and number of places is not set" do
        subject { create(:allocation).number_of_places }

        # TODO this should be invalid. Error handling of invalid
        # request_type - number_of_places combinations to be added
        it { is_expected.to eq(0) }
      end

      context "and number of places is set" do
        subject { create(:allocation, number_of_places: original_number_of_places).number_of_places }

        let(:original_number_of_places) { 10 }

        it "is unchanged" do
          expect(subject).to eq(original_number_of_places)
        end
      end
    end
  end
end
