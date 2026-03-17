# frozen_string_literal: true

require "rails_helper"
require "rake"

describe "courses:backfill_first_published_date" do
  before do
    Rails.application.load_tasks if Rake::Task.tasks.empty?
    task.reenable
  end

  let(:task) { Rake::Task["courses:backfill_first_published_date"] }

  it "backfills from the latest published enrichment created_at date" do
    course = create(:course, first_published_date: nil)
    create(:course_enrichment, :published, course:, created_at: Time.zone.local(2024, 1, 1, 9, 0, 0))
    create(:course_enrichment, :published, course:, created_at: Time.zone.local(2024, 2, 1, 9, 0, 0))

    task.invoke

    expect(course.reload.first_published_date).to eq(Date.new(2024, 2, 1))
  end

  it "does not overwrite an existing first_published_date" do
    course = create(:course, first_published_date: Date.new(2023, 12, 1))
    create(:course_enrichment, :published, course:, created_at: Time.zone.local(2024, 2, 1, 9, 0, 0))

    task.invoke

    expect(course.reload.first_published_date).to eq(Date.new(2023, 12, 1))
  end

  it "does not set a date when there are no published enrichments" do
    course = create(:course, first_published_date: nil)
    create(:course_enrichment, :draft, course:, created_at: Time.zone.local(2024, 2, 1, 9, 0, 0))

    task.invoke

    expect(course.reload.first_published_date).to be_nil
  end
end
