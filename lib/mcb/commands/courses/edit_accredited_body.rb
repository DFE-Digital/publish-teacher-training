name 'edit_accredited_body'
summary 'Edit accredited bodies on courses directly in the DB'
usage 'edit_accredited_body <provider_code>'
param :provider_code, transform: ->(code) { code.upcase }

run do |opts, args, _cmd|
  MCB.init_rails(opts)

  provider = Provider.find_by!(provider_code: args[:provider_code])
  cli = HighLine.new

  finished = false
  until finished
    chosen_body = nil
    accredited_bodies = provider.courses.collect(&:accrediting_provider).uniq.sort_by { |p| p&.provider_name || "" }

    cli.choose do |menu|
      menu.prompt = "Change the accredited body on courses for #{provider.provider_code}"
      menu.choice(:exit) { finished = true }

      accredited_bodies.each do |body|
        if body.present?
          menu.choice("Replace #{body.provider_name} (#{body.provider_code})") { chosen_body = body }
        else
          menu.choice("Make self-accredited courses consistent") { chosen_body = :fix_nulls }
        end
      end
    end

    case chosen_body
    when Provider
      new_accredited_body_code = cli.ask("What's the provider code of the new accredited provider?  ") {|a| a.default = provider.provider_code }
      new_accredited_body = Provider.find_by!(provider_code: new_accredited_body_code.strip)
      affected_courses = provider.courses.where(accrediting_provider: chosen_body)

      puts "Changing accredited body from #{chosen_body.provider_code} to #{new_accredited_body_code} on the following courses:"
      puts affected_courses.pluck(:course_code).join(", ")

      if cli.agree("Continue? ")
        provider.courses.where(accrediting_provider: chosen_body).each {|c| c.update(accrediting_provider: new_accredited_body) }
      end
    when Symbol
      affected_courses = provider.courses.where(accrediting_provider: nil)

      puts "Changing accredited body from nil to #{provider.provider_code} on the following courses:"
      puts affected_courses.pluck(:course_code).join(", ")

      if cli.agree("Continue? ")
        provider.courses.where(accrediting_provider: nil).each {|c| c.update(accrediting_provider: provider) }
      end
    end

    chosen_body = nil
    provider.reload
  end
end
