# frozen_string_literal: true

require "rails_helper"

describe Support::Allocations::Filter do
  let(:allocation) { create(:allocation, number_of_places: 5) }
  let(:allocation2) { create(:allocation, number_of_places: 3) }
  let(:provider) { allocation.provider }

  subject { Support::Allocations::Filter.call(allocations: Allocation.all, filters: params) }

  before do
    allocation
    allocation2
  end

  describe "#call" do
    context "filtering with a known allocation provider" do
      let(:params) do
        {
          text_search: provider.provider_name,
        }
      end

      it "filters the allocation out" do
        expect(subject).to eq([allocation])
      end
    end

    context "filtering with an unknown allocation provider or invalid entry" do
      let(:params) do
        {
          text_search: "i can haz cheezeburger",
        }
      end

      it "returns empty relation" do
        expect(subject).to be_empty
      end
    end

    context "filtering with no filters" do
      let(:params) { {} }

      it "returns all results" do
        expect(subject.length).to eq 2
        expect(subject).to eq([allocation, allocation2])
      end
    end
  end
end
