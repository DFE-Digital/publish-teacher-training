# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Logging rescued exceptions" do
  it "redacts PG DETAIL from the logged message" do
    allow(Rails.logger).to receive(:info).and_call_original

    ActiveSupport::Notifications.instrument(
      "rescue_from_callback.action_controller",
      exception: ActiveRecord::RecordNotUnique.new("PG::UniqueViolation: ERROR:  duplicate key\nDETAIL:  Key (email)=(someone@example.com) already exists."),
    )

    expect(Rails.logger).to have_received(:info).with(
      hash_including(payload: hash_including(exception_message: "PG::UniqueViolation: ERROR:  duplicate key\n[PG DETAIL FILTERED]")),
    )
  end
end
