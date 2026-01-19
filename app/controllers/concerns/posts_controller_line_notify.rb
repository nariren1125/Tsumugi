# frozen_string_literal: true

# LINE通知関連だけを分離（行数制限対策）
module PostsControllerLineNotify
  extend ActiveSupport::Concern

  private

  def line_notifier
    @line_notifier ||= LineNotifier.new
  end

  def recipient_uids_for(post)
    family_group = post.album.family_group
    return [] unless family_group

    family_group.users.reject { |u| u.id == current_user.id || u.line_uid.blank? }.map(&:line_uid)
  end

  def notify_family_group_members(post)
    notifier = line_notifier
    recipient_uids_for(post).each { |uid| notifier.push_flex_message(uid, post) }
  end

  def notify_family_group_members_safely(post)
    notify_family_group_members(post)
  rescue StandardError => e
    Rails.logger.warn("[LINE notify failed] post_id=#{post.id} error=#{e.class} message=#{e.message}")
  end
end
