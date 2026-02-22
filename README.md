# Markdown to moderncv Filter

This Pandoc Lua filter converts Markdown resumes into PDF via LaTeX using the popular `moderncv` class. It expects a simple Markdown structure (YAML frontmatter + definition lists) and turns those into nicely formatted CV sections.

|||
|---|---|
| ![Page 1](docs/assets/JohnnyCoder-0.png) |![Page 2](docs/assets/JohnnyCoder-1.png)|


# Requirements

- Pandoc 2.0 or newer
- LaTeX with `moderncv` package installed

# Getting started
- Clone this repo and navigate to it in your terminal.
- Make a copy of markdown/JohnnyCoder.md and [edit](#authoring-cv-content) it with your own info.
- Run `make pdf` in this repository to compile all files under `markdown/`.
- The result PDFs will be in the `output/` directory.


Direct Pandoc command:
```bash
pandoc your-resume.md --from markdown --to pdf --lua-filter=moderncv.lua --template=templates/moderncv.tex -o output.pdf
```

# Authoring CV content 
The content of the markdown file must be structured in a specific way for the filter to recognize it and convert it into the appropriate LaTeX commands. 

## Metadata (YAML)
Personal info and theme configuration go in the YAML frontmatter. 

### Basic personal info 
- `name`: Your full name. Can also use `firstname` and `lastname`.
- `title`: The title of the document (e.g., "Curriculum Vitae" or "Business Analyst").
- `address`: Your mailing address.
- `phone` or `phones`: Your phone number(s).
- `email`: Your email address.
- `social`: A map of social media networks to usernames (e.g., `github: myuser`).
- `photo`: Path to a photo.

### Theme options (optional): 

- `fontsize`: Font size for the document (e.g., `10pt`, `11pt`, `12pt`).
- `papersize`: Paper size for the document (e.g., `a4paper`, `letterpaper`).
- `fontfamily`: Font family for the document (e.g., `sans`, `roman`).
- `moderncvstyle`: Style of the `moderncv` class (e.g., `classic`, `banking`, `casual`,  `oldstyle`, `fancy`, `contemporary`).
- `moderncvcolor`: Color scheme for the `moderncv` class (e.g., `blue`, `green`, `red`).
- `scale`: Scale factor for the hints column width (e.g., `0.8`, `0.93`).

    Only specify options you want to change; sensible defaults are used otherwise.

Example Frontmatter:

```yaml

firstname: Johnny
lastname: Coder
title: Curriculum Vitae
address: "123 Parkway Drive, Mytown, Mycountry"
phone: "+00 (0)00 000 0000"
email: "email@example.com"
homepage: "www.johnnycoder.com"
social:
  github: Johnny-Coder
  linkedin: johnny-coder
theme:
  moderncvstyle: classic
  moderncvcolor: purple
  scale: 0.9

```

## CV Sections 
The CV is separated into sections (such as `# Experience`, `# Education`, etc.) using standard `#` and `##` section headings. `##` are optional and can be used for further sub-sectioning if needed.

## CV items 

The main content of your resume is created using [Extended Markdown definition lists](#appendix-understanding-definition-lists) under section headings. The structure of the definition list determines how the content is rendered in the final PDF. The syntax is designed with the intent that the visual structure you want in the PDF should be roughly mirrored by the structure of the definition list in Markdown.

## Examples 
Below are minimal examples for each implemented entry type; markdown on top, resulting Rendered PDF block below. 

### Simple (one-line)
Term + single definition, no block content = compact item (one-line output).

```markdown
# Interests

hobby 1
: Description 1

hobby 2
: Description 2
```

![Rendered PDF](docs/assets/1.png)


### Item with comment
Term + single definition with 2 fields, no block content = compact item (one-line + comment on the right) output

```markdown
# Languages

English
: Fluent | learned in school
```

![Rendered PDF](docs/assets/2.png)

### Double / Triple items
Term with `n` (either 2 or 3) fields + single definition with `n` fields, no block content = multi-column single-line item. `n` determines whether it's a double or triple item. \
If you need more lines, repeat the item. 
It is recommended not to mix double/triple items within the same section, as it will lead to inconsistent formatting.

```markdown
# Computer Skills

Programming | Tools
: Python, C++ | Git, Docker

Left | Center | Right
: A | B | C
```

![Rendered PDF](docs/assets/3.png)

### List items
Single term + multiple definitions = list-style items 

The Term itself is omitted from output, only the definitions are rendered as items in a list.

```markdown
# Hobbies
my hobbies
: Skiing
: Cooking
: Photography
```

2 fields in **All** definitions = double-column list-style items

```markdown
double list 
: Item A | Item D
: Item B | Item E
: Item C | Item F
```

![Rendered PDF](docs/assets/4.png)


### Detailed entry (job / project / education)
Single Term + single definition with up to 4 fields, with indented block content = detailed item (job/project with description and bullets).

```markdown
# Experience

Senior Engineer
: 2018--2024 | Acme Corp | Remote

    Led platform team.
    - Built APIs
    - Improved reliability
```

![Rendered PDF](docs/assets/5.png)

### Columns (multiple named columns)
Single Term + multiple definitions, each with block content = column layout (multiple named columns).\
Like in lists, the Term is omitted from output, only the definitions are rendered as columns. \
The number of definitions determines the number of columns. The content of each definition is rendered within the corresponding column, and block content formatting is preserved.

```markdown
# References

Term (omitted)
: Category 1

    Regular block content for category 1, which can include lists, code blocks, etc.

: Category 2

    - **Person 1**
    - Person 2
    - Person 3

: All the rest & some more

    That person and those also (all available upon request).
```

![Rendered PDF](docs/assets/6.png)

That's the minimal quickstart. For full details, examples and edge cases see the files in `docs/`.



## Appendix: Understanding Definition Lists 

### Basic Structure

A definition list in Markdown looks like this:

```markdown
Term 1
: Definition 1
    block content for Definition 1 (optional).
    - some complex formatting (optional)
    more content (optional)
: Definition 2 (optional).
    block content for Definition 2 (optional).

Term 2
: Definition 3
    block content for Definition 3 (optional).
```

- **Term**: The title or heading for the entry.
- **Definition**: The content or description associated with the term.
- **Block Content**: Optional additional content, such as paragraphs, lists, or code blocks, indented under the definition.

### Extended Structure with Fields

To represent more complex CV items, this project introduces composite terms and definitions: ones that can be split into multiple fields using the pipe (`|`) character. For example:

```markdown
Term Field 1 | optional Term Field 2
: Definition Field 1 | optional Definition Field 2
    block content for the definition (optional).
```

- **Fields**: Subdivisions within terms or definitions, separated by `|`. These allow for multi-column layouts or additional metadata.

### Mapping to CV Item Types

Extended Definition lists are the core structure used to represent CV entries in this project. 
The type of CV item generated in the final PDF depends on:

- The number of definitions per term.
- The number of fields within each term and definition.
- Whether block content is present in the first definition.