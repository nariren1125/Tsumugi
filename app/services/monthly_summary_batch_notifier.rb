# frozen_string_literal: true

class MonthlySummaryBatchNotifier
  def self.call(month: Date.current.prev_month, dry_run: false)
    new(month: month, dry_run: dry_run).call
  end

  def initialize(month:, dry_run:)
    @month = month.beginning_of_month
    @dry_run = dry_run
  end

  def call
    log_start

    FamilyGroup.find_each do |family_group|
      process_family_group(family_group)
    rescue StandardError => e
      handle_error(family_group, e)
    end

    log_end
  end

  private

  def process_family_group(family_group)
    MonthlySummaryNotifier.call(
      family_group: family_group,
      month: @month,
      dry_run: @dry_run
    )
  end

  def handle_error(family_group, error)
    Rails.logger.error(
      "Failed FamilyGroup(#{family_group.id}, #{family_group.name}) " \
      "month=#{@month.strftime('%Y-%m')} error=#{error.class} msg=#{error.message}"
    )
    Rails.logger.error(error.backtrace.join("\n"))
  end

  def log_start
    prefix = @dry_run ? '[DryRun] ' : ''
    Rails.logger.info(
      "#{prefix}=== Monthly Summary Batch Start (Month: #{@month.strftime('%Y-%m')}) ==="
    )
  end

  def log_end
    prefix = @dry_run ? '[DryRun] ' : ''
    Rails.logger.info("#{prefix}=== Monthly Summary Batch End ===")
  end
end
