class BackfillFamilyGroupMemberships < ActiveRecord::Migration[7.2]
  def up
    say_with_time "Backfilling family_group_memberships from users.family_group_id" do
      execute <<~SQL
        INSERT INTO family_group_memberships (user_id, family_group_id, created_at, updated_at)
        SELECT id, family_group_id, NOW(), NOW()
        FROM users
        WHERE family_group_id IS NOT NULL
        ON CONFLICT (user_id, family_group_id) DO NOTHING;
      SQL
    end
  end

  # 既存データを消すのは危険なので、基本は戻さない（空でOK）
  def down
  end
end
