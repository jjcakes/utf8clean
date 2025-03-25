# utf8clean — PostgreSQL UTF-8 Cleaner Function

## Overview
`utf8clean` is a robust PostgreSQL function that strips out invalid or non-UTF-8 byte sequences from text fields.  
It was built to handle messy external data sources (looking at you, Windows-1252 👀) and ensure stored data is clean, safe, and consistent.

## Why this exists
- External vendors and data feeds often deliver text with invalid UTF-8 characters.
- Standard PostgreSQL conversions can fail or truncate.
- This function inspects each byte, validating against the UTF-8 spec, and only passes allowed sequences.

## Features
- Written in PL/pgSQL.
- Strict adherence to UTF-8 rules (including multi-byte sequences).
- Preserves newline and carriage return characters.
- Easy to integrate into `INSERT`/`UPDATE` queries.
- Works on large datasets.

## Installation
Run the utf8clean.sql in your PostgreSQL instance

## Usage
Just wrap strings for insert/update in utf8clean(), for example:

```update some_table set some_column = utf8clean('some naughty string');```
