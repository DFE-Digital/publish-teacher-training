class AddUkprnToGIASEstablishmentsTable < ActiveRecord::Migration[6.1]
  def change
    add_column :gias_establishment, :ukprn, :text
  end
end
