# frozen_string_literal: true

require "rails_helper"

module Filters
  module ProviderAttributes
    describe View do
      alias_method :component, :page

      let(:filters) { nil }

      before do
        render_inline(described_class.new(filters: nil))
      end

      it "renders all the correct details" do
        expect(component).to have_text("Provider name or code")
        expect(component).to have_text("Course code")
      end
    end
  end
end
