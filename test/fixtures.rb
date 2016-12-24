fixtures = [
  { timestamp: Time.utc(2000, 1, 2, 12, 0, 2), status: "Success", list: "ruby-talk", action: "test" },
  { timestamp: Time.utc(2000, 1, 2, 12, 0, 3), status: "Error",   list: "ruby-talk", action: "test_error" },
  { timestamp: Time.utc(2000, 1, 2, 12, 0, 6), status: "Success", list: "ruby-talk", action: "test_last" },
  { timestamp: Time.utc(2000, 1, 2, 12, 0, 1), status: "Success", list: "ruby-talk", action: "test_first" },
  { timestamp: Time.utc(2000, 1, 2, 12, 0, 4), status: "Invalid", list: "ruby-talk", action: "test_invalid" },
  { timestamp: Time.utc(2000, 1, 2, 12, 0, 5), status: "Success", list: "ruby-talk", action: "test" }
]

fixtures.each {|row| Log.create(row) }
