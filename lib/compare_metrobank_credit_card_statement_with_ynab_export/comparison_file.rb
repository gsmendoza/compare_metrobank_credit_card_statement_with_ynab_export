require "csv"
require_relative "comparison_file/comparison"

module CompareMetrobankCreditCardStatementWithYnabExport
  class ComparisonFile
    attr_accessor :comparisons

    def initialize(comparisons: [])
      @comparisons = comparisons
    end

    def self.compare(mb_statement, ynab_export)
      mb_transactions = mb_statement.transactions.dup
      ynab_transactions = ynab_export.transactions.dup
      results = []

      mb_transactions.each do |mb_t|
        matches = ynab_transactions.select do |ynab_t|
          mb_t.amount == ynab_t.amount && (mb_t.transaction_date - ynab_t.date).abs <= 3
        end

        if matches.any?
          best_match = matches.min_by { |m| (mb_t.transaction_date - m.date).abs }
          results << Comparison.new(mb_transaction: mb_t, ynab_transaction: best_match)
          ynab_transactions.delete(best_match)
        else
          results << Comparison.new(mb_transaction: mb_t)
        end
      end

      ynab_transactions.each do |ynab_t|
        results << Comparison.new(ynab_transaction: ynab_t)
      end

      new(comparisons: results)
    end

    def to_csv
      sorted_comparisons = comparisons.sort do |a, b|
        a_date = a.mb_transaction&.transaction_date || a.ynab_transaction&.date
        b_date = b.mb_transaction&.transaction_date || b.ynab_transaction&.date
        
        a_desc = a.mb_transaction&.description || ""
        b_desc = b.mb_transaction&.description || ""
        
        a_amount = a.mb_transaction&.amount || a.ynab_transaction&.amount
        b_amount = b.mb_transaction&.amount || b.ynab_transaction&.amount

        # Sort by date (DESC), MB Description (ASC), MB Amount (ASC)
        [b_date, a_desc, a_amount] <=> [a_date, b_desc, b_amount]
      end

      CSV.generate do |csv|
        csv << [
          "MB Transaction Date", "MB Description", "MB Amount",
          "YNAB Date", "YNAB Description", "YNAB Outflow", "YNAB Inflow"
        ]

        sorted_comparisons.each do |c|
          mb = c.mb_transaction
          ynab = c.ynab_transaction

          csv << [
            mb&.transaction_date, mb&.description, mb&.amount&.to_s("F"),
            ynab&.date, ynab&.description, ynab&.outflow&.to_s("F"), ynab&.inflow&.to_s("F")
          ]
        end
      end
    end
  end
end
