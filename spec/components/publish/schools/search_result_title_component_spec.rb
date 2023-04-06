# frozen_string_literal: true

require 'rails_helper'

module Publish
  module Schools
    describe SearchResultTitleComponent, type: :component do
      let(:query) { 'test' }
      let(:return_path) { '/test' }
      let(:results_limit) { 15 }

      it 'renders many results text when result is more than limit' do
        render_component(10_000)

        expect(page).to have_text("10000 results found for ‘#{query}’")
        expect(page).to have_link('Try narrowing down your search', href: '/test')
      end

      it 'renders few results text when result is less than limit' do
        render_component(10)

        expect(page).to have_text("10 results found for ‘#{query}’")
        expect(page).to have_link('Change your search', href: '/test')
        expect(page).to have_text('if the school you’re looking for is not listed.')
      end

      it 'renders one result text when there is only one result' do
        render_component(1)

        expect(page).to have_text("1 result found for ‘#{query}’")
        expect(page).to have_link('Change your search', href: '/test')
        expect(page).to have_text('if the school you’re looking for is not listed.')
      end

      it 'renders no results text when there are no results' do
        render_component(0)

        expect(page).to have_text("No results found for ‘#{query}’")
        expect(page).to have_link('Change your search', href: '/test')
        expect(page).not_to have_text('if the school you’re looking for is not listed.')
      end

      def render_component(results_count)
        render_inline(
          described_class.new(
            query:,
            results_limit:,
            results_count:,
            return_path:
          )
        )
      end
    end
  end
end
