require "spec_helper"
require "compare_metrobank_credit_card_statement_with_ynab_export"

RSpec.describe CompareMetrobankCreditCardStatementWithYnabExport::MB::CreditCardStatementTextCopy::Line do
  let(:line) { described_class.new(content) }

  describe "#transaction?" do
    context "when line matches transaction format" do
      let(:content) { "12/26 12/21 RIDE SERVICE, CITY, ST" }
      it "returns true" do
        expect(line.transaction?).to be true
      end
    end

    context "when line does not match transaction format" do
      let(:content) { "PESO ACCOUNT DETAILS" }
      it "returns false" do
        expect(line.transaction?).to be false
      end
    end
  end

  describe "#amount?" do
    context "when line matches amount format" do
      let(:content) { "764.00" }
      it "returns true" do
        expect(line.amount?).to be true
      end
    end

    context "when line matches credit amount format" do
      let(:content) { "12,717.46 C" }
      it "returns true" do
        expect(line.amount?).to be true
      end
    end

    context "when line does not match amount format" do
      let(:content) { "12/26 12/21 RIDE SERVICE, CITY, ST" }
      it "returns false" do
        expect(line.amount?).to be false
      end
    end
  end

  describe "#parse_transaction" do
    let(:content) { "12/26 12/21 RIDE SERVICE, CITY, ST" }
    let(:statement_year) { 2026 }
    let(:statement_date) { Date.new(2026, 1, 24) }

    it "returns date and description" do
      result = line.parse_transaction(statement_year, statement_date)
      expect(result[:date]).to eq(Date.new(2025, 12, 21))
      expect(result[:description]).to eq("RIDE SERVICE, CITY, ST")
    end
  end

  describe "#parse_amount" do
    context "when it is a debit" do
      let(:content) { "764.00" }
      it "returns positive amount" do
        expect(line.parse_amount).to eq(BigDecimal("764.00"))
      end
    end

    context "when it is a credit" do
      let(:content) { "12,717.46 C" }
      it "returns negative amount" do
        expect(line.parse_amount).to eq(BigDecimal("-12717.46"))
      end
    end
  end
end
