class AntsAdminCreateAntsAdminLibraries < ActiveRecord::Migration
  def change
    create_table :ants_admin_libraries do |t|
      t.string :title
      t.attachment :photo

      t.timestamps
    end
  end
end
