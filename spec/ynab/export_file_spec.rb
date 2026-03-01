require "spec_helper"
require "compare_metrobank_credit_card_statement_with_ynab_export"

RSpec.describe CompareMetrobankCreditCardStatementWithYnabExport::YNAB::ExportFile do
  let(:fixture_path) { "spec/fixtures/ynab.csv" }
  let(:content) { File.read(fixture_path) }

  describe ".parse" do
    subject(:transactions) { described_class.parse(content).transactions }

    it "parses the correct number of transactions" do
      expect(transactions.size).to eq(4)
    end

    it "parses transaction details correctly" do
      t = transactions[0]
      expect(t.date).to eq(Date.new(2026, 1, 18))
      expect(t.description).to eq("SOME LICENSE FEE, SOME LICENSE FEE,")
      expect(t.outflow).to eq(BigDecimal("20876.47"))
      expect(t.inflow).to eq(BigDecimal("0"))
    end

    it "calculates amount correctly" do
      # Purchase: Outflow 20876.47, Inflow 0
      expect(transactions[0].amount).to eq(BigDecimal("20876.47"))
      # Payment: Outflow 0, Inflow 8650.76
      # Note: transactions[2] is the payment in fixture
      expect(transactions[2].amount).to eq(BigDecimal("-8650.76"))
    end

    describe "description priority" do
      it "uses memo if present" do
        csv = "Account,Flag,Date,Payee,Category Group/Category,Category Group,Category,Memo,Outflow,Inflow,Cleared\n" \
              "Acc,,2026-01-01,Payee,Cat,CG,Cat,Memo,100,0,Uncleared"
        t = described_class.parse(csv).transactions.first
        expect(t.description).to eq("Memo")
      end

      it "uses payee if memo is empty" do
        csv = "Account,Flag,Date,Payee,Category Group/Category,Category Group,Category,Memo,Outflow,Inflow,Cleared\n" \
              "Acc,,2026-01-01,Payee,Cat,CG,Cat,,100,0,Uncleared"
        t = described_class.parse(csv).transactions.first
        expect(t.description).to eq("Payee")
      end

      it "uses category if memo and payee are empty" do
        csv = "Account,Flag,Date,Payee,Category Group/Category,Category Group,Category,Memo,Outflow,Inflow,Cleared\n" \
              "Acc,,2026-01-01,,Cat,CG,Cat,,100,0,Uncleared"
        t = described_class.parse(csv).transactions.first
        expect(t.description).to eq("Cat")
      end
    end
  end

  describe "#rows" do
    subject(:rows) { described_class.parse(content).rows }

    it "returns an array of Row objects" do
      expect(rows.first).to be_a(CompareMetrobankCreditCardStatementWithYnabExport::YNAB::ExportFile::Row)
    end
  end
end
