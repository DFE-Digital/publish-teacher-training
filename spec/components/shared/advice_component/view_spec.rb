# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Shared::AdviceComponent::View, type: :component do
  subject(:result) do
    render_inline(component) do
      content
    end
  end

  let(:title) { 'Your training journey' }
  let(:content) { 'You’ll be placed in schools for most of your course.' }

  context 'when render the title, caption and the content' do
    subject(:component) { described_class.new(title:) }

    it 'renders the title with caption' do
      expect(result).to have_css('.app-advice__caption', text: 'Advice from')
      expect(result.text).to include(title)
      expect(result.text).to include(content)
    end
  end

  context 'when the caption is hidden' do
    subject(:component) { described_class.new(title:, show_caption: false) }

    it 'renders the title without caption' do
      expect(result).to have_no_css('.app-advice__caption')
      expect(result.text).to include(title)
      expect(result.text).to include(content)
    end
  end
end
