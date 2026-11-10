# frozen_string_literal: true

require "rails_helper"

RSpec.describe Support::Providers::HistoryQuery do
  subject(:entries) { described_class.call(provider:) }

  let(:provider) { create(:provider, provider_name: "2Schools Consortium", provider_code: "T92") }
  let(:admin) { create(:user, :admin, first_name: "James", last_name: "Turner") }
  let(:provider_user) { create(:user, first_name: "Emily", last_name: "Banks") }
  let(:course) { create(:course, provider:, name: "Primary", course_code: "A123") }

  def create_audit!(auditable:, user:, changes:, created_at: Time.zone.now)
    Audited::Audit.create!(
      auditable:,
      user:,
      action: "update",
      audited_changes: changes,
      version: 1,
      created_at:,
    )
  end

  it "returns provider name changes with admin users tagged" do
    create_audit!(
      auditable: provider,
      user: admin,
      changes: { "provider_name" => ["2Schools Consortium", "3Schools Consortium"] },
      created_at: 2.days.ago,
    )

    entry = entries.find { |item| item.change_type == :provider_name }

    expect(entry.old_value).to eq("2Schools Consortium")
    expect(entry.new_value).to eq("3Schools Consortium")
    expect(entry.user_name).to eq("James Turner")
    expect(entry).to be_admin
  end

  it "returns provider code changes" do
    create_audit!(
      auditable: provider,
      user: admin,
      changes: { "provider_code" => %w[1A2 1A3] },
    )

    entry = entries.find { |item| item.change_type == :provider_code }

    expect(entry.old_value).to eq("1A2")
    expect(entry.new_value).to eq("1A3")
  end

  it "returns course name and application status changes with course details" do
    create_audit!(
      auditable: course,
      user: admin,
      changes: { "name" => ["Primary", "Primary with English"] },
      created_at: 3.days.ago,
    )
    create_audit!(
      auditable: course,
      user: provider_user,
      changes: { "application_status" => %w[open closed] },
      created_at: 1.day.ago,
    )

    name_entry = entries.find { |item| item.change_type == :course_name }
    status_entry = entries.find { |item| item.change_type == :application_status }

    expect(name_entry.course).to eq(course)
    expect(name_entry.old_value).to eq("Primary")
    expect(name_entry.new_value).to eq("Primary with English")
    expect(name_entry).to be_admin

    expect(status_entry.old_value).to eq("open")
    expect(status_entry.new_value).to eq("closed")
    expect(status_entry.user_name).to eq("Emily Banks")
    expect(status_entry).not_to be_admin
  end

  it "returns enrichment status changes going forward" do
    enrichment = create(:course_enrichment, :published, course:)
    create_audit!(
      auditable: enrichment,
      user: provider_user,
      changes: { "status" => %w[rolled_over published] },
    )

    entry = entries.find { |item| item.change_type == :enrichment_status }

    expect(entry.old_value).to eq("rolled_over")
    expect(entry.new_value).to eq("published")
    expect(entry.course).to eq(course)
    expect(entry.status_label("rolled_over")).to eq(text: "Rolled over", colour: "yellow")
    expect(entry.status_label("published")).to eq(text: "Published", colour: "teal")
  end

  it "includes enrichment status set on create (for example rollover)" do
    Audited.audit_class.as_user(admin) do
      create(:course_enrichment, :rolled_over, course:)
    end

    entry = entries.find { |item| item.change_type == :enrichment_status && item.old_value.nil? }

    expect(entry).to be_present
    expect(entry.new_value).to eq("rolled_over")
    expect(entry.course).to eq(course)
  end

  it "still skips create-time provider name values" do
    Audited::Audit.where(auditable: provider).delete_all
    Audited::Audit.create!(
      auditable: provider,
      user: admin,
      action: "create",
      audited_changes: { "provider_name" => "2Schools Consortium" },
      version: 1,
    )

    expect(entries.select { |item| item.change_type == :provider_name }).to be_empty
  end

  it "orders entries reverse chronologically and ignores irrelevant course audits" do
    create_audit!(
      auditable: course,
      user: admin,
      changes: { "changed_at" => [1.day.ago, Time.zone.now] },
      created_at: 1.hour.ago,
    )
    create_audit!(
      auditable: provider,
      user: admin,
      changes: { "provider_name" => %w[Old Newer] },
      created_at: 2.days.ago,
    )
    create_audit!(
      auditable: course,
      user: admin,
      changes: { "application_status" => %w[closed open] },
      created_at: 1.day.ago,
    )

    expect(entries.map(&:change_type)).to eq(%i[application_status provider_name])
  end

  it "falls back to System when there is no user" do
    create_audit!(
      auditable: provider,
      user: nil,
      changes: { "provider_name" => %w[A B] },
    )

    expect(entries.first.user_name).to eq("System")
    expect(entries.first).not_to be_admin
  end
end
