# frozen_string_literal: true

require "rails_helper"

# Drift guard: StatusTag.token must stay consistent with the two places that
# already agree with each other — the status filter (Query#status_scope) and the
# rendered status tag (StatusTagComponent). If any of the three changes without
# the others, this fails.
RSpec.describe "Publish::Courses::StatusTag drift", type: :component do
  let(:all_tokens) { %i[open closed draft rolled_over scheduled withdrawn] }

  # Base text of the tag a token renders (ignoring the " *" unpublished suffix).
  let(:token_tag_text) do
    { open: "Open", closed: "Closed", draft: "Draft", rolled_over: "Rolled over", scheduled: "Scheduled", withdrawn: "Withdrawn" }
  end

  def rows(provider)
    Publish::Courses::Query.call(provider: provider.reload)
  end

  def tag_text(row)
    render_inline(
      Publish::Courses::StatusTagComponent.new(course: row, recruitment_cycle_year: row.recruitment_cycle.year),
    ).css(".govuk-tag").text.strip.delete_suffix(" *")
  end

  shared_examples "agrees across the three sources" do
    it "returns each course from exactly the status filter matching its token, and renders that tag" do
      all_rows = rows(provider)
      expect(all_rows).to be_present

      all_rows.each do |row|
        token = Publish::Courses::StatusTag.token(row)

        # (1) token matches the rendered tag
        expect(tag_text(row)).to eq(token_tag_text.fetch(token))

        # (2) the status filter for that token returns the course...
        included = Publish::Courses::Query.call(provider: provider.reload, params: { status: [token.to_s] }).map(&:id)
        expect(included).to include(row.id)

        # (3) ...and no other token's filter does
        (all_tokens - [token]).each do |other|
          excluded = Publish::Courses::Query.call(provider: provider.reload, params: { status: [other.to_s] }).map(&:id)
          expect(excluded).not_to include(row.id)
        end
      end
    end
  end

  context "in the current recruitment cycle" do
    let(:provider) { create(:provider, :accredited_provider) }

    before do
      create(:course, :published, provider:, application_status: :open, name: "Open")
      create(:course, :published, provider:, application_status: :closed, name: "Closed")
      create(:course, :draft_enrichment, provider:, name: "Draft")
      create(:course, provider:, application_status: :open, name: "Rolled over", enrichments: [build(:course_enrichment, :rolled_over)])
      create(:course, :withdrawn, provider:, name: "Withdrawn")
      create(:course, provider:, application_status: :open, name: "Open with changes",
                      enrichments: [build(:course_enrichment, :published), build(:course_enrichment, :initial_draft)])
    end

    include_examples "agrees across the three sources"
  end

  context "in a future recruitment cycle" do
    let(:provider) { create(:provider, :accredited_provider, :next_recruitment_cycle) }

    before do
      create(:course, :published, provider:, application_status: :open, name: "Scheduled")
      create(:course, :draft_enrichment, provider:, name: "Draft")
    end

    include_examples "agrees across the three sources"
  end
end
