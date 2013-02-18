class CreatePages < ActiveRecord::Migration
  def change
    create_table :pages do |t|
      t.string :url
      t.string :title
      t.string :thumbnail
      t.text :description

      t.timestamps
    end
  end
end
