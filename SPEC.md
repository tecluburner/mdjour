# Journal Repository Conventions

This repository manages a journal as Markdown files, without a database.  
Each entry is stored as a single `.md` file, with terminal search, Git-based history, and a future database migration in mind.

## Principles

- Create one Markdown file per entry.
- Base the file name on the date the entry was created.
- Track the date the entry was written and the date the event took place in separate fields.
- Keep the YAML front matter to the minimum set of fields needed for operation.
- Reference attachments from the body with Markdown links.
- Treat `id` as a unique identifier that never changes, to prepare for a future database migration.
- As a rule, create new entries with `mdjour-new.sh`.

## Directory structure

Entries are organized by year directory only; month directories are not created.

```text
~/mdjour/
├── entries/
│   └── 2026/
│       ├── 2026-10-13-01.md
│       ├── 2026-10-14-01.md
│       └── 2026-10-14-02.md
├── attachments/
│   └── 2026/
│       └── 2026-10-14/
│           └── restaurant.jpg
├── mdjour-new.sh
└── README.md
```

- Store entry bodies in `entries/YYYY/`.
- Store attachments in `attachments/YYYY/YYYY-MM-DD/`.
- Do not create month directories.
- To browse a month, filter by the `YYYY-MM` part of the file name.
- On days without attachments, do not create a directory under `attachments/`.
- Place `mdjour-new.sh` in the journal root (the same level as `README.md`).

## Creating entries (`mdjour-new.sh`)

`mdjour-new.sh` is a script that creates an entry template following the conventions in this document. It sets the file name, `id`, sequence number, `created`, and `updated` automatically, which prevents numbering mistakes and inconsistent formatting caused by manual work.

### Setup

Place it in the journal root and make it executable.

```bash
cd ~/mdjour
chmod +x mdjour-new.sh
```

The journal root is specified with the environment variable `JOURNAL_DIR`. If it is not set, the directory containing the script is used.

```bash
# To use a different location as the journal root
JOURNAL_DIR=~/diary ./mdjour-new.sh -t "Dinner with a friend"
```

### Usage

```bash
./mdjour-new.sh [-t title] [-e event date] [-g tag1,tag2] [-a] [-o]
```

| Option | Meaning | If omitted |
|---|---|---|
| `-t` | Entry title (`title`) | Prompts interactively. An empty title is an error |
| `-e` | Date the event took place (`event_date`), in `YYYY-MM-DD` format | Today |
| `-g` | Tags (`tags`), comma-separated | `[]` (no tags) |
| `-a` | Also create the same-day attachment directory `attachments/YYYY/YYYY-MM-DD/` | Not created |
| `-o` | Open the entry in `$EDITOR` after creating it | Not opened |
| `-h` | Show help | - |

### Examples

To record something that happened today:

```bash
./mdjour-new.sh -t "Morning walk" -g "walk"
```

To record something that happened the day before, create the attachment directory, and open the entry in the editor right away:

```bash
./mdjour-new.sh -t "Dinner with a friend" -e 2026-10-13 -g "friends,food" -a -o
```

### What gets created

If the second example above is run on 2026-10-14, the result is as follows.

- Entry: `entries/2026/2026-10-14-01.md` (`-02`, `-03`, and so on for the second and later entries of the day)
- Attachment directory (only with `-a`): `attachments/2026/2026-10-14/`

The content of the entry is as follows. The body is empty, so you can start writing right away.

```yaml
---
id: "20261014-01"
title: "Dinner with a friend"
created: "2026-10-14T22:10:00+09:00"
updated: "2026-10-14T22:10:00+09:00"
event_date: "2026-10-13"
tags: ["friends", "food"]
---
```

Only the path of the created entry is written to standard output. With `-a`, the attachment directory path and an example link for the body are shown on standard error.

### What the script does

- Determines the sequence number by adding 1 to the highest existing sequence number for the day (the creation date). Gaps are not filled.
- Writes `id` as a string in `YYYYMMDD-NN` format, matching `YYYY-MM-DD-NN` in the file name.
- Sets `created` and `updated` to the same value, the execution time. Date-times use ISO 8601 format with the UTC offset of the execution environment's time zone.
- Validates that `event_date` is a real date. A date such as `2026-02-30` is an error.
- Escapes `"` and `\` in the title and tags so they form valid YAML strings.
- Never overwrites an existing file.
- Creates `entries/YYYY/` and `attachments/YYYY/YYYY-MM-DD/` automatically when needed.
- Creates nothing under `attachments/` unless `-a` is given.

### Steps for using attachments

1. Create the entry with `-a`.
2. Place the attachment files in the created `attachments/YYYY/YYYY-MM-DD/`.
3. Reference them from the body by a path relative to the entry file (see [Referencing from the body](#referencing-from-the-body)).

If you forgot `-a`, you may create a directory following the same convention by hand. The date of the directory is the date the entry was created, not the date of the event.

### Notes

- The sequence number has two digits, so at most 99 entries can be created in a single day.
- The sequence number is derived from the highest existing file, so if you delete the newest entry of the day, the next entry gets the same number. If you do not want to reuse a past `id`, do not delete the entry; correct its content and keep it.
- The creation date is the date on which the script is run. Even when writing across a date change, specify the date of the event with `-e`.
- If you edit an entry after creating it, update `updated` manually according to the [rules for `updated`](#rules-for-updated).

## File name rules

Use the following format, including when you write several entries on the same day.

```text
YYYY-MM-DD-NN.md
```

Examples:

```text
2026-10-14-01.md
2026-10-14-02.md
2026-10-14-03.md
```

- `YYYY-MM-DD` is the date the entry was created.
- `NN` is the sequence number of the entry created that day.
- The sequence number is zero-padded to two digits and starts at `01`.
- Even if an entry is deleted, do not renumber the remaining ones.
- When merging or splitting entries, give the new entries new sequence numbers.
- Do not include the title in the file name. Write the title in the `title` field of the YAML front matter.
- Do not rename a file after it has been created.

## Rules for `id`

`id` uses the date + sequence number scheme.

```yaml
id: "20261014-01"
```

- The format is `YYYYMMDD-NN`.
- `id` is a value that uniquely identifies an entry and never changes after creation.
- If the file name is `2026-10-14-01.md`, the `id` is `20261014-01`.
- Always treat `id` as a string in YAML, so enclose it in quotes.
- When making a copy of an entry, give the copy a new `id`.

## YAML front matter

Write the following fields at the top of each entry. `mdjour-new.sh` writes these fields automatically.

```yaml
---
id: "20261014-01"
title: "Dinner with a friend"
created: "2026-10-14T22:10:00+09:00"
updated: "2026-10-14T22:10:00+09:00"
event_date: "2026-10-14"
tags: ["friends", "food"]
---
```

### Field meanings

| Field | Required | Meaning |
|---|---|---|
| `id` | Required | Unique identifier of the entry, in `YYYYMMDD-NN` format. |
| `title` | Required | Display title of the entry. |
| `created` | Required | Date-time the entry was first created. Never changes after creation. |
| `updated` | Required | Date-time the entry content was last updated. |
| `event_date` | Required | Date the event the entry is about took place. |
| `tags` | Required | Tags for classifying the entry. Use `[]` if none apply. |

### Date and time format

Write date-times in ISO 8601 format.

```yaml
created: "2026-10-14T22:10:00+09:00"
updated: "2026-10-14T22:10:00+09:00"
```

For a date only, use the following format.

```yaml
event_date: "2026-10-14"
```

- Treat dates and date-times as strings, so enclose them in quotes.
- For Japan Standard Time, add `+09:00` as the time zone. `mdjour-new.sh` uses the time zone of the execution environment, so to record in Japan Standard Time, set the environment's time zone to Japan Standard Time.
- Immediately after an entry is created, `created` and `updated` have the same value.

## Rules for `updated`

Update `updated` when you change the content of an entry or its meaningful metadata.

- Update it when you add to or correct the body. Fixing a typo counts as correcting the body.
- Update it when you change `title`, `tags`, or `event_date`.
- Update it when you add or change an attachment referenced from the body.
- Update it when you fix a link in the body because an attachment was moved or renamed.
- Never change `created`.
- Do not update it for changes that leave the content of the entry unchanged, such as reformatting the front matter or moving the entry file.
- When you update `updated`, include it in the same commit as the change to the entry. Do not make commits that change only `updated`, or commits in which the content is unchanged.

## Rules for `event_date`

`event_date` is the date the event recorded in the journal took place.

- Normally, specify the same date as the day the entry was created.
- If you record the previous day's event on the next day, specify the date the event took place.
- If you combine an event spanning several days into one entry, specify the starting date as the representative date.
- Manage `event_date` independently of `created` and `updated`.
- With `mdjour-new.sh`, specify it with `-e`. If omitted, it is the date of execution.

For example, if you write on October 14 about an event on October 13, it looks like this.

```yaml
created: "2026-10-14T10:50:00+09:00"
updated: "2026-10-14T10:50:00+09:00"
event_date: "2026-10-13"
```

## Rules for tags

Write `tags` as a YAML array.

```yaml
tags: ["friends", "food"]
```

If there are no tags, use an empty array.

```yaml
tags: []
```

- Keep tags short.
- Avoid inconsistent spellings for tags with the same meaning.
- Tags can be added or changed freely, but update `updated` when you change them.

## Managing attachments

Attachments are referenced from the body with Markdown links.  
Do not keep an `attachments` list in the front matter.

### Storage location

```text
attachments/YYYY/YYYY-MM-DD/
```

Example:

```text
attachments/2026/2026-10-14/restaurant.jpg
```

- Store attachments in `attachments/YYYY/YYYY-MM-DD/`.
- The year directory is based on the year the related entry was created.
- The date directory is based on the date the related entry was created.
- Even if the event took place the previous day, use the date the entry was created.
- Keep the original file name, or a name that shows what the file is.
- You can create the directory with `mdjour-new.sh -a`.

### Referencing from the body

If the entry file is `entries/2026/2026-10-14-01.md`, reference an attachment as follows.

```markdown
![Photo of the dinner](../../attachments/2026/2026-10-14/restaurant.jpg)
```

- Reference attachments with a path relative to the entry file.
- If you move or rename an attachment, fix the link in the body.
- If you add or change an attachment, update `updated`.

## Writing the body

After the closing `---` of the YAML front matter, write the body in Markdown.

```markdown
I had dinner with a friend today.

![Photo of the dinner](../../attachments/2026/2026-10-14/restaurant.jpg)

The restaurant was calm, and we had a good conversation.
```

- In the body, write the events you want to record in the journal, your impressions, and supplementary information.
- Do not force information that is obvious from the file name or location into the front matter.
- Include important words you may want to search for later in the body or in `tags`.

## Searching

### Full-text search

```bash
grep -Rni "friend" ~/mdjour/entries
```

### Tag search

```bash
grep -Rni "tags:.*friends" ~/mdjour/entries
```

### List entries for a month

```bash
ls ~/mdjour/entries/2026/2026-10-*.md
```

### List entries for a day

```bash
ls ~/mdjour/entries/2026/2026-10-14-*.md
```

### List titles

```bash
grep -R "^title:" ~/mdjour/entries
```

## Future database migration

If you migrate to a database in the future, each field of the YAML front matter maps as follows.

| YAML field | Example database column |
|---|---|
| `id` | Primary key, or a string column with a unique constraint |
| `title` | `title` |
| `created` | `created_at` |
| `updated` | `updated_at` |
| `event_date` | `event_date` |
| `tags` | A tag table, or an array column |
| Body | `body` or `content` |

- Keep `id` unchanged after migration.
- Dates and date-times are unified in ISO 8601 format, so they are easy to convert to database types.
- `tags` are managed as an array, so they can be split into a tag table.
- Keep the body as Markdown, and build a search index as needed.
