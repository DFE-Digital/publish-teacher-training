# frozen_string_literal: true

require "rails_helper"

module Filters
  module AllocationAttributes
    describe View do
      alias_method :component, :page

      let(:filters) { { text_search: "South Park Elementary" } }

      before do
        render_inline(described_class.new(filters:))
      end

      it "renders all the correct details" do
        expect(component).to have_text("Name or code")
      end
    end
  end
end
