# frozen_string_literal: true

module Courses
  # Groups Find search results into cards and pages through them by card.
  #
  # A card is a run of courses that sit next to each other in the sorted
  # results and have the same training provider and main subject. The sort
  # comes first, so a provider whose courses are split by another provider's
  # course gets more than one card.
  #
  # Cards are numbered in the database with window functions over the sorted
  # results, so only the courses on the requested page are loaded.
  class ResultCards
    def initialize(query:, page:, per_page:)
      @query = query
      @page = page
      @per_page = per_page
    end

    # Number of cards across every page.
    def count
      @count ||= rows.first&.last || 0
    end

    # The courses on this page's cards, in the order of the search.
    def courses
      @courses ||= card_numbers.empty? ? [] : @query.scope.where(course: { id: card_numbers.keys }).to_a
    end

    # The courses on this page, one array per card.
    def cards
      courses.chunk_while { |course, next_course| card_numbers[course.id] == card_numbers[next_course.id] }.to_a
    end

  private

    def card_numbers
      @card_numbers ||= rows
        .select { |_id, card_number, _total_cards| card_number.between?(first_card, last_card) }
        .to_h { |id, card_number, _total_cards| [id, card_number] }
    end

    # [course id, card number, total cards] for each course on this page, plus
    # the first course in the results so the total comes back even on a page
    # past the last card.
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
      Course.unscoped.from(ranked_courses, :ranked).select(<<~SQL)
        ranked.id, ranked.position,
        CASE WHEN (provider_id, master_subject_id) IS NOT DISTINCT FROM
                  (LAG(provider_id) OVER (ORDER BY position), LAG(master_subject_id) OVER (ORDER BY position))
             THEN 0 ELSE 1 END AS starts_card
      SQL
    end

    # Each course's position in the search's sort order.
    def ranked_courses
      @query.scope
        .unscope(:select, :order)
        .select("course.id, course.provider_id, course.master_subject_id, ROW_NUMBER() OVER (ORDER BY #{@query.order_sql}) AS position")
    end

    def first_card
      ((@page - 1) * @per_page) + 1
    end

    def last_card
      @page * @per_page
    end
  end
end
