require "spec_helper"
require "compare_metrobank_credit_card_statement_with_ynab_export"
require "csv"

RSpec.describe "CompareMetrobankCreditCardStatementWithYnabExport::ComparisonFile#to_csv" do
  let(:mb_t1) { CompareMetrobankCreditCardStatementWithYnabExport::MB::CreditCardStatementTextCopy::Transaction.new(transaction_date: Date.new(2026, 1, 2), description: "B", amount: BigDecimal("100")) }
  let(:mb_t2) { CompareMetrobankCreditCardStatementWithYnabExport::MB::CreditCardStatementTextCopy::Transaction.new(transaction_date: Date.new(2026, 1, 1), description: "A", amount: BigDecimal("200")) }
  let(:mb_t3) { CompareMetrobankCreditCardStatementWithYnabExport::MB::CreditCardStatementTextCopy::Transaction.new(transaction_date: Date.new(2026, 1, 2), description: "A", amount: BigDecimal("300")) }
  
  let(:ynab_t1) { CompareMetrobankCreditCardStatementWithYnabExport::YNAB::ExportFile::Transaction.new(date: Date.new(2026, 1, 2), description: "YNAB A", outflow: BigDecimal("300"), inflow: BigDecimal("0")) }

  let(:comparisons) do
    [
      CompareMetrobankCreditCardStatementWithYnabExport::ComparisonFile::Comparison.new(mb_transaction: mb_t1),
      CompareMetrobankCreditCardStatementWithYnabExport::ComparisonFile::Comparison.new(mb_transaction: mb_t2),
      CompareMetrobankCreditCardStatementWithYnabExport::ComparisonFile::Comparison.new(mb_transaction: mb_t3, ynab_transaction: ynab_t1)
    ]
  end
  let(:comparison_file) { CompareMetrobankCreditCardStatementWithYnabExport::ComparisonFile.new(comparisons: comparisons) }

  subject(:csv_string) { comparison_file.to_csv }

  it "generates CSV with correct headers" do
    csv = CSV.parse(csv_string)
    expect(csv[0]).to eq([
      "MB Transaction Date", "MB Description", "MB Amount",
      "YNAB Date", "YNAB Description", "YNAB Outflow", "YNAB Inflow"
    ])
  end

  it "generates CSV sorted by Date (DESC), MB Description (ASC), and MB Amount (ASC)" do
    csv = CSV.parse(csv_string)
    # Row 1: 2026-01-02, A, 300.0 (Latest date, first description)
    expect(csv[1][0..2]).to eq(["2026-01-02", "A", "300.0"])
    expect(csv[1][3..4]).to eq(["2026-01-02", "YNAB A"])
    # Row 2: 2026-01-02, B, 100.0 (Same date, second description)
    expect(csv[2][0..2]).to eq(["2026-01-02", "B", "100.0"])
    # Row 3: 2026-01-01, A, 200.0 (Oldest date)
    expect(csv[3][0..2]).to eq(["2026-01-01", "A", "200.0"])
  end
end
