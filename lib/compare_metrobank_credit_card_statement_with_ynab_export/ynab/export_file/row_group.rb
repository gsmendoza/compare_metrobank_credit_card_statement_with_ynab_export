require "date"
require "bigdecimal"

module CompareMetrobankCreditCardStatementWithYnabExport
  module YNAB
    class ExportFile
      class RowGroup
        SPLIT_REGEX = /Split \((\d+)\/(\d+)\)/

        attr_reader :rows

        def initialize(rows)
          @rows = rows
        end

        def date
          rows.first.date
        end

        def memo
          cleaned_memos = rows.map do |r|
            r.memo.gsub(SPLIT_REGEX, "").gsub(/\s+/, " ").strip
          end.reject(&:empty?)

          memo = cleaned_memos.first || ""
          if cleaned_memos.size > 1
            if cleaned_memos.uniq.size == 1
              memo = cleaned_memos.first
            else
              common = find_common_suffix(cleaned_memos)
              memo = common.strip if common && common.strip.length >= 5
            end
          end
          memo
        end

        def payee
          rows.map { |r| r.payee.strip }.reject(&:empty?).first || ""
        end

        def category
          rows.map { |r| r.category.strip }.reject(&:empty?).first || ""
        end

        def outflow
          rows.sum(&:outflow)
        end

        def inflow
          rows.sum(&:inflow)
        end

        def to_h
          {
            date: date,
            memo: memo,
            payee: payee,
            category: category,
            outflow: outflow,
            inflow: inflow
          }
        end

        private

        def find_common_suffix(strings)
          return nil if strings.empty?
          return strings.first if strings.size == 1
          
          reversed = strings.map(&:reverse)
          prefix = find_common_prefix(reversed)
          prefix&.reverse
        end

        def find_common_prefix(strings)
          return nil if strings.empty?
          s1 = strings.min
          s2 = strings.max
          s1.each_char.with_index do |char, i|
            return s1[0...i] if char != s2[i]
          end
          s1
        end
      end
    end
  end
end
