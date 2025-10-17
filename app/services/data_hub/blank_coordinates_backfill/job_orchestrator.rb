# frozen_string_literal: true

module DataHub
  module BlankCoordinatesBackfill
    class JobOrchestrator
      # Below the 50 requests per second rate limit
      DEFAULT_BATCH_SIZE = 40
      # Safe interval space between batches
      MIN_SECONDS_BETWEEN_BATCHES = 10
      # Start monitoring after last batch + buffer
      MONITORING_DELAY = 5.minutes

      attr_reader :recruitment_cycle_year, :dry_run, :query, :total_records, :recruitment_cycle

      def self.start_backfill(recruitment_cycle_year, dry_run: false)
        new(recruitment_cycle_year, dry_run:).execute
      end

      def initialize(recruitment_cycle_year, dry_run: false)
        @recruitment_cycle_year = recruitment_cycle_year
        @dry_run = dry_run
        @recruitment_cycle = RecruitmentCycle.find_by(year: recruitment_cycle_year)
        @query = Query.new(recruitment_cycle)
        @total_records = @query.total_count
      end

      def execute
        Log.info("Orchestration starting for cycle year=#{recruitment_cycle_year}, dry_run=#{dry_run}, total_records=#{total_records}")

        return handle_no_records if total_records.zero?

        initialize_process_summary
        batches_info = calculate_batch_schedule
        schedule_batches(batches_info)
        schedule_monitoring(batches_info)
        update_scheduling_complete(batches_info)

        Log.info("Orchestration complete: scheduled #{batches_info.size} batches across #{total_records} records")
        @process_summary
      rescue StandardError => e
        Log.error("Orchestration error: #{e.message}")
        Log.error(e.backtrace.first(5).join("\n"))
        @process_summary&.fail!(e)
        raise
      end

    private

      def handle_no_records
        Log.info("✓ No records need backfilling")
        nil
      end

      def initialize_process_summary
        @process_summary = DataHub::BlankCoordinatesBackfillProcessSummary.start!
        @process_summary.initialize_summary!(
          total_records: total_records,
          batch_size: DEFAULT_BATCH_SIZE,
          dry_run: dry_run,
        )
        Log.info("ProcessSummary created: ID=#{@process_summary.id}")
      end

      def calculate_batch_schedule
        batches = query.call.each_slice(DEFAULT_BATCH_SIZE).to_a
        batch_count = batches.size

        # Breathing space: add 1 second per 250 batches for extra margin
        interval = MIN_SECONDS_BETWEEN_BATCHES + [batch_count / 250, 10].min
        now = Time.current

        Log.info("Calculated batch schedule: #{batch_count} batches, #{interval}s interval")

        batches.each_with_index.map do |batch, i|
          { batch: batch, at: now + (i * interval).seconds }
        end
      end

      def schedule_batches(batches_info)
        Log.info("Scheduling #{batches_info.size} batches...")

        batches_info.each_with_index do |info, idx|
          Log.info("Batch #{idx + 1}/#{batches_info.size}: #{info[:batch].size} records at #{info[:at].strftime('%H:%M:%S')}")

          ::BlankCoordinatesBackfill::BatchJob.set(wait_until: info[:at]).perform_later(
            info[:batch],
            @process_summary.id,
            dry_run,
          )

          @process_summary.add_batch_enqueue_info(
            batch_number: idx + 1,
            scheduled_at: info[:at],
            records_count: info[:batch].size,
          )
        end
      end

      def schedule_monitoring(batches_info)
        monitoring_delay_seconds = (batches_info.last[:at] - Time.current).to_i + MONITORING_DELAY.to_i
        attempt_number = 1

        ::BlankCoordinatesBackfill::MonitoringJob.set(wait: monitoring_delay_seconds.seconds).perform_later(
          @process_summary.id,
          attempt_number,
        )

        monitoring_start_time = batches_info.last[:at] + MONITORING_DELAY
        Log.info("Scheduled monitoring to start in #{monitoring_delay_seconds / 60} minutes " \
                 "(at #{monitoring_start_time.strftime('%H:%M:%S')})")
      end

      def update_scheduling_complete(batches_info)
        estimated_completion = batches_info.last[:at] +
          MONITORING_DELAY +
          (MonitoringManager::MAX_ATTEMPTS * MonitoringManager::CHECK_INTERVAL)

        # Calculate interval between first and second batch
        batch_interval_seconds = if batches_info.size > 1
                                   (batches_info[1][:at] - batches_info[0][:at]).to_i
                                 else
                                   0
                                 end

        @process_summary.update!(
          short_summary: @process_summary.short_summary.merge(
            batches_scheduled: batches_info.size,
            batch_size: DEFAULT_BATCH_SIZE,
            batch_interval_seconds:,
            estimated_completion_time: estimated_completion.iso8601,
            scheduling_completed_at: Time.current.iso8601,
          ),
        )

        Log.info("Estimated completion: #{estimated_completion.strftime('%Y-%m-%d %H:%M:%S')}")
      end
    end
  end
end
