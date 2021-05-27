class AllocationCopyDataService
  include ServicePattern

  def initialize(allocation_cycle_year:, summary: false)
    @allocation_cycle_year = allocation_cycle_year
    @summary = summary
  end

  def call
    copied = 0
    skipped = 0

    Allocation.where(recruitment_cycle_id: previous_allocation_cycle.id).find_each do |prev_alloc|
      if prev_alloc.confirmed_number_of_places.to_i.zero? ||
          allocation_exists?(prev_alloc)
        skipped += 1
      else
        provider = find_provider(prev_alloc)
        accredited_body = find_accredited_body(prev_alloc)
        create_allocation(prev_alloc, provider, accredited_body)
        copied += 1
      end
    end

    if @summary
      puts "###################################"
      puts "## Allocation copying task complete"
      puts "# copied: #{copied}"
      puts "# skipped: #{skipped}"
      puts "###################################"
    end
  end

private

  def create_allocation(prev_alloc, provider, accredited_body)
    Allocation.create!(
      provider_code: prev_alloc.provider_code,
      accredited_body_code: prev_alloc.accredited_body_code,
      recruitment_cycle_id: allocation_cycle.id,

      provider_id: provider.id,
      accredited_body_id: accredited_body.id,

      number_of_places: prev_alloc.confirmed_number_of_places,
      confirmed_number_of_places: nil,
    )
  end

  def find_provider(prev_alloc)
    # Fetch new provider with same code for current recruitment cycle
    Provider.where(
      provider_code: prev_alloc.provider_code,
      recruitment_cycle_id: allocation_cycle.id,
    ).first!
  end

  def find_accredited_body(prev_alloc)
    # Fetch new accredited_body with same code for current recruitment cycle
    Provider.where(
      provider_code: prev_alloc.accredited_body_code,
      recruitment_cycle_id: allocation_cycle.id,
      accrediting_provider: :accredited_body,
    ).first!
  end

  def allocation_exists?(prev_alloc)
    Allocation.where(
      provider_code: prev_alloc.provider_code,
      accredited_body_code: prev_alloc.accredited_body_code,
      recruitment_cycle_id: allocation_cycle.id,
    ).exists?
  end

  def allocation_cycle
    @allocation_cycle ||= RecruitmentCycle.where(year: @allocation_cycle_year).first!
  end

  def previous_allocation_cycle
    allocation_cycle.previous
  end
end
