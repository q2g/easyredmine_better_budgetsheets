# BetterButgetsheets for EasyRedmine

Allows to generate optimized Budgetsheets in EasyRedmine based on the Query/Filter functions provided by ER.

Optimizations include:

- Grouping
- Formatting of Numeric values
- Custom namings for columns
- Automatic locking of time entries after printing pdf

**Comning soon**
- Custom Header and Footer for PDF file

## Using custom field labels

The `I18n` scope for the custom field labels is `better_budgetsheets.columns`. 
It is possible the label custom fields by adding keys like `cf_1` (to label `CustomField` with `id=1`)


## Info

This Plugin was created by Florian Eck ([EL Digital Solutions](http://www.el-digital.de)) for [akquinet finance & controlling GmbH](http://www.akquinet.de/).

It is licensed under GNU GENERAL PUBLIC LICENSE.

This Plugin only works with easy redmine

## Fixes

### Language

faktura preview shows "translation missing: de.field_project_id" instead of "Projekt" 
config/locales/de.yml translates "field_project" (without _id) to "Projekt" in line 365
adding the line "field_project_id: Projekt" to config/locales/de.yml at line 166 fixes the issue