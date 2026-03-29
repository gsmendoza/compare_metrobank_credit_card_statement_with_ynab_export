require "date"
require "bigdecimal"

module CompareMetrobankCreditCardStatementWithYnabExport
  module MB
    class CreditCardStatementTextCopy
      class Line
        TRANSACTION_REGEX = %r{^(\d{2}/\d{2})\s+(\d{2}/\d{2})\s+(.+)$}
        AMOUNT_REGEX = /^[\d,]+\.\d{2}(\s+C)?$/

        attr_reader :content

        def initialize(content)
          @content = content
        end

        def transaction?
          return false if content.match?(/\*\*\*.*-\s*\d{2,4}\*/)
          content.match?(TRANSACTION_REGEX)
        end

        def amount?
          content.match?(AMOUNT_REGEX)
        end

        def parse_transaction(statement_year, statement_date)
          match = content.match(TRANSACTION_REGEX)

          return nil unless match

          _post_date_str, tran_date_str, description = match.captures
          
          # Clean up description (remove USD info if it's there)
          description = description.gsub(/\s+USD\s+[\d,]+\.\d{2}$/, "").gsub(/\s+USD\s+\d+$/, "")

          # Extract amount if it's on the same line
          amount = nil
          amount_match = description.match(/\s+([\d,]+\.\d{2}(\s+C)?)$/)

          if amount_match
            amount_str = amount_match[1].gsub(",", "")
            is_credit = amount_str.end_with?(" C")
            amount_val = BigDecimal(amount_str.chomp(" C"))
            amount = is_credit ? -amount_val : amount_val
            description = description.sub(amount_match[0], "").strip
          end

          month, day = tran_date_str.split("/").map(&:to_i)
          year = statement_year

          if statement_date && month > statement_date.month && statement_date.month < 6
             year -= 1
          end

          {
            date: Date.new(year, month, day),
            description: description,
            amount: amount
          }
        end

        def parse_amount
          return nil unless amount?

          amount_str = content.gsub(",", "")
          is_credit = amount_str.end_with?(" C")
          amount = BigDecimal(amount_str.chomp(" C"))
          is_credit ? -amount : amount
        end

        def to_s
          content
        end
      end
    end
  end
end
