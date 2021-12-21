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
      # TODO: Add more expected attributes here
    end

    it "renders the attributes filter of the filter klass" do
      # TODO: Check that the nested render happened
    end
  end
end
