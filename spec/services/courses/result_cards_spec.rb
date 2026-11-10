# frozen_string_literal: true

require "rails_helper"

RSpec.describe Courses::ResultCards do
  let(:mathematics) { find_or_create(:secondary_subject, :mathematics) }
  let(:physics) { find_or_create(:secondary_subject, :physics) }

  let(:ashford) { create(:provider, provider_name: "Ashford Teacher Training") }
  let(:bexley) { create(:provider, provider_name: "Bexley SCITT") }
  let(:camden) { create(:provider, provider_name: "Camden School") }

  let(:params) { { order: "provider_name_ascending" } }

  def result_cards(page: 1, per_page: 10)
    query = Courses::Query.new(params: params.dup)
    query.call

    described_class.new(query:, page:, per_page:)
  end

  def card_codes(cards)
    cards.map { |card| card.map(&:course_code) }
  end

  def create_course(provider:, course_code:, subject: mathematics, sites: :with_full_time_sites, **attributes)
    create(
      :course,
      :secondary,
      sites,
      :published,
      provider:,
      course_code:,
      name: subject.subject_name,
      subjects: [subject],
      master_subject_id: subject.id,
      **attributes,
    )
  end

  context "when a provider has courses of the same subject next to each other" do
    before do
      create_course(provider: ashford, course_code: "A001")
      create_course(provider: ashford, course_code: "A002", is_send: true)
      create_course(provider: bexley, course_code: "B001")
    end

    it "puts them on one card, including SEND courses" do
      expect(card_codes(result_cards.cards)).to eq([%w[A001 A002], %w[B001]])
    end
  end

  context "when a provider's same-subject courses have different accredited providers" do
    let(:university_a) { create(:provider, :accredited_provider) }
    let(:university_b) { create(:provider, :accredited_provider) }

    before do
      create_course(provider: ashford, course_code: "A001", accredited_provider_code: university_a.provider_code)
      create_course(provider: ashford, course_code: "A002", accredited_provider_code: university_b.provider_code)
    end

    it "puts them on one card" do
      expect(card_codes(result_cards.cards)).to eq([%w[A001 A002]])
    end
  end

  context "when searching for 2 subjects" do
    let(:params) { { subjects: [mathematics.subject_code, physics.subject_code], order: "provider_name_ascending" } }

    before do
      create_course(provider: ashford, course_code: "A001")
      create_course(provider: ashford, course_code: "A002", subject: physics)
    end

    it "puts each subject on its own card" do
      expect(card_codes(result_cards.cards)).to eq([%w[A001], %w[A002]])
    end
  end

  context "when another provider's course sorts between a provider's courses" do
    let(:params) { { order: "fee_uk_ascending" } }

    before do
      create_course(provider: ashford, course_code: "A001", enrichments: [build(:course_enrichment, :published, fee_uk_eu: 9_000)])
      create_course(provider: bexley, course_code: "B001", enrichments: [build(:course_enrichment, :published, fee_uk_eu: 10_000)])
      create_course(provider: ashford, course_code: "A002", enrichments: [build(:course_enrichment, :published, fee_uk_eu: 12_000)])
    end

    it "splits the provider's courses into 2 cards" do
      expect(card_codes(result_cards.cards)).to eq([%w[A001], %w[B001], %w[A002]])
    end
  end

  context "when a filter leaves one course from a provider" do
    let(:params) { { study_types: %w[part_time], order: "provider_name_ascending" } }

    before do
      create_course(provider: ashford, course_code: "A001", study_mode: :full_time)
      create_course(provider: ashford, course_code: "A002", study_mode: :part_time, sites: :with_part_time_sites)
    end

    it "gives the provider a card with one course" do
      expect(card_codes(result_cards.cards)).to eq([%w[A002]])
    end
  end

  context "when there are more cards than fit on a page" do
    before do
      [ashford, bexley, camden].each_with_index do |provider, index|
        create_course(provider:, course_code: "#{index}01")
        create_course(provider:, course_code: "#{index}02")
      end
    end

    it "counts cards, not courses" do
      expect(result_cards(per_page: 2).count).to eq(3)
    end

    it "shows a page of cards, with more courses than cards" do
      page = result_cards(page: 1, per_page: 2)

      expect(card_codes(page.cards)).to eq([%w[001 002], %w[101 102]])
      expect(page.courses.map(&:course_code)).to eq(%w[001 002 101 102])
    end

    it "shows the remaining cards on the last page" do
      expect(card_codes(result_cards(page: 2, per_page: 2).cards)).to eq([%w[201 202]])
    end

    it "shows each course exactly once across the pages" do
      codes = [1, 2].flat_map { |page| result_cards(page:, per_page: 2).courses.map(&:course_code) }

      expect(codes).to eq(%w[001 002 101 102 201 202])
    end

    it "shows nothing past the last page" do
      expect(result_cards(page: 3, per_page: 2).courses).to be_empty
    end
  end

  context "with every sort option" do
    let(:school) { create(:gias_school, latitude: 52.4862, longitude: -1.8904) }

    before do
      [ashford, ashford, bexley].each_with_index do |provider, index|
        course = create_course(provider:, course_code: "C00#{index}")
        create(:course_school, course:, gias_school: school)
      end
    end

    %w[
      distance
      course_name_ascending
      provider_name_ascending
      newest_course
      start_date_ascending
      fee_uk_ascending
      fee_intl_ascending
    ].each do |order|
      context "when ordering by #{order}" do
        let(:params) { { latitude: 52.4862, longitude: -1.8904, radius: 10, order: } }

        it "groups the results in the order of the search" do
          cards = result_cards

          expect(cards.count).to be_between(2, 3)
          expect(cards.courses.map(&:id)).to eq(Courses::Query.call(params: params.dup).map(&:id))
        end
      end
    end
  end
end
