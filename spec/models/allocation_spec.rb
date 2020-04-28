# == Schema Information
#
# Table name: allocation
#
#  accredited_body_id :bigint
#  created_at         :datetime         not null
#  id                 :bigint           not null, primary key
#  number_of_places   :integer
#  provider_id        :bigint
#  request_type       :integer          default("initial")
#  updated_at         :datetime         not null
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
end
