# frozen_string_literal: true

# Be sure to restart your server when you modify this file.

# Add new inflection rules using the following format. Inflections
# are locale specific, and you may define rules for as many different
# locales as you wish. All of these examples are active by default:
# ActiveSupport::Inflector.inflections(:en) do |inflect|
#   inflect.plural /^(ox)$/i, "\\1en"
#   inflect.singular /^(ox)en/i, "\\1"
#   inflect.irregular "person", "people"
#   inflect.uncountable %w( fish sheep )
# end

# These inflection rules are supported but not enabled by default:
# ActiveSupport::Inflector.inflections(:en) do |inflect|
#   inflect.acronym "RESTful"
# end

ActiveSupport::Inflector.inflections do |inflect|
  inflect.acronym "API"
  inflect.acronym "CSV"
  inflect.acronym "URN"
  inflect.acronym "PGDE"
  inflect.acronym "UCAS"
  inflect.acronym "MFL" # Modern foreign languages
  inflect.acronym "DFE" # Department for Education
  inflect.acronym "DfE" # Department for Education
  inflect.acronym "SCITT" # School-Centred Initial Teacher Training
  inflect.acronym "QA"
end
