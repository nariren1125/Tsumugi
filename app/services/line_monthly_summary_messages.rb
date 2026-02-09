# frozen_string_literal: true

class LineMonthlySummaryMessages
  def self.messages
    @messages ||= LineMonthlySummaryMessagesBase.messages
                                                .merge(LineMonthlySummaryMessagesAppear.messages)
                                                .merge(LineMonthlySummaryMessagesPost.messages)
                                                .merge(LineMonthlySummaryMessagesBalanced.messages)
                                                .freeze
  end
end
