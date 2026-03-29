require "spec_helper"
require "compare_metrobank_credit_card_statement_with_ynab_export"

RSpec.describe CompareMetrobankCreditCardStatementWithYnabExport::MB::CreditCardStatementTextCopy do
  let(:fixture_path) { "spec/fixtures/metrobank.txt" }
  let(:content) { File.read(fixture_path) }

  describe ".parse" do
    subject(:transactions) { described_class.parse(content).transactions }

    it "parses the correct number of transactions" do
      expect(transactions.size).to eq(8)
    end

    it "parses transaction dates correctly (inferring year from statement date)" do
      expect(transactions[0].transaction_date).to eq(Date.new(2025, 12, 21))
      expect(transactions[1].transaction_date).to eq(Date.new(2026, 1, 5))
    end

    it "parses descriptions correctly" do
      expect(transactions[0].description).to eq("RIDE SERVICE, CITY, ST")
    end

    it "parses amounts correctly" do
      expect(transactions[0].amount).to eq(BigDecimal("764.00"))
    end

    it "parses payments as negative amounts (C suffix)" do
      payment = transactions.find { |t| t.description.include?("PAYMENT - THANK YOU") }
      expect(payment.amount).to eq(BigDecimal("-12717.46"))
    end

    context "when amount is on the same line as description" do
      let(:content) do
        <<~TEXT
          Statement Date
          21 January 2026
          PESO ACCOUNT DETAILS
          01/22 01/21 GAS STATION, CITY 2,000.00
          01/23 01/22 RESTAURANT 500.00 C
        TEXT
      end

      it "parses transactions and amounts correctly" do
        expect(transactions.size).to eq(2)
        expect(transactions[0].description).to eq("GAS STATION, CITY")
        expect(transactions[0].amount).to eq(BigDecimal("2000.00"))
        expect(transactions[1].description).to eq("RESTAURANT")
        expect(transactions[1].amount).to eq(BigDecimal("-500.00"))
      end
    end
  end

  describe "#lines" do
    subject(:lines) { described_class.parse(content).lines }

    it "returns an array of Line objects" do
      expect(lines.first).to be_a(CompareMetrobankCreditCardStatementWithYnabExport::MB::CreditCardStatementTextCopy::Line)
    end
  end
end
