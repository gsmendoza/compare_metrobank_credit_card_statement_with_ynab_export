require "spec_helper"
require "compare_metrobank_credit_card_statement_with_ynab_export"

RSpec.describe CompareMetrobankCreditCardStatementWithYnabExport::YNAB::ExportFile::RowGroup do
  def build_row(memo:, date: "2026-02-12", outflow: 0, inflow: 0)
    data = {
      "Date" => date,
      "Payee" => "TIONG BAHRU BAKERY",
      "Memo" => memo,
      "Category Group/Category" => "Unplanned Expenses (0K): Unplanned / Loans",
      "Outflow" => outflow.to_s,
      "Inflow" => inflow.to_s
    }
    csv_row = CSV::Row.new(data.keys, data.values)
    CompareMetrobankCreditCardStatementWithYnabExport::YNAB::ExportFile::Row.new(csv_row)
  end

  let(:rows) do
    [
      build_row(memo: "Split (1/3) TIONG BAHRU BAKERY, Singapore, SG", outflow: 925.84),
      build_row(memo: "Split (2/3) TIONG BAHRU BAKERY, Singapore, SG", outflow: 925.82),
      build_row(memo: "Split (3/3) TIONG BAHRU BAKERY, Singapore, SG", outflow: 925.82)
    ]
  end
  let(:row_group) { described_class.new(rows) }

  describe "#date" do
    it "returns the date from the first row" do
      expect(row_group.date).to eq(Date.new(2026, 2, 12))
    end
  end

  describe "#outflow" do
    it "sums the outflow of all rows" do
      expect(row_group.outflow).to eq(BigDecimal("2777.48"))
    end
  end

  describe "#inflow" do
    it "sums the inflow of all rows" do
      expect(row_group.inflow).to eq(BigDecimal("0"))
    end
  end

  describe "#memo" do
    it "cleans split markers and finds common description" do
      expect(row_group.memo).to eq("TIONG BAHRU BAKERY, Singapore, SG")
    end
  end

  describe "#payee" do
    it "returns the first non-empty payee" do
      expect(row_group.payee).to eq("TIONG BAHRU BAKERY")
    end
  end

  describe "#category" do
    it "returns the first non-empty category" do
      expect(row_group.category).to eq("Unplanned Expenses (0K): Unplanned / Loans")
    end
  end

  describe "#to_h" do
    it "returns consolidated data hash" do
      hash = row_group.to_h
      expect(hash[:date]).to eq(Date.new(2026, 2, 12))
      expect(hash[:outflow]).to eq(BigDecimal("2777.48"))
      expect(hash[:memo]).to eq("TIONG BAHRU BAKERY, Singapore, SG")
    end
  end
end
