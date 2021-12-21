# frozen_string_literal: true

require "rails_helper"

module Filters
  module UserAttributes
    describe View do
      alias_method :component, :page

      let(:filters) { nil }

      before do
        render_inline(described_class.new(filters: nil))
      end

      it "renders all the correct details" do
        # TODO: Add more expected attributes here
      end
    end
  end
end
