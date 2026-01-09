# frozen_string_literal: true

namespace :family_group do
  desc '管理者が存在しない家族グループに管理者を自動付与する'
  task backfill_admin: :environment do
    FamilyGroup.find_each do |group|
      # すでに管理者がいるグループはスキップ
      next if group.family_group_memberships.exists?(is_admin: true)

      # 最初に参加したメンバーを管理者にする
      membership = group.family_group_memberships.order(:created_at).first
      next unless membership

      membership.update!(is_admin: true)

      puts "✔ 管理者付与: family_group_id=#{group.id}, user_id=#{membership.user_id}"
    end
  end
end
