require "rails_helper"

RSpec.describe RolloverProgressComponent, type: :component do
  include ViewComponent::TestHelpers

  subject(:result) { render_inline(component) }

  let(:current_cycle) { create(:recruitment_cycle) }
  let(:target_cycle) { build(:recruitment_cycle, :next, application_start_date: Date.tomorrow) }

  let(:component) do
    described_class.new(
      current_cycle:,
      target_cycle:,
    )
  end

  describe "percentage calculation" do
    context "with providers in both cycles" do
      before do
        create_list(:provider, 10, recruitment_cycle: current_cycle)
        create_list(:provider, 3, recruitment_cycle: target_cycle)
      end

      it "calculates correct percentage" do
        expect(component.percentage_complete).to eq(30.0)
      end
    end

    context "when current cycle has no providers" do
      it "returns 0%" do
        expect(component.percentage_complete).to eq(0.0)
      end
    end

    context "when target cycle has no providers" do
      before do
        create_list(:provider, 10, recruitment_cycle: current_cycle)
      end

      it "returns 0%" do
        expect(component.percentage_complete).to eq(0.0)
      end
    end

    context "when both cycles have providers" do
      before do
        create_list(:provider, 10, recruitment_cycle: current_cycle)
        create_list(:provider, 2, recruitment_cycle: target_cycle)
      end

      it "calculates exact percentage" do
        expect(component.percentage_complete).to eq(20.0)
      end
    end
  end

  describe "rendering" do
    context "with valid progress" do
      before do
        create_list(:provider, 10, recruitment_cycle: current_cycle)
        create_list(:provider, 4, recruitment_cycle: target_cycle)
      end

      it "displays correct status" do
        expect(result).to have_text("4 of 10 providers (40.0%)\n")
      end
    end

    context "with zero providers" do
      before do
        create_list(:provider, 10, recruitment_cycle: current_cycle)
      end

      it "shows 0% progress" do
        expect(result).to have_text("0 of 10 providers (0%)\n")
      end
    end

    context "when old cycles" do
      before do
        create_list(:provider, 10, recruitment_cycle: current_cycle)
        create_list(:provider, 2, recruitment_cycle: target_cycle)
      end

      it "always returns 100%" do
        expect(result).to have_text("")
      end
    end
  end
end
