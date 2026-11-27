# frozen_string_literal: true

require "rails_helper"

RSpec.describe RetentionDeletion do
  describe "validations" do
    subject { build(:retention_deletion) }

    it { is_expected.to validate_presence_of(:entity_type) }
    it { is_expected.to validate_presence_of(:entity_id) }
    it { is_expected.to validate_presence_of(:deleted_records) }
    it { is_expected.to validate_presence_of(:deleted_at) }

    [
      ["an array", %w[123]],
      ["a table mapped to a single id", { "candidate" => "123" }],
      ["integer ids", { "candidate" => [123] }],
      ["an empty id list", { "candidate" => [] }],
      ["a blank id", { "candidate" => [""] }],
      ["a blank table name", { "" => %w[123] }],
    ].each do |description, deleted_records|
      it "rejects #{description}" do
        retention_deletion = build(:retention_deletion, deleted_records:)

        expect(retention_deletion).not_to be_valid
        expect(retention_deletion.errors[:deleted_records]).to eq(["must map each table name to a list of ID strings"])
      end
    end
  end

  describe "append-only" do
    let!(:retention_deletion) { create(:retention_deletion) }

    it "cannot be updated" do
      expect { retention_deletion.update!(entity_id: "999") }.to raise_error(ActiveRecord::ReadOnlyRecord)
    end

    it "cannot be destroyed" do
      expect { retention_deletion.destroy! }.to raise_error(ActiveRecord::ReadOnlyRecord)
    end
  end
end
