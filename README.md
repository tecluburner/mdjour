# mdjour

A Markdown-based journal system. Each entry is a single Markdown file with
YAML front matter, so your journal stays in plain text: easy to search with
`grep`, easy to track with Git, and easy to migrate to a database later.

Markdown ベースの日記システムです。1つの記事を YAML フロントマター付きの
1つの Markdown ファイルとして保存するため、日記をプレーンテキストのまま
管理できます。`grep` で検索しやすく、Git で履歴を管理でき、将来のデータベース
移行にも備えています。

## Features

- **Markdown first** – one entry per `.md` file, no database required
- **Searchable from the terminal** – date-based file names and simple YAML metadata work well with `grep`, `ls` and `find`
- **Separate dates** – created, updated, and event dates are tracked independently (`created`, `updated`, `event_date`)
- **Stable IDs** – every entry has an unchanging `YYYYMMDD-NN` id, ready for a future database migration
- **Attachments by link** – files live in `attachments/YYYY/YYYY-MM-DD/` and are referenced with relative Markdown links
- **Entry generator** – `mdjour-new.sh` creates a correctly named and formatted entry in one command

## 特徴

- **Markdown が中心** – 1記事1ファイル(`.md`)。データベース不要
- **ターミナルから検索しやすい** – 日付ベースのファイル名とシンプルな YAML で、`grep`・`ls`・`find` と相性が良い
- **日付を分けて管理** – 作成日・更新日・出来事の日を独立して記録(`created`、`updated`、`event_date`)
- **変わらない ID** – `YYYYMMDD-NN` 形式の ID で、将来のデータベース移行に備える
- **添付はリンクで管理** – `attachments/YYYY/YYYY-MM-DD/` に保存し、Markdown の相対リンクで参照
- **記事の生成スクリプト** – `mdjour-new.sh` で、規則どおりのファイル名と書式の記事を1コマンドで作成

## Quick start

```bash
./mdjour-new.sh -t "Dinner with a friend" -g "friends,food" -a -o
```
