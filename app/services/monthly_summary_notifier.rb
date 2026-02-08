# frozen_string_literal: true

class MonthlySummaryNotifier
  def self.call(family_group:, month:, dry_run: false)
    new(family_group: family_group, month: month, dry_run: dry_run).call
  end

  def initialize(family_group:, month:, dry_run:)
    @family_group = family_group
    @month = month
    @dry_run = dry_run
    @line_notifier = LineNotifier.new
  end

  def call
    father, mother = find_target_parents
    unless father && mother
      log_skip('parents missing or LINE not linked')
      return
    end

    summary = MonthlyFamilySummary.call(family_group: @family_group, month: @month)
    text = LineMonthlySummaryMessageBuilder.build(summary)

    deliver(father, text)
    deliver(mother, text)
  end

  private

  def find_target_parents
    memberships =
      @family_group.family_group_memberships
                   .includes(:user)
                   .where(role: %i[father mother])

    father = find_parent_user(memberships, 'father')
    mother = find_parent_user(memberships, 'mother')

    return [nil, nil] if father.nil? || mother.nil?
    return [nil, nil] if father.line_uid.blank? || mother.line_uid.blank?

    [father, mother]
  end

  def find_parent_user(memberships, role)
    memberships.find { |m| m.role == role }&.user
  end

  def deliver(user, text)
    if @dry_run
      log_dry_run(user, text)
      return
    end

    Rails.logger.info("Sending monthly summary to User(#{user.id}: #{user.name})")
    @line_notifier.push_text_message(user.line_uid, text)
  end

  # log_dry_run の AbcSize を下げる
  def log_dry_run(user, text)
    log_lines(dry_run_lines(user, text))
  end

  def dry_run_lines(user, text)
    [
      '----------------------------------------',
      '=== [DRY RUN] MonthlySummaryNotifier ===',
      "family_group: #{@family_group.id} #{@family_group.name}",
      "month: #{@month.strftime('%Y-%m')}",
      "to: #{user.id} #{user.name} line_uid=#{user.line_uid}",
      '----------------------------------------',
      *text.to_s.lines.map(&:chomp),
      '----------------------------------------'
    ]
  end

  def log_lines(lines)
    lines.each { |line| Rails.logger.info(line) }
  end

  def log_skip(reason)
    Rails.logger.info(
      "FamilyGroup(#{@family_group.id}, #{@family_group.name}): Skip (#{reason})"
    )
  end
end
