# frozen_string_literal: true

require "rails_helper"

RSpec.describe Support::AddUserWizard::Repositories::AddUser do
  let(:cache) { ActiveSupport::Cache::MemoryStore.new }
  let(:repository) do
    described_class.new(
      recruitment_cycle_year: 2027,
      state_key: "test-state-key",
      cache:,
    )
  end

  it "reads back the entered user details" do
    repository.write(
      "first_name" => "Luke",
      "last_name" => "Skywalker",
      "email" => "luke@jedi.com",
      "admin" => false,
    )

    expect(repository.read).to eq(
      first_name: "Luke",
      last_name: "Skywalker",
      email: "luke@jedi.com",
      admin: false,
    )
  end
end
