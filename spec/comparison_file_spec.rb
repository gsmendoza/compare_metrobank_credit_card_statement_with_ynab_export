require "spec_helper"
require "compare_metrobank_credit_card_statement_with_ynab_export"

RSpec.describe CompareMetrobankCreditCardStatementWithYnabExport::ComparisonFile do
  describe ".compare" do
    let(:mb_date) { Date.new(2026, 1, 10) }
    let(:mb_t1) { CompareMetrobankCreditCardStatementWithYnabExport::MB::CreditCardStatementTextCopy::Transaction.new(transaction_date: mb_date, description: "MB 1", amount: BigDecimal("100.00")) }
    let(:mb_t2) { CompareMetrobankCreditCardStatementWithYnabExport::MB::CreditCardStatementTextCopy::Transaction.new(transaction_date: mb_date, description: "MB 2", amount: BigDecimal("200.00")) }
    let(:mb_statement) { CompareMetrobankCreditCardStatementWithYnabExport::MB::CreditCardStatementTextCopy.new(transactions: [mb_t1, mb_t2]) }

    let(:ynab_t1) { CompareMetrobankCreditCardStatementWithYnabExport::YNAB::ExportFile::Transaction.new(date: mb_date + 1, description: "YNAB 1", outflow: BigDecimal("100.00"), inflow: BigDecimal("0")) }
    let(:ynab_t2) { CompareMetrobankCreditCardStatementWithYnabExport::YNAB::ExportFile::Transaction.new(date: mb_date + 5, description: "YNAB 2", outflow: BigDecimal("200.00"), inflow: BigDecimal("0")) }
    let(:ynab_export) { CompareMetrobankCreditCardStatementWithYnabExport::YNAB::ExportFile.new(transactions: [ynab_t1, ynab_t2]) }

    subject(:comparisons) { described_class.compare(mb_statement, ynab_export).comparisons }

    it "matches transactions with same amount within date range" do
      match1 = comparisons.find { |c| c.mb_transaction == mb_t1 }
      expect(match1.ynab_transaction).to eq(ynab_t1)
    end

    it "does not match if date is too far" do
      match2 = comparisons.find { |c| c.mb_transaction == mb_t2 }
      expect(match2.ynab_transaction).to be_nil
    end

    it "handles unmatched YNAB transactions" do
      unmatched_ynab = comparisons.find { |c| c.ynab_transaction == ynab_t2 }
      expect(unmatched_ynab.mb_transaction).to be_nil
    end

    context "when there are multiple matches" do
      let(:ynab_t3) { CompareMetrobankCreditCardStatementWithYnabExport::YNAB::ExportFile::Transaction.new(date: mb_date + 2, description: "YNAB 3", outflow: BigDecimal("100.00"), inflow: BigDecimal("0")) }
      let(:ynab_export) { CompareMetrobankCreditCardStatementWithYnabExport::YNAB::ExportFile.new(transactions: [ynab_t1, ynab_t3]) }

      it "picks the closest date match" do
         match = comparisons.find { |c| c.mb_transaction == mb_t1 }
         expect(match.ynab_transaction).to eq(ynab_t1) 
      end
    end

    context "with payments" do
      let(:mb_p) { CompareMetrobankCreditCardStatementWithYnabExport::MB::CreditCardStatementTextCopy::Transaction.new(transaction_date: mb_date, description: "PAYMENT", amount: BigDecimal("-500.00")) }
      let(:mb_statement) { CompareMetrobankCreditCardStatementWithYnabExport::MB::CreditCardStatementTextCopy.new(transactions: [mb_p]) }
      let(:ynab_p) { CompareMetrobankCreditCardStatementWithYnabExport::YNAB::ExportFile::Transaction.new(date: mb_date, description: "PAYMENT", outflow: BigDecimal("0"), inflow: BigDecimal("500.00")) }
      let(:ynab_export) { CompareMetrobankCreditCardStatementWithYnabExport::YNAB::ExportFile.new(transactions: [ynab_p]) }

      it "matches payments (negative MB amount vs positive YNAB inflow)" do
        match = comparisons.find { |c| c.mb_transaction == mb_p }
        expect(match.ynab_transaction).to eq(ynab_p)
      end
    end
  end
end
