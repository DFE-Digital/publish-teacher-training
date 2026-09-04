# frozen_string_literal: true

require "rails_helper"

RSpec.describe Publish::Courses::Query do
  subject(:rows) { described_class.call(provider: provider.reload) }

  def group_names
    rows.map { |course| course[:group_name] }
  end

  def grouped_codes
    rows.group_by { |course| course[:group_name] }.transform_values { |courses| courses.map(&:course_code) }
  end

  describe "grouping and ordering" do
    context "when a self-accredited provider has its own courses" do
      let(:provider) { create(:provider, :accredited_provider) }

      before { create_list(:course, 3, provider:) }

      it "returns every course in the self-accredited (NULL) group" do
        expect(group_names).to eq([nil, nil, nil])
      end
    end

    context "when courses span multiple accredited providers" do
      let(:provider) { create(:provider) }

      before do
        create(:course, provider:, accrediting_provider: create(:accredited_provider, provider_name: "Banana College"))
        create(:course, provider:, accrediting_provider: create(:accredited_provider, provider_name: "apple Academy"))
        create(:course, provider:, accrediting_provider: create(:accredited_provider, provider_name: "Cherry Trust"))
      end

      it "orders groups case-insensitively by accredited provider name" do
        expect(group_names).to eq(["apple Academy", "Banana College", "Cherry Trust"])
      end
    end

    context "when the provider has both self-accredited and ratified courses" do
      let(:provider) { create(:provider, :accredited_provider, provider_name: "Mid Provider") }

      before do
        create(:course, provider:)
        create(:course, provider:, accrediting_provider: create(:accredited_provider, provider_name: "Zoo College"))
        create(:course, provider:, accrediting_provider: create(:accredited_provider, provider_name: "Aardvark University"))
      end

      it "orders the self-accredited group first, then the rest alphabetically" do
        expect(group_names).to eq([nil, "Aardvark University", "Zoo College"])
      end
    end

    context "when a course has no accredited provider" do
      let(:provider) { create(:provider, :accredited_provider) }

      before do
        create(:course, provider:, accrediting_provider: nil)
        create(:course, provider:, accrediting_provider: create(:accredited_provider, provider_name: "Other University"))
      end

      it "folds the course into the self-accredited group" do
        expect(grouped_codes.keys).to contain_exactly(nil, "Other University")
        expect(grouped_codes[nil].size).to eq(1)
      end
    end

    context "within a group" do
      let(:provider) { create(:provider) }
      let(:accredited_provider) { create(:accredited_provider, provider_name: "One University") }

      before do
        create(:course, provider:, accrediting_provider: accredited_provider, name: "Biology", course_code: "B200")
        create(:course, provider:, accrediting_provider: accredited_provider, name: "Art", course_code: "A100")
        create(:course, provider:, accrediting_provider: accredited_provider, name: "Biology", course_code: "B100")
      end

      it "orders courses by name then course code" do
        expect(grouped_codes).to eq("One University" => %w[A100 B100 B200])
      end
    end

    context "when the provider has no courses" do
      let(:provider) { create(:provider) }

      it "returns no rows" do
        expect(rows).to be_empty
      end
    end
  end

  describe "school filter" do
    subject(:rows) { described_class.call(provider: provider.reload, school:) }

    let(:provider) { create(:provider) }
    let(:school) { create(:provider_school, provider:) }
    let!(:attached) { create(:course, provider:, name: "Biology", course_code: "B123") }
    let!(:unattached) { create(:course, provider:, name: "History", course_code: "H100") }

    before { create(:course_school, course: attached, provider_school: school, gias_school: school.gias_school) }

    it "returns only courses attached to that school" do
      expect(rows.map(&:course_code)).to eq(%w[B123])
    end

    context "when the school has no attached courses" do
      subject(:rows) { described_class.call(provider: provider.reload, school: empty_school) }

      let(:empty_school) { create(:provider_school, provider:) }

      it "returns no courses" do
        expect(rows).to be_empty
      end
    end

    context "when an attached course has been discarded" do
      before { attached.discard }

      it "does not return it" do
        expect(rows).to be_empty
      end
    end
  end

  describe "accredited_provider filter" do
    subject(:rows) { described_class.call(provider: provider.reload, params: { accredited_provider: wanted.provider_code }) }

    let(:provider) { create(:provider) }
    let(:wanted) { create(:accredited_provider, provider_name: "Wanted University") }

    before do
      create(:course, provider:, accrediting_provider: wanted, course_code: "W111")
      create(:course, provider:, accrediting_provider: create(:accredited_provider, provider_name: "Other"))
    end

    it "returns only courses ratified by that accredited provider" do
      expect(rows.map(&:course_code)).to eq(%w[W111])
    end
  end

  describe "level filter" do
    subject(:rows) { described_class.call(provider: provider.reload, params:) }

    let(:provider) { create(:provider, :accredited_provider) }
    let!(:primary) { create(:course, :primary, provider:, name: "Alpha") }
    let!(:secondary) { create(:course, :secondary, provider:, name: "Bravo") }
    let!(:further_education) { create(:course, :without_validation, provider:, level: :further_education, name: "Charlie") }

    context "when no level is given" do
      let(:params) { {} }

      it "returns every course" do
        expect(rows).to match_collection([primary, secondary, further_education], attribute_names: %w[name level])
      end
    end

    context "when one level is given" do
      let(:params) { { level: %w[secondary] } }

      it "returns only courses at that level" do
        expect(rows).to match_collection([secondary], attribute_names: %w[name level])
      end
    end

    context "when several levels are given" do
      let(:params) { { level: %w[primary further_education] } }

      it "returns courses at any of them" do
        expect(rows).to match_collection([primary, further_education], attribute_names: %w[name level])
      end
    end

    context "when the level is not a recognised value" do
      let(:params) { { level: %w[bogus] } }

      it "returns no courses" do
        expect(rows).to be_empty
      end
    end

    context "when a recognised level is mixed with an unrecognised one" do
      let(:params) { { level: %w[primary bogus] } }

      it "ignores the unrecognised value" do
        expect(rows).to match_collection([primary], attribute_names: %w[name level])
      end
    end
  end

  describe "funding filter" do
    subject(:rows) { described_class.call(provider: provider.reload, params:) }

    let(:provider) { create(:provider, :accredited_provider) }
    let!(:fee) { create(:course, :fee, provider:, name: "Alpha") }
    let!(:salary) { create(:course, :salary, provider:, name: "Bravo") }
    let!(:apprenticeship) { create(:course, :apprenticeship, provider:, name: "Charlie") }

    context "when one funding type is given" do
      let(:params) { { funding: %w[salary] } }

      it "returns only courses with that funding" do
        expect(rows).to match_collection([salary], attribute_names: %w[name funding])
      end
    end

    context "when several funding types are given" do
      let(:params) { { funding: %w[fee apprenticeship] } }

      it "returns courses with any of them" do
        expect(rows).to match_collection([fee, apprenticeship], attribute_names: %w[name funding])
      end
    end

    context "when the funding type is not a recognised value" do
      let(:params) { { funding: %w[bogus] } }

      it "returns no courses" do
        expect(rows).to be_empty
      end
    end
  end

  describe "ids filter" do
    subject(:rows) { described_class.call(provider: provider.reload, params:) }

    let(:provider) { create(:provider, :accredited_provider) }
    let!(:wanted) { create(:course, provider:, name: "Alpha") }

    before { create(:course, provider:, name: "Bravo") }

    context "when no ids are given" do
      let(:params) { {} }

      it "returns every course" do
        expect(rows.size).to eq(2)
      end
    end

    context "when ids are given" do
      let(:params) { { ids: [wanted.id] } }

      it "returns only those courses" do
        expect(rows).to match_collection([wanted], attribute_names: %w[name])
      end
    end

    # An empty set is a set, not the absence of a filter: a bulk update that
    # matched nothing must show nothing.
    context "when the ids are empty" do
      let(:params) { { ids: [] } }

      it "returns no courses" do
        expect(rows).to be_empty
      end
    end
  end

  describe "qualification filter" do
    subject(:rows) { described_class.call(provider: provider.reload, params:) }

    let(:provider) { create(:provider, :accredited_provider) }
    let!(:qts) { create(:course, :resulting_in_qts, provider:, name: "Alpha") }
    let!(:pgce_with_qts) { create(:course, :resulting_in_pgce_with_qts, provider:, name: "Bravo") }
    let!(:pgde_with_qts) { create(:course, :resulting_in_pgde_with_qts, provider:, name: "Charlie") }

    before { create(:course, :resulting_in_pgce, provider:, name: "Delta") }

    context "when QTS only is given" do
      let(:params) { { qualification: %w[qts] } }

      it "returns only QTS courses" do
        expect(rows).to match_collection([qts], attribute_names: %w[name qualification])
      end
    end

    context "when QTS with PGCE or PGDE is given" do
      let(:params) { { qualification: %w[qts_with_pgce_or_pgde] } }

      it "returns both the PGCE and the PGDE courses" do
        expect(rows).to match_collection([pgce_with_qts, pgde_with_qts], attribute_names: %w[name qualification])
      end
    end

    context "when both options are given" do
      let(:params) { { qualification: %w[qts qts_with_pgce_or_pgde] } }

      it "returns the union rather than nothing" do
        expect(rows).to match_collection([qts, pgce_with_qts, pgde_with_qts], attribute_names: %w[name qualification])
      end
    end

    context "when the qualification is not a recognised value" do
      let(:params) { { qualification: %w[bogus] } }

      it "returns no courses" do
        expect(rows).to be_empty
      end
    end
  end

  describe "study mode filter" do
    subject(:rows) { described_class.call(provider: provider.reload, params:) }

    let(:provider) { create(:provider, :accredited_provider) }
    let!(:full_time) { create(:course, provider:, study_mode: :full_time, name: "Alpha") }
    let!(:part_time) { create(:course, provider:, study_mode: :part_time, name: "Bravo") }
    let!(:either) { create(:course, provider:, study_mode: :full_time_or_part_time, name: "Charlie") }

    context "when full time is given" do
      let(:params) { { study_mode: %w[full_time] } }

      it "also returns courses offered either way" do
        expect(rows).to match_collection([full_time, either], attribute_names: %w[name study_mode])
      end
    end

    context "when part time is given" do
      let(:params) { { study_mode: %w[part_time] } }

      it "also returns courses offered either way" do
        expect(rows).to match_collection([part_time, either], attribute_names: %w[name study_mode])
      end
    end

    context "when both options are given" do
      let(:params) { { study_mode: %w[full_time part_time] } }

      it "returns the union rather than nothing" do
        expect(rows).to match_collection([full_time, part_time, either], attribute_names: %w[name study_mode])
      end
    end

    context "when the study mode is not a recognised value" do
      let(:params) { { study_mode: %w[bogus] } }

      it "returns no courses" do
        expect(rows).to be_empty
      end
    end
  end

  describe "start date filter" do
    subject(:rows) { described_class.call(provider: provider.reload, params:) }

    let(:provider) { create(:provider, :accredited_provider) }
    let!(:september) { create(:course, provider:, name: "Alpha", start_date: Time.zone.local(2026, 9, 1)) }
    let!(:january) { create(:course, provider:, name: "Bravo", start_date: Time.zone.local(2027, 1, 15)) }

    # A course with no start date must never match a month.
    before { create(:course, :without_validation, provider:, name: "Charlie", start_date: nil) }

    context "when one month is given" do
      let(:params) { { start_date: %w[2026-09] } }

      it "returns only courses starting in that month" do
        expect(rows).to match_collection([september], attribute_names: %w[name start_date])
      end
    end

    context "when several months are given" do
      let(:params) { { start_date: %w[2026-09 2027-01] } }

      it "returns courses starting in any of them" do
        expect(rows).to match_collection([september, january], attribute_names: %w[name start_date])
      end
    end

    context "when a month has no courses" do
      let(:params) { { start_date: %w[2026-12] } }

      it "returns no courses" do
        expect(rows).to be_empty
      end
    end

    context "at the boundaries of the selected month" do
      let(:params) { { start_date: %w[2026-09] } }
      let!(:last_moment) { create(:course, provider:, name: "Delta", start_date: Time.zone.local(2026, 9, 30, 23, 59, 59)) }

      before { create(:course, provider:, name: "Echo", start_date: Time.zone.local(2026, 10, 1, 0, 0, 0)) }

      it "includes the last moment of the month and excludes the first of the next" do
        expect(rows).to match_collection([september, last_moment], attribute_names: %w[name start_date])
      end
    end

    context "when a course starts in the British Summer Time hour before UTC midnight" do
      # Stored as 2026-08-31 23:30 UTC, but the list displays it — and the
      # provider thinks of it — as September, so September must match it.
      let(:params) { { start_date: %w[2026-09] } }
      let!(:just_after_midnight) { create(:course, provider:, name: "Delta", start_date: Time.zone.local(2026, 9, 1, 0, 30)) }

      it "matches the month the course displays under" do
        expect(just_after_midnight.start_date.utc.day).to eq(31)
        expect(rows).to match_collection([september, just_after_midnight], attribute_names: %w[name start_date])
      end
    end

    context "when the month cannot be parsed" do
      let(:params) { { start_date: %w[bogus] } }

      it "returns no courses" do
        expect(rows).to be_empty
      end
    end

    context "when a parseable month is mixed with an unparseable one" do
      let(:params) { { start_date: %w[2026-09 bogus] } }

      it "ignores the unparseable value" do
        expect(rows).to match_collection([september], attribute_names: %w[name start_date])
      end
    end
  end

  describe "status filter" do
    subject(:rows) { described_class.call(provider: provider.reload, params:) }

    def published_with_changes
      [build(:course_enrichment, :published), build(:course_enrichment, :initial_draft)]
    end

    context "in the current recruitment cycle" do
      let(:provider) { create(:provider, :accredited_provider) }
      let!(:closed_published) { create(:course, :published, provider:, application_status: :closed, name: "Closed published") }
      let!(:draft_enrichment) { create(:course, :draft_enrichment, provider:, application_status: :open, name: "Draft enrichment") }
      let!(:draft_no_enrichment) { create(:course, provider:, application_status: :open, name: "Draft none") }
      let!(:open_published) { create(:course, :published, provider:, application_status: :open, name: "Open published") }
      let!(:open_with_changes) { create(:course, provider:, application_status: :open, name: "Open with changes", enrichments: published_with_changes) }
      let!(:rolled_over) { create(:course, provider:, application_status: :open, name: "Rolled over", enrichments: [build(:course_enrichment, :rolled_over)]) }
      let!(:withdrawn) { create(:course, :withdrawn, provider:, application_status: :open, name: "Withdrawn") }

      context "when open is given" do
        let(:params) { { status: %w[open] } }

        it "returns published courses accepting applications, including those with unpublished changes" do
          expect(rows).to match_collection([open_published, open_with_changes], attribute_names: %w[name])
        end
      end

      context "when closed is given" do
        let(:params) { { status: %w[closed] } }

        it "returns published courses not accepting applications" do
          expect(rows).to match_collection([closed_published], attribute_names: %w[name])
        end
      end

      context "when draft is given" do
        let(:params) { { status: %w[draft] } }

        it "returns courses with no enrichment and courses with only a draft" do
          expect(rows).to match_collection([draft_enrichment, draft_no_enrichment], attribute_names: %w[name])
        end
      end

      context "when rolled over is given" do
        let(:params) { { status: %w[rolled_over] } }

        it "returns only rolled over courses" do
          expect(rows).to match_collection([rolled_over], attribute_names: %w[name])
        end
      end

      context "when withdrawn is given" do
        let(:params) { { status: %w[withdrawn] } }

        it "returns only withdrawn courses" do
          expect(rows).to match_collection([withdrawn], attribute_names: %w[name])
        end
      end

      context "when scheduled is given" do
        let(:params) { { status: %w[scheduled] } }

        it "returns no courses, because nothing in this cycle is scheduled" do
          expect(rows).to be_empty
        end
      end

      context "when several statuses are given" do
        let(:params) { { status: %w[draft withdrawn] } }

        it "returns courses matching any of them" do
          expect(rows).to match_collection([draft_enrichment, draft_no_enrichment, withdrawn], attribute_names: %w[name])
        end
      end

      context "when a reachable status is combined with an unreachable one" do
        let(:params) { { status: %w[open scheduled] } }

        it "returns the courses matching the reachable status" do
          expect(rows).to match_collection([open_published, open_with_changes], attribute_names: %w[name])
        end
      end

      context "when the status is not a recognised value" do
        let(:params) { { status: %w[bogus] } }

        it "returns no courses" do
          expect(rows).to be_empty
        end
      end

      context "when no status is given" do
        let(:params) { {} }

        it "returns every course" do
          expect(rows.size).to eq(7)
        end
      end
    end

    context "in a future recruitment cycle" do
      let(:provider) { create(:provider, :accredited_provider, :next_recruitment_cycle) }
      let!(:published) { create(:course, :published, provider:, application_status: :open, name: "Alpha") }
      let!(:with_changes) { create(:course, provider:, application_status: :closed, name: "Bravo", enrichments: published_with_changes) }
      let!(:draft) { create(:course, :draft_enrichment, provider:, application_status: :open, name: "Charlie") }

      context "when scheduled is given" do
        let(:params) { { status: %w[scheduled] } }

        it "returns published courses regardless of their application status" do
          expect(rows).to match_collection([published, with_changes], attribute_names: %w[name])
        end
      end

      context "when open is given" do
        let(:params) { { status: %w[open] } }

        it "returns no courses, because nothing in a future cycle is open yet" do
          expect(rows).to be_empty
        end
      end

      context "when closed is given" do
        let(:params) { { status: %w[closed] } }

        it "returns no courses" do
          expect(rows).to be_empty
        end
      end

      context "when draft is given" do
        let(:params) { { status: %w[draft] } }

        it "still returns draft courses, which are cycle independent" do
          expect(rows).to match_collection([draft], attribute_names: %w[name])
        end
      end
    end

    context "when combined with another filter" do
      let(:provider) { create(:provider, :accredited_provider) }
      let(:params) { { status: %w[draft], funding: %w[salary] } }
      let!(:wanted) { create(:course, :draft_enrichment, :salary, provider:, name: "Alpha") }

      before do
        create(:course, :draft_enrichment, :fee, provider:, name: "Bravo")
        create(:course, :published, :salary, provider:, name: "Charlie")
      end

      it "narrows on both" do
        expect(rows).to match_collection([wanted], attribute_names: %w[name])
      end
    end
  end

  # Drift guard: a course is returned by a status filter exactly when the list
  # renders it with that status tag. Rendering is the source of truth, so the
  # two cannot disagree about what "Open" or "Scheduled" means.
  describe "status filter agrees with the rendered status tag", type: :component do
    let(:provider) { create(:provider, :accredited_provider) }

    def tag_text(row)
      render_inline(
        Publish::Courses::StatusTagComponent.new(course: row, recruitment_cycle_year: row.recruitment_cycle.year),
      ).css(".govuk-tag").text.strip
    end

    before do
      create(:course, :published, provider:, application_status: :open, name: "Alpha")
      create(:course, :published, provider:, application_status: :closed, name: "Bravo")
      create(:course, provider:, application_status: :open, name: "Charlie")
      create(:course, :draft_enrichment, provider:, application_status: :closed, name: "Delta")
      create(:course, provider:, application_status: :open, name: "Echo", enrichments: [build(:course_enrichment, :rolled_over)])
      create(:course, :withdrawn, provider:, application_status: :open, name: "Foxtrot")
      create(:course, provider:, application_status: :closed, name: "Golf",
                      enrichments: [build(:course_enrichment, :published), build(:course_enrichment, :initial_draft)])
    end

    {
      "open" => "Open",
      "closed" => "Closed",
      "draft" => "Draft",
      "rolled_over" => "Rolled over",
      "withdrawn" => "Withdrawn",
    }.each do |token, label|
      it "returns exactly the courses tagged #{label.inspect} for status=#{token}" do
        all_rows = described_class.call(provider: provider.reload)
        expected = all_rows.select { |row| tag_text(row).delete_suffix(" *") == label }
        filtered = described_class.call(provider: provider.reload, params: { status: [token] })

        expect(expected).to be_present
        expect(filtered.map(&:id)).to match_array(expected.map(&:id))
      end
    end
  end

  # The filter values reach SQL, so prove hostile input is inert rather than
  # merely allowed through by the form that normally sits in front of the query.
  describe "hostile filter values" do
    subject(:rows) { described_class.call(provider: provider.reload, params:) }

    let(:provider) { create(:provider, :accredited_provider) }

    before { create_list(:course, 2, provider:) }

    injection = "x' OR 1=1 --"
    drop_table = "2026-09'); DROP TABLE course; --"

    {
      "level" => { level: [injection] },
      "funding" => { funding: [injection] },
      "qualification" => { qualification: [injection] },
      "study_mode" => { study_mode: [injection] },
      "status" => { status: [injection] },
      "start_date" => { start_date: [injection] },
      "start_date with a statement terminator" => { start_date: [drop_table] },
    }.each do |description, hostile_params|
      context "when #{description} carries SQL" do
        let(:params) { hostile_params }

        it "matches nothing and leaves the database intact" do
          expect(rows).to be_empty
          expect(::Course.count).to eq(2)
        end
      end
    end

    context "when a hostile value is mixed with a real one" do
      let(:params) { { level: ["primary", injection] } }

      it "applies only the real one" do
        expect(rows.size).to eq(2)
        expect(::Course.count).to eq(2)
      end
    end
  end

  describe "combining filters" do
    subject(:rows) { described_class.call(provider: provider.reload, params:) }

    let(:provider) { create(:provider, :accredited_provider) }
    let!(:wanted) { create(:course, :primary, :salary, provider:, name: "Alpha") }
    let(:params) { { level: %w[primary], funding: %w[salary] } }

    before do
      create(:course, :primary, :fee, provider:, name: "Bravo")
      create(:course, :secondary, :salary, provider:, name: "Charlie")
    end

    it "narrows on every filter at once" do
      expect(rows).to match_collection([wanted], attribute_names: %w[name level funding])
    end
  end

  describe "applied_scopes" do
    let(:provider) { create(:provider, :accredited_provider) }
    let(:query) { described_class.new(provider: provider.reload, params:) }

    context "when filters are given" do
      let(:params) do
        { level: %w[primary], funding: %w[fee], qualification: %w[qts], study_mode: %w[part_time], start_date: %w[2026-09] }
      end

      it "records each applied filter" do
        query.call

        expect(query.applied_scopes).to eq(
          level: %w[primary], funding: %w[fee], qualification: %w[qts], study_mode: %w[part_time], start_date: %w[2026-09],
        )
      end
    end

    context "when no filters are given" do
      let(:params) { {} }

      it "records nothing" do
        query.call

        expect(query.applied_scopes).to be_empty
      end
    end
  end

  describe "content_status column matches the canonical Ruby" do
    let(:provider) { create(:provider, :accredited_provider) }

    {
      "no enrichment" => -> { create(:course, provider:) },
      "a single draft" => -> { create(:course, :draft_enrichment, provider:) },
      "a single published enrichment" => -> { create(:course, :published, provider:) },
      "a withdrawn enrichment" => -> { create(:course, :withdrawn, provider:) },
      "published with a newer draft" => lambda {
        create(:course, provider:, enrichments: [build(:course_enrichment, :published), build(:course_enrichment, :initial_draft)])
      },
    }.each do |description, setup|
      context "with #{description}" do
        before { instance_exec(&setup) }

        it "agrees with Course#content_status" do
          row = described_class.call(provider: provider.reload).first

          expect(row[:content_status]).to eq(row.content_status.to_s)
        end
      end
    end
  end

  describe "query efficiency" do
    def count_queries(&)
      count = 0
      counter = ->(_name, _start, _finish, _id, payload) { count += 1 unless payload[:name].to_s =~ /SCHEMA|TRANSACTION/ }
      ActiveSupport::Notifications.subscribed(counter, "sql.active_record", &)
      count
    end

    def materialise(course_count, params = {})
      provider = create(:provider)
      accredited = create(:accredited_provider)
      create_list(:course, course_count, :published, provider:, accrediting_provider: accredited)
      count_queries { described_class.call(provider: provider.reload, params:).to_a }
    end

    it "loads the list in a constant number of queries regardless of course count" do
      expect(materialise(12)).to eq(materialise(3))
    end

    # The status filter needs the provider's cycle year, which costs one
    # association load — but that is per request, not per course, so a filtered
    # list must still be constant in the number of courses.
    it "loads a filtered list in a constant number of queries regardless of course count" do
      filters = { level: %w[primary], funding: %w[fee], qualification: %w[qts], study_mode: %w[full_time], status: %w[closed] }

      expect(materialise(12, filters)).to eq(materialise(3, filters))
    end

    it "adds no more than the cycle lookup when filtering" do
      provider = create(:provider)
      create_list(
        :course, 12, :published, :primary, :fee, :resulting_in_qts,
        provider:, accrediting_provider: create(:accredited_provider), study_mode: :full_time
      )
      filters = { level: %w[primary], funding: %w[fee], qualification: %w[qts], study_mode: %w[full_time], status: %w[closed] }

      unfiltered = count_queries { described_class.call(provider: provider.reload).to_a }
      filtered = count_queries { described_class.call(provider: provider.reload, params: filters).to_a }

      # Guard against passing because the filters matched nothing, which would
      # skip the preload the unfiltered list performs.
      expect(described_class.call(provider: provider.reload, params: filters).size).to eq(12)
      expect(filtered).to eq(unfiltered + 1)
    end
  end
end
