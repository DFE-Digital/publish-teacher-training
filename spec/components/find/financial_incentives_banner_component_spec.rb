# frozen_string_literal: true

require "rails_helper"

module Find
  describe FinancialIncentivesBannerComponent, type: :component do
    context "when the `bursaries_and_scholarships_announced` flag is deactive" do
      it "does render" do
        FeatureFlag.deactivate(:bursaries_and_scholarships_announced)
        result = render_inline(described_class.new)

        expect(result.text).to have_content "Financial support"
      end
    end

    context "when the `bursaries_and_scholarships_announced` flag is active" do
      it "does not render" do
        FeatureFlag.activate(:bursaries_and_scholarships_announced)
        result = render_inline(described_class.new)

        expect(result.text).to be_blank
      end
    end
  end
end
