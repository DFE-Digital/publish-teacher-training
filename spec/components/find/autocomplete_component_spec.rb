# frozen_string_literal: true

require 'rails_helper'

module Find
  describe AutocompleteComponent, type: :component do
    context 'when sending classes to parent container' do
      before do
        render_inline(
          described_class.new(form_field:, classes: 'test-css-class')
        )
      end

      it 'supports custom classes on the parent container' do
        expect(page).to have_selector('.test-css-class')
      end

      it 'includes default classes' do
        expect(page).to have_selector('.suggestions')
      end

      it 'adds the data module' do
        expect(page).to have_selector('[data-module="app-dfe-autocomplete"]')
      end
    end

    context 'when sending html attributes' do
      before do
        render_inline(
          described_class.new(
            form_field:,
            html_attributes: { 'test-attribute' => 'my-custom-attribute' }
          )
        )
      end

      it 'supports custom html attributes on the parent container' do
        expect(page).to have_selector('[test-attribute="my-custom-attribute"]')
      end
    end

    context 'when not defining the raw attribute' do
      before do
        render_inline(
          described_class.new(
            form_field:,
            html_attributes: { 'test-attribute' => 'my-custom-attribute' }
          )
        )
      end

      it 'create empty default value' do
        expect(page).to have_selector('[data-module="app-dfe-autocomplete"]')
      end
    end

    private

    def form_field
      <<~HTML
        <div class="govuk-form-group">
          <label class="govuk-label" for="select-1">
            Select a country
          </label>
          <select class="govuk-select" id="select-1" name="select-1">
            <option value="">Select a country</option>
            <option value="fr">France</option>
            <option value="de">Germany</option>
            <option value="gb">United Kingdom</option>
          </select>
        </div>
      HTML
    end
  end
end
