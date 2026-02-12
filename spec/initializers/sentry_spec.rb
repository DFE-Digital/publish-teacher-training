# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Sentry before_send" do
  subject(:before_send) { Sentry.configuration.before_send.call(event, hint) }

  let(:hint) { { exception: StandardError.new("test") } }
  let(:event) { Sentry::Event.new(configuration: Sentry.configuration) }

  context "when the event message is 'One Login failure'" do
    before { event.message = { message: "One Login failure" } }

    context "when not in production" do
      it "drops the event" do
        allow(Rails.env).to receive(:production?).and_return(false)

        expect(before_send).to be_nil
      end
    end

    context "when in production" do
      it "does not drop the event" do
        allow(Rails.env).to receive(:production?).and_return(true)

        expect(before_send).not_to be_nil
      end
    end
  end

  context "when the event message is not 'One Login failure'" do
    before { event.message = { message: "Some other error" } }

    it "returns the filtered event" do
      expect(before_send).not_to be_nil
    end
  end
end
