# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Sentry" do
  def raise_and_rescue
    yield
  rescue StandardError => e
    e
  end

  def before_send(exception)
    event = Sentry::ErrorEvent.new(configuration: Sentry.configuration)
    event.add_exception_interface(exception, mechanism: Sentry::Mechanism.new)
    Sentry.configuration.before_send.call(event, { exception: })
  end

  let(:unique_violation_message) do
    <<~MESSAGE
      PG::UniqueViolation: ERROR:  duplicate key value violates unique constraint "index_user_on_email"
      DETAIL:  Key (email)=(someone@example.com) already exists.
    MESSAGE
  end

  it "redacts PG DETAIL from an unwrapped RecordNotUnique and still sends the event" do
    event = before_send(ActiveRecord::RecordNotUnique.new(unique_violation_message))

    expect(event.exception.values.map(&:value)).to eq([<<~FILTERED])
      PG::UniqueViolation: ERROR:  duplicate key value violates unique constraint "index_user_on_email" (ActiveRecord::RecordNotUnique)
      [PG DETAIL FILTERED]
    FILTERED
  end

  it "redacts PG DETAIL from every exception in a wrapped cause chain" do
    exception = raise_and_rescue do
      raise ActiveRecord::RecordNotUnique, unique_violation_message
    rescue ActiveRecord::RecordNotUnique
      raise ActiveRecord::StatementInvalid, "PG::InFailedSqlTransaction: ERROR:  aborted\nDETAIL:  Key (session_id)=(abc123)."
    end

    values = before_send(exception).exception.values.map(&:value)

    expect(values.size).to eq(2)
    expect(values).to all(include("[PG DETAIL FILTERED]"))
    expect(values.join).not_to include("someone@example.com", "abc123")
  end
end
