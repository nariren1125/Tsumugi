class BackfillFamilyGroupMemberships < ActiveRecord::Migration[7.2]
  def up
    say_with_time "Backfilling family_group_memberships from users.family_group_id" do
      User.where.not(family_group_id: nil).find_each do |user|
        FamilyGroupMembership.find_or_create_by!(
          user_id: user.id,
          family_group_id: user.family_group_id
        )
      end
    end
  end

  # 既存データを消すのは危険なので、基本は戻さない（空でOK）
  def down
  end
end
