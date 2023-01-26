# frozen_string_literal: true

require "rails_helper"

module Find
  describe FeedbackComponent, type: :component do
    let(:path) { "/path" }

    it "renders the correct feedback link" do
      render_inline(described_class.new(path:, controller: "results"))

      expect(page).to have_link(
        "How can we improve this page? (Opens in a new tab)",
        href: "#{Settings.apply_base_url}/candidate/find-feedback?path=#{path}&find_controller=results"
      )
    end
  end
end
