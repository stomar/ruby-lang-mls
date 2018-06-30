# frozen_string_literal: true

require "dm-core"
require "dm-migrations"


class DailyStats
  include DataMapper::Resource

  property :id,         Serial
  property :date,       Date,    :required => true
  property :talk_subsc, Integer, :default => 0
  property :talk_unsub, Integer, :default => 0
  property :core_subsc, Integer, :default => 0
  property :core_unsub, Integer, :default => 0
  property :doc_subsc,  Integer, :default => 0
  property :doc_unsub,  Integer, :default => 0
  property :cvs_subsc,  Integer, :default => 0
  property :cvs_unsub,  Integer, :default => 0

  def self.headers
    %w{date talk_subsc talk_unsub core_subsc core_unsub
       doc_subsc doc_unsub cvs_subsc cvs_unsub}.join(",")
  end

  def to_string
    [date, talk_subsc, talk_unsub, core_subsc, core_unsub,
     doc_subsc, doc_unsub, cvs_subsc, cvs_unsub].map(&:to_s).join(",")
  end

  def increment(list, action)
    column = column_from_list_action(list, action)

    new_value = self[column] + 1
    self.update(column => new_value)
  end

  private

  def column_from_list_action(list, action)
    "#{list.gsub(/ruby-/,"")}_#{action[0..4]}".to_sym
  end
end
