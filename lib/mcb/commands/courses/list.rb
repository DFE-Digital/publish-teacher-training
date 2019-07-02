name 'list'
summary 'List courses in db'

run do |opts, args, _cmd|
  MCB.init_rails(opts)

  courses = if args.any?
              Course.where(course_code: args.to_a.map(&:upcase))
            else
              Course.all
            end

  tp.set :capitalize_headers, false

  output = [
    '',
    'Course:',
    Tabulo::Table.new(courses) { |t|
      t.add_column :id
      t.add_column(:provider_code) { |c| c.provider.provider_code }
      t.add_column :course_code
      t.add_column :name
    }.pack(max_table_width: nil)
  ]
  MCB.pageable_output(output)
end
