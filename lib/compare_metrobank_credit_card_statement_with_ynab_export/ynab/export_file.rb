require "csv"
require "date"
require "bigdecimal"
require_relative "export_file/transaction"
require_relative "export_file/row"
require_relative "export_file/row_group"

module CompareMetrobankCreditCardStatementWithYnabExport
  module YNAB
    class ExportFile
      attr_accessor :transactions, :rows

      def initialize(transactions: [], rows: [])
        @transactions = transactions
        @rows = rows
      end

      def self.parse(content)
        csv = CSV.parse(content, headers: true)
        rows = csv.map { |r| Row.new(r) }
        
        # 1. Group adjacent split rows
        processed_data = group_splits(rows)

        # 2. Create Transaction objects and calculate description
        transactions = processed_data.map do |data|
          description = determine_description(data)
          Transaction.new(
            date: data[:date],
            description: description,
            outflow: data[:outflow],
            inflow: data[:inflow]
          )
        end

        new(transactions: transactions, rows: rows)
      end

      private

      def self.determine_description(data)
        return data[:memo] unless data[:memo].to_s.strip.empty?
        return data[:payee] unless data[:payee].to_s.strip.empty?
        data[:category].to_s.strip
      end

      def self.group_splits(rows)
        results = []
        current_group = []
        current_y = nil

        rows.each do |row|
          if row.split?
            x, y = row.split_info
            
            if x == 1 || current_group.empty? || y != current_y || row.date != current_group.first.date
              if current_group.any?
                results << RowGroup.new(current_group).to_h
              end
              current_group = [row]
              current_y = y
            else
              current_group << row
            end
            
            if x == y && current_group.any?
              results << RowGroup.new(current_group).to_h
              current_group = []
              current_y = nil
            end
          else
            if current_group.any?
              results << RowGroup.new(current_group).to_h
              current_group = []
              current_y = nil
            end
            results << row.to_h
          end
        end

        if current_group.any?
          results << RowGroup.new(current_group).to_h
        end
        
        results
      end
    end
  end
end
