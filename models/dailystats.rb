# frozen_string_literal: true

# DailyStats model.
class DailyStats < Sequel::Model

  dataset_module do
    order :by_date, :date
  end

  def self.headers
    %w[date talk_subsc talk_unsub core_subsc core_unsub
       doc_subsc doc_unsub cvs_subsc cvs_unsub].join(",")
  end

  def to_s
    [date, talk_subsc, talk_unsub, core_subsc, core_unsub,
     doc_subsc, doc_unsub, cvs_subsc, cvs_unsub].map(&:to_s).join(",")
  end

  def increment(list, action)
    column = column_from_list_action(list, action)

    new_value = self[column] + 1
    update(column => new_value)
  end

  private

  def column_from_list_action(list, action)
    :"#{list.delete_prefix('ruby-')}_#{action[0..4]}"
  end
end
