module CompareMetrobankCreditCardStatementWithYnabExport
  module YNAB
    class ExportFile
      class Transaction
        attr_accessor :date, :description, :outflow, :inflow

        def initialize(date:, description:, outflow:, inflow:)
          @date = date
          @description = description
          @outflow = outflow
          @inflow = inflow
        end

        def amount
          outflow - inflow
        end
      end
    end
  end
end
