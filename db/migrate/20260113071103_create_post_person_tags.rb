class CreatePostPersonTags < ActiveRecord::Migration[7.2]
  def change
    create_table :post_person_tags do |t|
      t.references :post, null: false, foreign_key: true
      t.references :person_tag, null: false, foreign_key: true

      t.timestamps
    end

    add_index :post_person_tags, [:post_id, :person_tag_id], unique: true
  end
end
