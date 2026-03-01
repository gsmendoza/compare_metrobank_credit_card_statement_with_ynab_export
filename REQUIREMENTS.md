## Goal

I want a gem that can generate a comparison of two transaction files:

* Metrobank credit card statement text copy
* YNAB export file

I want to be able to view the comparison to be saved as a CSV so that I can manually verify it.

## Requirements

* I want the comparison file to have the following columns:
  * MB Transaction Date
  * MB Description
  * MB Amount
  * YNAB Date
  * YNAB Description
  * YNAB Outflow
  * YNAB Inflow

* Do not make assumptions about cardholder names like "HOLDER_A" and "HOLDER_B".

* `YNAB::ExportFile::Transaction#amount` is either its outflow or the negative value of its inflow.

* Sort the comparison file by 2025-12-21 (DESC), MB Description (ASC), MB Amount (ASC).

* When a YNAB transaction has been splitted, group them in a single transaction. Example, treat the transaction below as a single transaction with outflow = 2777.48.

  ```
CC / Bank    2026-02-12  Transfer : L / Friend A  Personal Expenses (0K): Personal / Loans  Personal Expenses (0K) Personal / Loans Split (1/3) LOCAL BAKERY, City, ST 925.84  0 Uncleared
CC / Bank    2026-02-12  Transfer : L / Friend B  Personal Expenses (0K): Personal / Loans  Personal Expenses (0K) Personal / Loans Split (2/3) LOCAL BAKERY, City, ST 925.82  0 Uncleared
CC / Bank    2026-02-12    Hidden Categories: Personal / Vacation  Hidden Categories Personal / Vacation Split (3/3) LOCAL BAKERY, City, ST 925.82  0 Uncleared
  ```

* Do not include the individual splitted YNAB transactions in the comparison file.

## Design and structure

* Consider organizing the app based on the following subclasses:

  * MB::CreditCardStatementTextCopy
    - Methods
      - transactions
      - lines

  * MB::CreditCardStatementTextCopy::Line

  * MB::CreditCardStatementTextCopy::Transaction
    - Attributes
      - transaction_date
      - description
      - amount

  * YNAB::ExportFile
    - Methods
      - rows
      - transactions

  * YNAB::ExportFile::Row

  * YNAB::ExportFile::RowGroup
    - Attributes
      - rows

  * YNAB::ExportFile::Transaction
    - Attributes
      - date
      - description
        - Set to any of these three (in order of priority)
          - memo
          - payee
          - Category Group/Category
      - outflow
      - inflow

    - Methods
      - amount

  * ComparisonFile
    - Attributes
      - comparisons

  * ComparisonFile::Comparison
    - Attributes
      - mb_transaction
      - ynab_transaction

* Declare these subclasses under the gem's namespace.

* Create a file for each class (Except for one-liner subclasses).

## Dependencies

* Use RSpec for testing.

## Version control

* Do not commit the real test files that are currently in tmp.

## QA

* When I run `bundle exec exe/compare-metrobank-ynab tmp/mb-input.txt tmp/ynab-input.csv tmp/output.csv`,
  * "2026-12-26    PAYMENT - THANK YOU - MB    -12717.46" should be matched "2025-12-26        0    12717.46".

* When I run `bundle exec exe/compare-metrobank-ynab tmp/mb-input.txt tmp/ynab-input.csv tmp/output.csv`, these should be grouped:
  ```
  CC / Bank    2026-01-23  Transport Service  External (62K)  Variable / Transport  Split (1/2) Friend's share  2064  0 Uncleared
  CC / Bank    2026-01-23  Transfer : L / Friend B  Personal Expenses (0K): Personal / Loans  Personal Expenses (0K) Personal / Loans Split (2/2) My share 1032  0 Uncleared
  ```
