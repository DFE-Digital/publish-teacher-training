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

  context "when the search has characters that look like bind markers" do
    let(:provider) { create(:provider, provider_name: "Who? St:Mary's") }
    let(:params) { { provider_name: provider.provider_name, order: "provider_name_ascending" } }

    before do
      create_course(provider:, course_code: "W001")
      create_course(provider:, course_code: "W002")
    end

    it "groups the results" do
      expect(card_codes(result_cards.cards)).to eq([%w[W001 W002]])
      expect(result_cards.count).to eq(1)
    end
  end

  context "when no courses match" do
    it "has no cards" do
      expect(result_cards.count).to eq(0)
      expect(result_cards.cards).to be_empty
    end
  end

  context "when a provider has courses of the same subject next to each other" do
    before do
      create_course(provider: ashford, course_code: "A001")
      create_course(provider: ashford, course_code: "A002", name: "Mathematics (SEND)", is_send: true)
      create_course(provider: bexley, course_code: "B001")
    end

    it "puts them on one card, including SEND courses" do
      expect(card_codes(result_cards.cards)).to eq([%w[A001 A002], %w[B001]])
    end

    context "when sorting by course name" do
      let(:params) { { order: "course_name_ascending" } }

      # The sort comes first: other providers' "Mathematics" courses sort
      # before "Mathematics (SEND)", so the SEND course gets its own card.
      it "gives the SEND course its own card" do
        expect(card_codes(result_cards.cards)).to eq([%w[A001], %w[B001], %w[A002]])
      end
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

  context "when searching for an accredited provider" do
    let(:university) { create(:provider, :accredited_provider, provider_name: "Birmingham City University") }
    let(:arthur_terry) { create(:provider, provider_name: "Arthur Terry School") }
    let(:bishop_vesey) { create(:provider, provider_name: "Bishop Vesey's Grammar School") }
    let(:teach_central) { create(:provider, provider_name: "Teach Central") }
    let(:params) { { provider_name: university.provider_name, order: "provider_name_ascending" } }

    before do
      create_course(provider: arthur_terry, course_code: "A001", accredited_provider_code: university.provider_code)
      create_course(provider: arthur_terry, course_code: "A002", accredited_provider_code: university.provider_code)
      create_course(provider: bishop_vesey, course_code: "B001")
      create_course(provider: teach_central, course_code: "T001", accredited_provider_code: university.provider_code)
    end

    it "gives each partner school its own card" do
      expect(card_codes(result_cards.cards)).to eq([%w[A001 A002], %w[T001]])
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

  # The fee sorts put every salaried and apprenticeship course after the
  # fee-paying ones, so a provider's would otherwise get a card of its own.
  context "when sorting by lowest fee" do
    let(:params) { { order: "fee_uk_ascending" } }

    def create_fee_course(provider:, course_code:, fee:, **attributes)
      create_course(provider:, course_code:, enrichments: [build(:course_enrichment, :published, fee_uk_eu: fee, fee_international: fee)], **attributes)
    end

    %w[salary apprenticeship].each do |funding|
      context "when a provider offers a subject for a fee and as #{funding}" do
        before do
          create_fee_course(provider: ashford, course_code: "A001", fee: 9_000)
          create_fee_course(provider: bexley, course_code: "B001", fee: 10_000)
          create_course(provider: ashford, course_code: "A002", funding:)
        end

        it "puts it at the bottom of the provider's card" do
          expect(card_codes(result_cards.cards)).to eq([%w[A001 A002], %w[B001]])
        end

        context "when sorting by lowest non-UK fee" do
          let(:params) { { order: "fee_intl_ascending" } }

          it "puts it at the bottom of the provider's card" do
            expect(card_codes(result_cards.cards)).to eq([%w[A001 A002], %w[B001]])
          end
        end
      end
    end

    context "when the provider's fee courses are split across 2 cards" do
      before do
        create_fee_course(provider: ashford, course_code: "A001", fee: 9_000)
        create_fee_course(provider: bexley, course_code: "B001", fee: 10_000)
        create_fee_course(provider: ashford, course_code: "A002", fee: 12_000)
        create_course(provider: ashford, course_code: "A003", funding: "salary")
      end

      it "puts the salaried course at the bottom of the last one" do
        expect(card_codes(result_cards.cards)).to eq([%w[A001], %w[B001], %w[A002 A003]])
      end

      it "shows each course exactly once across the pages" do
        pages = [1, 2, 3, 4].map { |page| result_cards(page:, per_page: 1) }

        expect(pages.map { |page| card_codes(page.cards) }).to eq([[%w[A001]], [%w[B001]], [%w[A002 A003]], []])
        expect(pages.map(&:count).uniq).to eq([3])
      end
    end

    context "when a provider has several salaried courses of the subject" do
      before do
        create_fee_course(provider: ashford, course_code: "A001", fee: 9_000)
        create_fee_course(provider: bexley, course_code: "B001", fee: 10_000)
        create_course(provider: ashford, course_code: "A002", funding: "salary")
        create_course(provider: ashford, course_code: "A003", funding: "apprenticeship")
      end

      it "keeps them in the order of the search, under the fee courses" do
        search_order = Courses::Query.call(params: params.dup).map(&:course_code) & %w[A002 A003]

        expect(card_codes(result_cards.cards)).to eq([["A001", *search_order], %w[B001]])
      end
    end

    context "when a provider only has salaried courses of the subject" do
      before do
        create_fee_course(provider: ashford, course_code: "A001", fee: 9_000)
        create_course(provider: camden, course_code: "C001", funding: "salary")
        create_fee_course(provider: bexley, course_code: "B001", fee: 10_000)
      end

      it "leaves them at the end, on a card of their own" do
        expect(card_codes(result_cards.cards)).to eq([%w[A001], %w[B001], %w[C001]])
      end
    end

    context "when the provider's salaried course is of another subject" do
      before do
        create_fee_course(provider: ashford, course_code: "A001", fee: 9_000)
        create_fee_course(provider: bexley, course_code: "B001", fee: 10_000)
        create_course(provider: ashford, course_code: "A002", subject: physics, funding: "salary")
      end

      it "leaves it at the end, on a card of its own" do
        expect(card_codes(result_cards.cards)).to eq([%w[A001], %w[B001], %w[A002]])
      end
    end

    context "when sorting by something other than fee" do
      let(:params) { { order: "course_name_ascending" } }

      before do
        create_course(provider: ashford, course_code: "A001", name: "Mathematics")
        create_course(provider: bexley, course_code: "B001", name: "Mathematics (SEND)")
        create_course(provider: ashford, course_code: "A002", name: "Mathematics with Economics", funding: "salary")
      end

      it "leaves the salaried course where the sort puts it" do
        expect(card_codes(result_cards.cards)).to eq([%w[A001], %w[B001], %w[A002]])
      end
    end
  end

  context "when a provider's subjects are at the same distance" do
    let(:params) { { latitude: 52.4862, longitude: -1.8904, radius: 10, order: "distance" } }

    before do
      school = create(:gias_school, latitude: 52.4862, longitude: -1.8904)

      [mathematics, physics, mathematics, physics].each_with_index do |subject, index|
        course = create_course(provider: ashford, course_code: "A00#{index}", subject:)
        create(:course_school, course:, gias_school: school)
      end
    end

    it "keeps each subject on one card" do
      expect(result_cards.cards.map { |card| card.map(&:master_subject_id).uniq }).to contain_exactly([mathematics.id], [physics.id])
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

    it "still counts cards past the last page" do
      expect(result_cards(page: 3, per_page: 2).count).to eq(3)
    end

    it "numbers the cards once for a page's courses and card count" do
      page = result_cards(page: 1, per_page: 2)
      numbering_queries = []
      subscriber = ActiveSupport::Notifications.subscribe("sql.active_record") do |*, payload|
        numbering_queries << payload[:sql] if payload[:sql].include?("ROW_NUMBER()")
      end

      page.courses
      page.count

      expect(numbering_queries.size).to eq(1)
    ensure
      ActiveSupport::Notifications.unsubscribe(subscriber)
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

        # Every course here is fee-paying. Under the fee sorts, a salaried
        # course can move up to its provider's card, ahead of the search's order.
        it "groups the results in the order of the search" do
          cards = result_cards

          expect(cards.count).to be_between(2, 3)
          expect(cards.courses.map(&:id)).to eq(Courses::Query.call(params: params.dup).map(&:id))
        end
      end
    end
  end
end
