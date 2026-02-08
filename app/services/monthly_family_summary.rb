# frozen_string_literal: true

class MonthlyFamilySummary
  def self.call(family_group:, month:)
    new(family_group: family_group, month: month).call
  end

  def initialize(family_group:, month:)
    @family_group = family_group
    @month = month
    @from = month.beginning_of_month
    @to = month.end_of_month
  end

  def call
    target_tags = identify_target_tags
    posts = fetch_monthly_posts

    appear_counts = count_appearances(target_tags, posts)
    total_memories = posts.count

    build_result(total_memories, appear_counts)
  end

  private

  def identify_target_tags
    find_parent_tags
    find_child_tags
    [@father_tag, @mother_tag].compact + @child_tags.to_a
  end

  def find_parent_tags
    memberships =
      @family_group.family_group_memberships
                   .includes(:user)
                   .where(role: %i[father mother])

    @father_tag = find_tag_by_role(memberships, 'father')
    @mother_tag = find_tag_by_role(memberships, 'mother')
  end

  def find_tag_by_role(memberships, role)
    user = memberships.find { |m| m.role == role }&.user
    return nil unless user

    @family_group.person_tags.find_by(name: user.name)
  end

  def find_child_tags
    child_names = @family_group.children.pluck(:name)
    @child_tags = @family_group.person_tags.where(name: child_names)
  end

  # ✅ 投稿は album.family_group_id で確定する（混入防止）
  def fetch_monthly_posts
    Post
      .joins(:album)
      .where(albums: { family_group_id: @family_group.id })
      .where(photo_date: @from..@to)
      .distinct
  end

  def count_appearances(target_tags, posts)
    return {} if target_tags.empty?

    post_ids = posts.pluck(:id)
    return {} if post_ids.empty?

    PostPersonTag
      .where(person_tag_id: target_tags.map(&:id), post_id: post_ids)
      .group(:person_tag_id)
      .count('DISTINCT post_id')
  end

  def build_result(total_memories, appear_counts)
    {
      month: @month,
      total_memories: total_memories,
      appear: build_appear_stats(appear_counts),
      post_counts: build_post_counts
    }
  end

  def build_appear_stats(appear_counts)
    {
      father: count_for(@father_tag, appear_counts),
      mother: count_for(@mother_tag, appear_counts),
      children: build_children_stats(appear_counts)
    }
  end

  def count_for(tag, counts)
    tag ? (counts[tag.id] || 0) : 0
  end

  def build_children_stats(appear_counts)
    stats = @child_tags.map do |t|
      { name: t.name, count: appear_counts[t.id] || 0 }
    end
    stats.sort_by { |h| -h[:count] }
  end

  def build_post_counts
    counts = count_by_role
    {
      father: counts['father'] || counts[:father] || 0,
      mother: counts['mother'] || counts[:mother] || 0
    }
  end

  # ✅ 投稿スコープ（album）を揃えたうえで、投稿者roleを membership で集計
  def count_by_role
    scoped_posts_by_role
      .group('family_group_memberships.role')
      .count
  end

  def scoped_posts_by_role
    Post
      .joins(:album)
      .joins(user: :family_group_memberships)
      .where(albums: { family_group_id: @family_group.id })
      .where(family_group_memberships: membership_scope)
      .where(photo_date: @from..@to)
  end

  def membership_scope
    {
      family_group_id: @family_group.id,
      # シンボルを整数値に変換する
      role: FamilyGroupMembership.roles.values_at(:father, :mother)
    }
  end
end
