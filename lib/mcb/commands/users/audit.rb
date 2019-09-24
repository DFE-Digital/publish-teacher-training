summary "Show changes made to a user record"
param :id_or_email_or_sign_in_id
usage "audit <id>"

run do |opts, args, _cmd|
  MCB.init_rails(opts)

  user = MCB.find_user_by_identifier args[:id_or_email_or_sign_in_id]

  table = Tabulo::Table.new user.audits do |t|
    t.add_column(:user_id, header: "user\nid", width: 6)
    t.add_column(:user, header: "user email") { |a| a.user&.email }
    t.add_column(:action, width: 8)
    t.add_column(:associated_id, header: "associated\nid", width: 10)
    t.add_column(:associated_type, header: "associated\ntype", width: 10)
    t.add_column(:audited_changes,
                 header: "changes",
                 formatter: ->(v) { PP.pp(v, StringIO.new, 40).string },
                 width: 40)
    t.add_column(:created_at, width: 23)
  end
  puts table.pack(max_table_width: nil)
end
