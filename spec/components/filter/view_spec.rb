# frozen_string_literal: true

require "rails_helper"

module Filters
  describe View do
    alias_method :component, :page

    let(:filter_model) { [Provider, User, Allocation].sample }

    before do
      render_inline(described_class.new(filters: nil, filter_model: filter_model))
    end

    it "renders all the correct details" do
      expect(component).to have_text("Filters")
    end
  end
end
