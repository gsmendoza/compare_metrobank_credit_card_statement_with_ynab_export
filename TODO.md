# TODO

- [x] Initialize gem structure and dependencies <!-- id: 0 -->
- [x] Implement `MB::CreditCardStatementTextCopy::Transaction` and its parser <!-- id: 1 -->
- [x] Implement `YNAB::ExportFile::Transaction` and its parser <!-- id: 2 -->
- [x] Implement `ComparisonFile::Comparison` logic for matching transactions <!-- id: 3 -->
- [x] Implement CSV generation for the comparison results <!-- id: 4 -->
- [x] Refactor `MB::CreditCardStatementTextCopy::Line` to handle individual line parsing <!-- id: 6 -->
- [x] Refactor `YNAB::ExportFile::Row` to handle CSV row parsing <!-- id: 7 -->
- [x] Update `MB::CreditCardStatementTextCopy` to use `Line` objects <!-- id: 8 -->
- [x] Update `YNAB::ExportFile` to use `Row` objects <!-- id: 9 -->
- [x] Implement `YNAB::ExportFile::RowGroup` for grouping split transactions <!-- id: 10 -->
- [x] Refactor `YNAB::ExportFile` to use `RowGroup` <!-- id: 11 -->
