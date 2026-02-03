class CreateBillOfLadings < ActiveRecord::Migration[7.2]
  def change
    create_table :bill_of_ladings, id: :bigint do |t|
      t.belongs_to :customer, index: true, foreign_key: true, comment: 'Legacy id_client'

      t.string :bl_number, null: false, comment: 'Legacy bl_number'
      t.datetime :arrival_date, null: false, comment: 'Legacy arrival_date'
      t.integer :freetime, null: false, default: 0, comment: 'Free time in days'

      # Container counts - renamed from legacy nbre_* columns
      # nbre_20, nbre_40, nbre_40hc, nbre_45, nbre_reefer, nbre_ot do not exist in the schema
      # but are referenced as key columns so, using here as descriptive names and
      # conversion from legacy columns can be handled in during data migration
      t.integer :number_of_20ft_containers, default: 0, comment: 'Translation for legacy nbre_20'
      t.integer :number_of_40ft_containers, default: 0, comment: 'Translation for legacy nbre_40'
      t.integer :number_of_40ft_high_cube_containers, default: 0, comment: 'Translation for legacy nbre_40hc'
      t.integer :number_of_45ft_containers, default: 0, comment: 'Translation for legacy nbre_45'
      t.integer :number_of_reefer_containers, default: 0, comment: 'Translation for legacy nbre_reefer'
      t.integer :number_of_other_containers, default: 0, comment: 'Translation for legacy nbre_ot'

      t.timestamps
    end

    add_index :bill_of_ladings, :arrival_date
    add_index :bill_of_ladings, :bl_number, unique: true
  end
end
