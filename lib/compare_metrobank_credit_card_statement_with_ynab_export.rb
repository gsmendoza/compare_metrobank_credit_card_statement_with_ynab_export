# frozen_string_literal: true

require_relative "compare_metrobank_credit_card_statement_with_ynab_export/version"
require_relative "compare_metrobank_credit_card_statement_with_ynab_export/mb/credit_card_statement_text_copy"
require_relative "compare_metrobank_credit_card_statement_with_ynab_export/ynab/export_file"
require_relative "compare_metrobank_credit_card_statement_with_ynab_export/comparison_file"

module CompareMetrobankCreditCardStatementWithYnabExport
  class Error < StandardError; end
  
  def self.run(mb_path, ynab_path, output_path)
    mb_content = File.read(mb_path)
    ynab_content = File.read(ynab_path)
    
    mb_statement = MB::CreditCardStatementTextCopy.parse(mb_content)
    ynab_export = YNAB::ExportFile.parse(ynab_content)
    
    comparison_file = ComparisonFile.compare(mb_statement, ynab_export)
    csv_output = comparison_file.to_csv
    
    File.write(output_path, csv_output)
    puts "Comparison saved to #{output_path}"
  end
end
