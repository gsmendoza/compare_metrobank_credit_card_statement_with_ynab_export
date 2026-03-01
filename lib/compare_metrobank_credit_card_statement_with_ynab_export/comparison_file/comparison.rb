module CompareMetrobankCreditCardStatementWithYnabExport
  class ComparisonFile
    class Comparison
      attr_accessor :mb_transaction, :ynab_transaction

      def initialize(mb_transaction: nil, ynab_transaction: nil)
        @mb_transaction = mb_transaction
        @ynab_transaction = ynab_transaction
      end
    end
  end
end
