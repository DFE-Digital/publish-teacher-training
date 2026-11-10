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
      @count ||= connection.select_value("SELECT COALESCE(SUM(starts_card), 0) FROM (#{marked_sql}) marked").to_i
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
      @card_numbers ||= connection.select_rows(page_sql).to_h { |id, card_number| [id.to_i, card_number.to_i] }
    end

    def page_sql
      Course.sanitize_sql_array([<<~SQL, first_card, last_card])
        SELECT id, card_number
        FROM (
          SELECT id, SUM(starts_card) OVER (ORDER BY position) AS card_number
          FROM (#{marked_sql}) marked
        ) cards
        WHERE card_number BETWEEN ? AND ?
      SQL
    end

    # Marks each course that starts a new card: the first course, and any
    # course whose provider or main subject differs from the course before it.
    def marked_sql
      <<~SQL
        SELECT id, position,
               CASE WHEN (provider_id, master_subject_id) IS NOT DISTINCT FROM
                         (LAG(provider_id) OVER previous, LAG(master_subject_id) OVER previous)
                    THEN 0 ELSE 1 END AS starts_card
        FROM (#{ranked_sql}) ranked
        WINDOW previous AS (ORDER BY position)
      SQL
    end

    # Each course's position in the search's sort order.
    def ranked_sql
      @query.scope
        .unscope(:select, :order)
        .select("course.id, course.provider_id, course.master_subject_id, ROW_NUMBER() OVER (ORDER BY #{@query.order_sql}) AS position")
        .to_sql
    end

    def first_card
      ((@page - 1) * @per_page) + 1
    end

    def last_card
      @page * @per_page
    end

    def connection
      Course.connection
    end
  end
end
