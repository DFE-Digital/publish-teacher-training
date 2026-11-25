# frozen_string_literal: true

module Courses
  # Groups Find search results into cards and pages through them by card.
  #
  # A card is a run of courses that sit next to each other in the sorted
  # results and have the same training provider and main subject. The sort
  # comes first, so a provider whose courses are split by another provider's
  # course gets more than one card. The fee sorts are the exception: they put
  # salaried and apprenticeship courses last, so those join the bottom of their
  # provider's last fee card for the subject instead.
  #
  # Cards are numbered in the database with window functions over the sorted
  # results, so only the courses on the requested page are loaded.
  class ResultCards
    Row = Data.define(:course_id, :card_number, :total_cards)

    FEE_SORTS = %w[fee_uk_ascending fee_intl_ascending].freeze

    def initialize(query:, page:, per_page:)
      @query = query
      @page = page
      @per_page = per_page
    end

    # Number of cards across every page. Every row carries it.
    def count
      @count ||= rows.first&.total_cards || 0
    end

    # The courses on this page's cards, in card order.
    def courses
      @courses ||= card_numbers.empty? ? [] : @query.scope.where(course: { id: card_numbers.keys }).sort_by { |course| card_positions.fetch(course.id) }
    end

    # The courses on this page, one array per card.
    def cards
      courses.chunk_while { |course, next_course| card_numbers[course.id] == card_numbers[next_course.id] }.to_a
    end

  private

    def card_numbers
      @card_numbers ||= rows
        .select { |row| row.card_number.between?(first_card, last_card) }
        .to_h { |row| [row.course_id, row.card_number] }
    end

    def card_positions
      @card_positions ||= card_numbers.keys.each_with_index.to_h
    end

    # A Row for each course on this page, plus the first course in the results
    # so the total comes back even on a page past the last card.
    #
    # Each level is a relation rather than SQL built from strings, so the
    # search's values (a provider name with a "?", say) are never read as bind
    # markers. Only the page condition is sanitised.
    def rows
      @rows ||= Course.unscoped
        .from(numbered_cards, :cards)
        .where("card_number BETWEEN ? AND ? OR position = 1", first_card, last_card)
        .order(Arel.sql("cards.position"))
        .pluck(Arel.sql("cards.id"), Arel.sql("cards.card_number"), Arel.sql("cards.total_cards"))
        .map { |course_id, card_number, total_cards| Row.new(course_id:, card_number:, total_cards:) }
    end

    # Adds up the card starts: a running total gives each course its card
    # number, and a total over every course gives the number of cards.
    def numbered_cards
      Course.unscoped.from(marked_courses, :marked).select(<<~SQL)
        marked.id, marked.position,
        SUM(starts_card) OVER (ORDER BY position) AS card_number,
        SUM(starts_card) OVER () AS total_cards
      SQL
    end

    # Marks each course that starts a new card: the first course, and any
    # course whose provider or main subject differs from the course before it.
    def marked_courses
      Course.unscoped.from(positioned_courses, :ranked).select(<<~SQL)
        ranked.id, ranked.position,
        CASE WHEN (provider_id, master_subject_id) IS NOT DISTINCT FROM
                  (LAG(provider_id) OVER (ORDER BY position), LAG(master_subject_id) OVER (ORDER BY position))
             THEN 0 ELSE 1 END AS starts_card
      SQL
    end

    def positioned_courses
      fee_sort? ? salaried_after_fee_courses : ranked_courses
    end

    # Moves each salaried or apprenticeship course to just after the last fee
    # course with its provider and main subject. The fee sorts already put it
    # after every fee course, so ordering by that position, then its own, keeps
    # it below them. A course with no fee course to join stays where it was.
    def salaried_after_fee_courses
      Course.unscoped.from(anchored_courses, :anchored).select(<<~SQL)
        anchored.id, anchored.provider_id, anchored.master_subject_id,
        ROW_NUMBER() OVER (ORDER BY COALESCE(anchor, position), position) AS position
      SQL
    end

    def anchored_courses
      Course.unscoped.from(ranked_courses, :ranked).select(<<~SQL)
        ranked.id, ranked.provider_id, ranked.master_subject_id, ranked.position,
        CASE WHEN funding <> 'fee'
             THEN MAX(position) FILTER (WHERE funding = 'fee') OVER (PARTITION BY provider_id, master_subject_id)
        END AS anchor
      SQL
    end

    # Each course's position in the search's sort order.
    def ranked_courses
      @query.scope
        .unscope(:select, :order)
        .select("course.id, course.provider_id, course.master_subject_id, course.funding, ROW_NUMBER() OVER (ORDER BY #{@query.order_sql}) AS position")
    end

    def fee_sort?
      FEE_SORTS.include?(@query.applied_scopes[:order])
    end

    def first_card
      ((@page - 1) * @per_page) + 1
    end

    def last_card
      @page * @per_page
    end
  end
end
