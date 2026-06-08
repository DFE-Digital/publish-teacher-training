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

  describe "content_status / has_unpublished_changes columns match the canonical Ruby" do
    let(:provider) { create(:provider, :accredited_provider) }

    def boolean(value)
      ActiveModel::Type::Boolean.new.cast(value)
    end

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

        it "agrees with Course#content_status and #has_unpublished_changes?" do
          row = described_class.call(provider: provider.reload).first

          expect(row[:content_status]).to eq(row.content_status.to_s)
          expect(boolean(row[:has_unpublished_changes])).to eq(row.has_unpublished_changes?)
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

    def materialise(course_count)
      provider = create(:provider)
      accredited = create(:accredited_provider)
      create_list(:course, course_count, :published, provider:, accrediting_provider: accredited)
      count_queries { described_class.call(provider: provider.reload).to_a }
    end

    it "loads the list in a constant number of queries regardless of course count" do
      expect(materialise(12)).to eq(materialise(3))
    end
  end
end
