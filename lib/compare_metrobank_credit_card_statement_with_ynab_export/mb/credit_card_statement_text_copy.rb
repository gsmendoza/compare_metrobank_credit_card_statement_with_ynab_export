require "date"
require "bigdecimal"
require_relative "credit_card_statement_text_copy/transaction"
require_relative "credit_card_statement_text_copy/line"

module CompareMetrobankCreditCardStatementWithYnabExport
  module MB
    class CreditCardStatementTextCopy
      attr_accessor :transactions, :lines

      def initialize(transactions: [], lines: [])
        @transactions = transactions
        @lines = lines
      end

      def self.parse(content)
        raw_lines = content.split("\n").map(&:strip).reject(&:empty?)

        lines = raw_lines.map { |l| Line.new(l) }

        # 1. Get Statement Date to infer year
        statement_date_line_idx = lines.find_index { |l| l.to_s.start_with?("Statement Date") }

        statement_date = nil

        if statement_date_line_idx
          statement_date = Date.parse(lines[statement_date_line_idx + 1].to_s)
        end

        statement_year = statement_date&.year || Date.today.year

        transactions_data = []
        amounts_data = []

        in_transaction_details = false
        reached_end = false

        lines.each do |line|
          content = line.to_s.strip
          
          if content.upcase.include?("PESO ACCOUNT DETAILS")
            in_transaction_details = true
            next
          end

          next unless in_transaction_details

          if content.upcase.include?("TOTAL AMOUNT DUE") || content.start_with?("****")
            reached_end = true
            next
          end

          if !reached_end
            # Skip sub-headers like "JOH*** * DOE**** - 40** **** **** 1234"
            next if content.match?(/^[A-Z\*\s]+-\s+\d{2,4}.+\d{2,4}$/)

            if line.transaction?
              transactions_data << line.parse_transaction(statement_year, statement_date)
            elsif line.amount?
              # Skip "Previous Balance" amount if it appears before any transaction
              next if transactions_data.empty?

              amounts_data << line.parse_amount
            end
          else
            if line.amount?
              amounts_data << line.parse_amount
            end
          end
        end

        transactions = transactions_data.each_with_index.map do |data, i|
          Transaction.new(
            transaction_date: data[:date],
            description: data[:description],
            amount: data[:amount] || amounts_data[i]
          )
        end

        new(transactions: transactions, lines: lines)
      end
    end
  end
end
