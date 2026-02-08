namespace :monthly_summary do
  desc '先月の思い出まとめをLINEで送信する（本番送信用）'
  task send: :environment do
    # ログを標準出力に出す（Renderのログで確認するため）
    Rails.logger = Logger.new($stdout)

    # デフォルトは「先月」
    target_month = Date.current.prev_month

    Rails.logger.info "=== [Batch Start] Monthly Summary for #{target_month.strftime('%Y-%m')} ==="

    # バッチ実行（dry_run: false で本番送信）
    MonthlySummaryBatchNotifier.call(month: target_month, dry_run: false)

    Rails.logger.info '=== [Batch End] ==='
  end

  desc '【テスト用】先月の思い出まとめ送信のドライラン（送信なし・ログのみ）'
  task dry_run: :environment do
    Rails.logger = Logger.new($stdout)
    target_month = Date.current.prev_month

    Rails.logger.info '=== [Dry Run Start] ==='

    # dry_run: true なので送信されません
    MonthlySummaryBatchNotifier.call(month: target_month, dry_run: true)

    Rails.logger.info '=== [Dry Run End] ==='
  end
end
