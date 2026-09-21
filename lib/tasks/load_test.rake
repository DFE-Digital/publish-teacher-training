# frozen_string_literal: true

namespace :load_test do
  desc "Publish rolled over courses in a recruitment cycle, so a load test runs against a realistic catalogue"
  task :publish_cycle, %i[year target user_email] => :environment do |_task, args|
    if Settings.environment.name == "production"
      abort "load_test:publish_cycle does not run in production. It publishes courses on behalf of providers."
    end

    year = Integer(args[:year] || Find::CycleTimetable.next_year)
    target = args[:target].present? ? Integer(args[:target]) : nil

    user = if args[:user_email].present?
             User.admins.find_by!(email: args[:user_email])
           else
             User.admins.first
           end

    abort "No admin user found. Pass one: rake 'load_test:publish_cycle[#{year},#{target},you@example.com]'" if user.nil?

    courses = Course.with_recruitment_cycle(year)
    published_before = courses.published.count

    if target && published_before >= target
      puts "Cycle #{year} has #{published_before} published courses. The target of #{target} is already met."
      next
    end

    candidates = courses
      .where(id: CourseEnrichment.draft.select(:course_id))
      .where.not(id: CourseEnrichment.published.select(:course_id))

    wanted = target ? target - published_before : candidates.count

    puts "Cycle #{year}: #{published_before} published, #{candidates.count} rolled over or draft."
    puts "Publishing up to #{wanted} courses as #{user.email}."

    # Bulk publishing would send one email for every course. The load test only
    # needs the data, so stop the notification before it reaches the mailer.
    NotificationService::CoursePublished.define_singleton_method(:call) { |**| false }

    published = 0
    skipped = 0

    candidates.find_each(batch_size: 500) do |course|
      break if published >= wanted

      if Courses::PublishService.new(course:, user:).call
        published += 1
      else
        skipped += 1
      end

      puts "  #{published} published, #{skipped} skipped" if ((published + skipped) % 500).zero?
    end

    puts "Published #{published} courses. Skipped #{skipped} that were not publishable."
    puts "Cycle #{year} now has #{courses.published.count} published and #{courses.findable.distinct.count} findable courses."
  end
end
