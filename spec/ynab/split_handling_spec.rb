require "spec_helper"
require "compare_metrobank_credit_card_statement_with_ynab_export"

RSpec.describe "YNAB Split Handling" do
  subject(:export_file) { CompareMetrobankCreditCardStatementWithYnabExport::YNAB::ExportFile.parse(csv_content) }
  let(:transactions) { export_file.transactions }

  describe "grouping adjacent split rows" do
    let(:csv_content) do
      <<~CSV
        Account,Flag,Date,Payee,Category Group/Category,Category Group,Category,Memo,Outflow,Inflow,Cleared
        CC / Metrobank,,2026-02-12,Transfer : L / Friend A,Category,Group,Cat,Friend A Split (1/3) LOCAL BAKERY,925.84,0,Uncleared
        CC / Metrobank,,2026-02-12,Transfer : L / Friend B,Category,Group,Cat,Friend B Split (2/3) LOCAL BAKERY,925.82,0,Uncleared
        CC / Metrobank,,2026-02-12,,Category,Group,Cat,Hidden Split (3/3) LOCAL BAKERY,925.82,0,Uncleared
        CC / Metrobank,,2026-02-12,Normal,Category,Group,Cat,Normal Memo,100.00,0,Uncleared
      CSV
    end

    it "groups split transactions into a single transaction" do
      expect(transactions.size).to eq(2)
      
      split_t = transactions.find { |t| t.description == "LOCAL BAKERY" }
      expect(split_t.outflow).to eq(BigDecimal("2777.48"))
      expect(split_t.date).to eq(Date.new(2026, 2, 12))
      
      normal_t = transactions.find { |t| t.description == "Normal Memo" }
      expect(normal_t.outflow).to eq(BigDecimal("100.00"))
    end
  end

  describe "handling different memo suffixes (e.g. Transport case)" do
    let(:csv_content) do
      <<~CSV
        Account,Flag,Date,Payee,Category Group/Category,Category Group,Category,Memo,Outflow,Inflow,Cleared
        CC / Metrobank,,2026-01-23,TRANSPORT SERVICE,Cat,Group,Cat,Split (1/2) Friend C's share,2064,0,Uncleared
        CC / Metrobank,,2026-01-23,Transfer : L / Friend A,Cat,Group,Cat,Split (2/2) Friend A's share,1032,0,Uncleared
      CSV
    end

    it "groups them by adjacency and date" do
      expect(transactions.size).to eq(1)
      t = transactions.first
      expect(t.amount).to eq(BigDecimal("3096"))
      expect(t.description).to eq("'s share") # Common suffix
    end
  end

  describe "handling split info elsewhere in memo" do
    let(:csv_content) do
      <<~CSV
        Account,Flag,Date,Payee,Category Group/Category,Category Group,Category,Memo,Outflow,Inflow,Cleared
        CC / Metrobank,,2026-02-12,,Category,Group,Cat,Something Split (1/2) Other,10.00,0,Uncleared
        CC / Metrobank,,2026-02-12,,Category,Group,Cat,Else Split (2/2) Other,10.00,0,Uncleared
      CSV
    end

    it "extracts common identifier" do
      expect(transactions.size).to eq(1)
      t = transactions.first
      expect(t.outflow).to eq(BigDecimal("20.00"))
      expect(t.description).to eq("Other")
    end
  end
end
