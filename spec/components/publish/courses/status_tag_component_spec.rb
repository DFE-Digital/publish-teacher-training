# frozen_string_literal: true

require "rails_helper"

# Drift guard: the read-model status tag (fed by Publish::Courses::Query columns)
# must render identically to the canonical ApplicationDecorator#status_tag across
# enrichment states, application status, and recruitment-cycle branches.
RSpec.describe Publish::Courses::StatusTagComponent, type: :component do
  def row_for(course)
    Publish::Courses::Query.call(provider: course.provider.reload).detect { |row| row.id == course.id }
  end

  def rendered_component(course)
    row = row_for(course)
    render_inline(described_class.new(course: row, recruitment_cycle_year: row.recruitment_cycle.year)).to_html
  end

  def normalize(html)
    html.to_s.gsub(/\s+/, " ").strip
  end

  def expect_match(course)
    expect(normalize(rendered_component(course))).to eq(normalize(course.reload.decorate.status_tag))
  end

  enrichment_states = {
    "draft (no enrichment)" => {},
    "draft enrichment" => { traits: %i[draft_enrichment] },
    "published" => { traits: %i[published] },
    "withdrawn" => { traits: %i[withdrawn] },
    "published with a newer draft" => { enrichments: -> { [build(:course_enrichment, :published), build(:course_enrichment, :initial_draft)] } },
    "rolled over" => { enrichments: -> { [build(:course_enrichment, :rolled_over)] } },
  }

  def build_course(provider:, application_status:, traits: [], enrichments: nil)
    attrs = { provider:, application_status: }
    attrs[:enrichments] = instance_exec(&enrichments) if enrichments
    create(:course, *traits, **attrs)
  end

  context "in the current recruitment cycle" do
    let(:provider) { create(:provider, :accredited_provider) }

    enrichment_states.each do |description, config|
      %i[open closed].each do |application_status|
        it "matches the decorator for #{description} (#{application_status})" do
          course = build_course(provider:, application_status:, traits: config[:traits] || [], enrichments: config[:enrichments])
          expect_match(course)
        end
      end
    end
  end

  context "in a future recruitment cycle (scheduled)" do
    let(:provider) { create(:provider, :accredited_provider, :next_recruitment_cycle) }

    it "matches the decorator for a published course" do
      expect_match(build_course(provider:, application_status: :open, traits: %i[published]))
    end

    it "matches the decorator for a published course with unpublished changes" do
      course = build_course(provider:, application_status: :open, enrichments: -> { [build(:course_enrichment, :published), build(:course_enrichment, :initial_draft)] })
      expect_match(course)
    end
  end

  context "in the previous recruitment cycle" do
    let(:provider) { create(:provider, :accredited_provider, :previous_recruitment_cycle) }

    %i[open closed].each do |application_status|
      it "matches the decorator for a published course (#{application_status})" do
        expect_match(build_course(provider:, application_status:, traits: %i[published]))
      end
    end
  end
end
