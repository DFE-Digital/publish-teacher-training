namespace :allocations do
  desc "Copy previous allocations data to allocation cycle year: rake allocations:copy_allocations_data_to_cycle_year"
  task :copy_allocations_data_to_cycle_year, [:allocation_cycle_year] => :environment do |_task, args|
    raise "Requires allocation cycle year" if args[:allocation_cycle_year].to_i.zero?
    AllocationCopyDataService.call(allocation_cycle_year: args[:allocation_cycle_year], summary: true)
  end
end
