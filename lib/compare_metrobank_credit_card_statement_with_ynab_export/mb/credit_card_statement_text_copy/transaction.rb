module CompareMetrobankCreditCardStatementWithYnabExport
  module MB
    class CreditCardStatementTextCopy
      class Transaction
        attr_accessor :transaction_date, :description, :amount

        def initialize(transaction_date:, description:, amount:)
          @transaction_date = transaction_date
          @description = description
          @amount = amount
        end
      end
    end
  end
end
