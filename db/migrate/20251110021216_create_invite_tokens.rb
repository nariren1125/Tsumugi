class CreateInviteTokens < ActiveRecord::Migration[7.2]
  def change
    create_table :invite_tokens do |t|
      t.references :family_group, null: false, foreign_key: true
      t.string :token
      t.datetime :expires_at

      t.timestamps
    end
  end
end
