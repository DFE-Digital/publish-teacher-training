name "provider"
summary "Operate on providers via the V1 API"
default_subcommand "list"

option :a, :all, "Perform on all providers, not just the first page returned.",
       default: false
option :c, :'changed-since', "Perform only on providers changed since this date",
       argument: :required
