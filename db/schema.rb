# frozen_string_literal: true

require_relative "connection"

DB.create_table(:logs) do
  primary_key :id
  DateTime :timestamp, null: false
  String :list, size: 9, null: false
  String :action, size: 11, null: false
  String :status, size: 7, null: false
  String :exception, size: 35
end

DB.create_table(:daily_stats) do
  primary_key :id
  Date :date, null: false
  Integer :talk_subsc, default: 0
  Integer :talk_unsub, default: 0
  Integer :core_subsc, default: 0
  Integer :core_unsub, default: 0
  Integer :doc_subsc, default: 0
  Integer :doc_unsub, default: 0
  Integer :cvs_subsc, default: 0
  Integer :cvs_unsub, default: 0
end
