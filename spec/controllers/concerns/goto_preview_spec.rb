# frozen_string_literal: true

require 'rails_helper'

describe GotoPreview do
  let(:test_class) do
    Class.new do
      include GotoPreview

      def params; end

      def param_form_key = :param_form_key
    end.new
  end

  before do
    allow(test_class).to receive(:params).and_return(params)
  end

  describe '#goto_preview?' do
    subject do
      test_class.goto_preview?
    end

    context 'params is empty' do
      let(:params) { {} }

      it 'returns falsey' do
        expect(subject).to be_falsey
      end
    end

    context 'params has param_form_key with goto_preview set to "true"' do
      let(:params) { { param_form_key: { goto_preview: 'true' } } }

      it 'returns truthy' do
        expect(subject).to be_truthy
      end
    end
  end

  describe '#goto_provider?' do
    subject do
      test_class.goto_provider?
    end

    context 'params is empty' do
      let(:params) { {} }

      it 'returns falsey' do
        expect(subject).to be_falsey
      end
    end

    context 'params has param_form_key with goto_provider set to "true"' do
      let(:params) { { param_form_key: { goto_provider: 'true' } } }

      it 'returns truthy' do
        expect(subject).to be_truthy
      end
    end
  end
end
