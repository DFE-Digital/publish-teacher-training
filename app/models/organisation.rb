class Organisation < ApplicationRecord
  self.table_name = "organisation"

  belongs_to :org
end
