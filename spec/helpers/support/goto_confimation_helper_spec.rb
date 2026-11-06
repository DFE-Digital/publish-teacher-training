# frozen_string_literal: true

require "rails_helper"

module Support
  describe GotoConfirmationHelper do
    let(:param_form_key) { :param_form_key }

    describe "#goto_confirmation_value" do
      subject do
        goto_confirmation_value(param_form_key:, params:)
      end

      context "params is empty" do
        let(:params) { {} }

        it "returns falsey" do
          expect(subject).to be_nil
        end
      end

      context 'params has goto_confirmation set to "true"' do
        let(:params) { { goto_confirmation: "true" } }

        it "returns truthy" do
          expect(subject).to eq("true")
        end
      end

      context 'params has param_form_key with goto_confirmation set to "true"' do
        let(:params) { { param_form_key: { goto_confirmation: "true" } } }

        it "returns truthy" do
          expect(subject).to eq("true")
        end
      end
    end

    describe "#goto_confirmation?" do
      subject do
        goto_confirmation?(param_form_key:, params:)
      end

      context "params is empty" do
        let(:params) { {} }

        it "returns falsey" do
          expect(subject).to be_falsey
        end
      end

      context 'params has goto_confirmation set to "true"' do
        let(:params) { { goto_confirmation: "true" } }

        it "returns truthy" do
          expect(subject).to be_truthy
        end
      end

      context 'params has param_form_key with goto_confirmation set to "true"' do
        let(:params) { { param_form_key: { goto_confirmation: "true" } } }

        it "returns truthy" do
          expect(subject).to be_truthy
        end
      end
    end
  end
end
