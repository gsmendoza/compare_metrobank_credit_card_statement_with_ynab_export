#!/usr/bin/env ruby
# frozen_string_literal: true

require "csv"
require "date"

input_file = ARGV[0] || "ynab-export.csv"
output_file = "ynab-transactions.csv"

abort "File not found: #{input_file}" unless File.exist?(input_file)

lines = File.readlines(input_file, chomp: true)

rows = []

# CSV headers: Date, Outflow, Inflow
CSV.foreach(input_file, headers: true) do |row|
  date_str = row["Date"]
  outflow = row["Outflow"].to_f
  inflow = row["Inflow"].to_f

  next if date_str.nil? || date_str.strip.empty?

  date = Date.parse(date_str)

  rows << [date, outflow, inflow]
end

# Sort newest first
rows.sort_by! { |date, _, _| date }.reverse!

CSV.open(output_file, "w") do |csv|
  csv << ["Date", "Outflow", "Inflow"]
  rows.each do |date, outflow, inflow|
    csv << [date.strftime("%Y-%m-%d"), outflow, inflow]
  end
end

puts "✨ Exported #{rows.size} YNAB-ready rows into #{output_file}"
