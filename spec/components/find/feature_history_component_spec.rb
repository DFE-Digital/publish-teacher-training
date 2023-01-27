# frozen_string_literal: true

require 'rails_helper'

module Find
  describe FeatureHistoryComponent, type: :component do
    let(:feature_name) { 'test_feature' }

    before do
      allow(FeatureFlag).to receive(:last_updated).with(feature_name).and_return(Time.zone.local(2021, 12, 1, 12).to_s)
    end

    context 'feature is active' do
      it 'renders the correctly formatted date and time' do
        allow(FeatureFlag).to receive(:active?).and_return(true)

        result = render_inline(described_class.new(feature_name))

        expect(result.text).to have_content 'Changed to active at 12pm on 1 December 2021'
      end
    end

    context 'feature is inactive' do
      it 'renders the correctly formatted date and time' do
        allow(FeatureFlag).to receive(:active?).and_return(false)

        result = render_inline(described_class.new(feature_name))

        expect(result.text).to have_content 'Changed to inactive at 12pm on 1 December 2021'
      end
    end

    context 'feature has never been updated' do
      it 'renders a message saying the feature flag has not been updated' do
        allow(FeatureFlag).to receive(:active?).and_return(false)
        allow(FeatureFlag).to receive(:last_updated).and_return(nil)

        result = render_inline(described_class.new(feature_name))

        expect(result.text).to have_content 'This flag has not been updated'
      end
    end
  end
end
