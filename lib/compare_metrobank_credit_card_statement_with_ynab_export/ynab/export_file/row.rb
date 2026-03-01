require "date"
require "bigdecimal"

module CompareMetrobankCreditCardStatementWithYnabExport
  module YNAB
    class ExportFile
      class Row
        SPLIT_REGEX = /Split \((\d+)\/(\d+)\)/

        attr_reader :csv_row

        def initialize(csv_row)
          @csv_row = csv_row
        end

        def date
          Date.parse(csv_row["Date"])
        end

        def memo
          csv_row["Memo"] || ""
        end

        def payee
          csv_row["Payee"] || ""
        end

        def category
          csv_row["Category Group/Category"] || ""
        end

        def outflow
          BigDecimal(csv_row["Outflow"] || "0")
        end

        def inflow
          BigDecimal(csv_row["Inflow"] || "0")
        end

        def split?
          memo.match?(SPLIT_REGEX)
        end

        def split_info
          match = memo.match(SPLIT_REGEX)
          return nil unless match

          [match[1].to_i, match[2].to_i]
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
      end
    end
  end
end
