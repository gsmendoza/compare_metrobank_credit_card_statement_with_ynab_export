#!/usr/bin/env ruby
# frozen_string_literal: true

require "csv"
require "date"

input_file = ARGV[0] || "metrobank-export.txt"
output_file = "metrobank-transactions.csv"

abort "File not found: #{input_file}" unless File.exist?(input_file)

lines = File.readlines(input_file, chomp: true)

date_rows = []
after_end = false
amounts = []

transaction_row_regex = /^\d{2}\/\d{2}\s+(\d{2}\/\d{2})/

lines.each do |line|
  if (m = line.match(transaction_row_regex))
    date_rows << m[1]
  end

  if after_end
    break if line.strip == "PAYMENT MADE EASIER: Pay your Metrobank Credit Card bills through Metrobank Online or"
    amounts << line.strip
  end

  after_end = true if line =~ /\*\*\*\*END OF STATEMENT\*\*\*\*/
end

amounts.pop # remove TOTAL AMOUNT DIFF row

current_year = Date.today.year
current_month = Date.today.month

transactions = date_rows.zip(amounts).map do |date_str, value|
  m, d = date_str.split("/").map(&:to_i)

  year = m <= current_month ? current_year : current_year - 1
  date = Date.new(year, m, d)

  inflow = 0.0
  outflow = 0.0

  if value.end_with?("C")
    inflow = value.gsub(/[^\d.]/, "").to_f
  else
    outflow = value.gsub(/[^\d.]/, "").to_f
  end

  [date, outflow, inflow]
end

# Sort by date descending
transactions.sort_by! { |date, _, _| date }.reverse!

CSV.open(output_file, "w") do |csv|
  csv << ["Date", "Outflow", "Inflow"]
  transactions.each do |date, outflow, inflow|
    csv << [date.strftime("%Y-%m-%d"), outflow, inflow]
  end
end

puts "✅ Extracted #{transactions.size} transactions into #{output_file}"
