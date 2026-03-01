require "spec_helper"
require "compare_metrobank_credit_card_statement_with_ynab_export"

RSpec.describe CompareMetrobankCreditCardStatementWithYnabExport::YNAB::ExportFile::Row do
  let(:row_data) do
    {
      "Date" => "2026-02-12",
      "Payee" => "TIONG BAHRU BAKERY",
      "Memo" => "Split (1/3) TIONG BAHRU BAKERY, Singapore, SG",
      "Category Group/Category" => "Unplanned Expenses (0K): Unplanned / Loans",
      "Outflow" => "925.84",
      "Inflow" => "0"
    }
  end
  let(:csv_row) { CSV::Row.new(row_data.keys, row_data.values) }
  let(:row) { described_class.new(csv_row) }

  describe "attributes" do
    it "returns the date" do
      expect(row.date).to eq(Date.new(2026, 2, 12))
    end

    it "returns the payee" do
      expect(row.payee).to eq("TIONG BAHRU BAKERY")
    end

    it "returns the memo" do
      expect(row.memo).to eq("Split (1/3) TIONG BAHRU BAKERY, Singapore, SG")
    end

    it "returns the category" do
      expect(row.category).to eq("Unplanned Expenses (0K): Unplanned / Loans")
    end

    it "returns the outflow" do
      expect(row.outflow).to eq(BigDecimal("925.84"))
    end

    it "returns the inflow" do
      expect(row.inflow).to eq(BigDecimal("0"))
    end
  end

  describe "#split?" do
    context "when it is a split transaction" do
      it "returns true" do
        expect(row.split?).to be true
      end
    end

    context "when it is not a split transaction" do
      let(:row_data) { super().merge("Memo" => "Normal transaction") }
      it "returns false" do
        expect(row.split?).to be false
      end
    end
  end

  describe "#split_info" do
    it "returns x and y from 'Split (x/y)'" do
      expect(row.split_info).to eq([1, 3])
    end

    context "when not a split" do
      let(:row_data) { super().merge("Memo" => "Normal transaction") }
      it "returns nil" do
        expect(row.split_info).to be_nil
      end
    end
  end
end
