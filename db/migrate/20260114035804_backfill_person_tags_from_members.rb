class BackfillPersonTagsFromMembers < ActiveRecord::Migration[7.2]
  def up
    say_with_time "Backfilling person_tags from FamilyGroup members" do
      FamilyGroup.find_each do |family_group|
        # 家族グループに属するユーザーからタグを作成
        family_group.users.find_each do |user|
          PersonTag.find_or_create_by!(
            family_group_id: family_group.id,
            name: user.name
          )
        end

        # 子どもモデルがある場合はそこからもタグを作成
        if family_group.respond_to?(:children)
          family_group.children.find_each do |child|
            PersonTag.find_or_create_by!(
              family_group_id: family_group.id,
              name: child.name
            )
          end
        end
      end
    end
  end

  def down
    # ロールバック時の挙動は特に不要なので空でOK
  end
end
