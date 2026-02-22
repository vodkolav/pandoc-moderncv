# Markdown to moderncv Filter

This Pandoc Lua filter converts a Markdown file into a LaTeX resume using the `moderncv` class. It maps YAML frontmatter to `moderncv`'s personal information macros and converts Markdown definition lists into formatted CV entries.

## Usage

To use this filter, invoke Pandoc with the following command, specifying your Markdown file and this Lua filter:

```bash
pandoc your-resume.md --from markdown --to latex --lua-filter=moderncv.lua -o output.tex
```

You must also use a `moderncv`-compatible Pandoc template, such as the `moderncv.tex` file provided in the parent directory.

Agent: 
- first describe the easier way: running with make
- don't tell user what he must. the template is already included. that's the natural choice.
- inclide the template with `--template=path/to/moderncv.tex` 


## Metadata (YAML Frontmatter)

Personal information is provided in a YAML frontmatter block at the top of your Markdown file. The filter injects this information into the LaTeX header.

### Supported Fields

- `name`: Your full name. Can also use `firstname` and `lastname`.
- `title`: The title of the document (e.g., "Curriculum Vitae" or "Business Analyst").
- `address`: Your mailing address.
- `phone` or `phones`: Your phone number(s).
- `email`: Your email address.
- `homepage` or `url`: Your personal website.
- `social`: A map of social media networks to usernames (e.g., `github: myuser`).
- `photo`: Path to a photo.
- `quote`: A brief quote.
- `extrainfo`: Any additional information.

### Theme Configuration

You can configure the `moderncv` theme directly from the YAML frontmatter. The following fields are supported under the `theme` key:

- `fontsize`: Font size for the document (e.g., `10pt`, `11pt`, `12pt`).
- `papersize`: Paper size for the document (e.g., `a4paper`, `letterpaper`).
- `fontfamily`: Font family for the document (e.g., `sans`, `roman`).
- `moderncvstyle`: Style of the `moderncv` class (e.g., `classic`, `banking`, `casual`). Agent: list all styles supported by moderncv.
- `moderncvcolor`: Color scheme for the `moderncv` class (e.g., `blue`, `green`, `red`).
- `scale`: Scale factor for the hints column width (e.g., `0.8`, `0.93`).

Agent: mention that all theme configuration options are optional and have default values. the user only needs to specify those they want to customize. 

#### Example Frontmatter

```yaml
---
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
  fontsize: 12pt
  papersize: a4paper
  fontfamily: sans
  moderncvstyle: banking
  moderncvcolor: green
  scale: 0.93
---
```

## CV Entries

The main content of your resume is created using Markdown definition lists under standard `#` and `##` section headings. The filter supports two main entry types, which map to `\cventry` and the `\cvitem` family of macros. Inline formatting like **bold**, *italic*, `code`, and [links](http://example.com) is preserved.

## Understanding Definition Lists

Definition lists are the core structure used to represent CV entries in Markdown. They consist of terms (titles) and definitions (content), and their variations determine the type of CV item generated in the final PDF.

### Basic Structure

A definition list in Markdown looks like this:

```markdown
Term 1
: Definition 1
    block content for Definition 1 (optional).
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

The type of CV item generated depends on:
1. The number of terms.
2. The number of definitions per term.
3. The number of fields within each term and definition.
4. Whether block content is present.

Agent: you've described the entries twice in the document. that's redundant. make document more concise , getting started-like. send user to docs to learn more.

#### Compact Entries

- **Single Term, Single Definition, No Block Content**:
  - Maps to `cvitem` or `cvitemwithcomment`.
  - Use `|` to add comments or additional fields.

**Example:**
```markdown
Skill
: Proficient | 5 years experience
```

#### Multi-Column Entries

- **Single Term, Single Definition, Multiple Fields**:
  - Maps to `cvdoubleitem` or `cvtripleitem`.

**Example:**
```markdown
Category 1 | Category 2
: Content 1 | Content 2
```

#### List Items

- **Single Term, Multiple Definitions, No Block Content**:
  - Maps to `cvlistitem` or `cvlistdoubleitem`.

**Example:**
```markdown
List (omitted)
: Item 1
: Item 2
: Item 3
```

#### Detailed Entries

- **Single Term, Single Definition, With Block Content**:
  - Maps to `cventry`.

**Example:**
```markdown
Job Title
: 2020--Present | Company Name | Location

    - Developed software.
    - Led a team.
```

#### Column-Based Entries

- **Single Term, Multiple Definitions, With Block Content**:
  - Maps to `cvcolumns`.

**Example:**
```markdown
Term (omitted)
: Category 1
    Content for Category 1.
: Category 2
    Content for Category 2.
```

### Tips for Using the Pipe Character

The `|` character is used to separate fields within terms or definitions. To avoid errors:
- Always add spaces around the `|` character (e.g., `Field 1 | Field 2`).
- If a `|` appears in the content itself, escape it or reformat the text to avoid confusion.

### Summary

All CV item types are variations of the same definition list structure. By adjusting the number of terms, definitions, fields, and block content, you can create any type of CV entry supported by the `pandoc-moderncv` filter.

## CV Content

### Sectioning

Top-level sections (`#`) represent CV topics, such as Education, Experience, Skills, etc. They contain entries. Second-level sections (`##`) are optional.

### Compact Entries

Compact entries are simple, one-line items without detailed descriptions. They are ideal for listing skills, qualifications, or other concise information.

#### Simple Items (`cvitem`)

Use a single `Term : Definition` structure for simple items.

**Markdown Example:**
```markdown
# Interests

hobby 1
: Description 1

hobby 2
: Description 2

hobby 3
: Description 3
```

**Resulting LaTeX:**
```latex
\section{Interests}
\cvitem{hobby 1}{Description 1}
\cvitem{hobby 2}{Description 2}
\cvitem{hobby 3}{Description 3}
```

#### Items with Comments (`cvitemwithcomment`)

Add a comment to the definition using the `|` separator.

**Markdown Example:**
```markdown
# Languages

**Klingon**
: native speaker | fluent in reading and writing

**English**
: so-so | learned in kindergarten
```

**Resulting LaTeX:**
```latex
\section{Languages}
\cvitemwithcomment{Klingon}{native speaker}{fluent in reading and writing}
\cvitemwithcomment{English}{so-so}{learned in kindergarten}
```

#### Multi-Column Items (`cvdoubleitem`, `cvtripleitem`)

Use multiple fields in the term and definition to create double or triple items.

**Markdown Example:**
```markdown
# Computer Skills

category Left | category Right
: content left | content right

category Left | category Center | category Right
: content left | content center | content right
```

**Resulting LaTeX:**
```latex
\cvdoubleitem{category Left}{content left}{category Right}{content right}
\cvtripleitem{category Left}{content left}{category Center}{content center}{category Right}{content right}
```

### List Items

List items are used for enumerations or grouped content. They can be single-column or double-column lists.

#### Single-Column Lists (`cvlistitem`)

**Markdown Example:**
```markdown
# Hobbies

list (omitted)
: Item 1
: Item 2
: Item 3
```

**Resulting LaTeX:**
```latex
\cvlistitem{Item 1}
\cvlistitem{Item 2}
\cvlistitem{Item 3}
```

#### Double-Column Lists (`cvlistdoubleitem`)

**Markdown Example:**
```markdown
double list (omitted)
: Item 1 | Item 4
: Item 2 | Item 5
: Item 3 | Item 6
```

**Resulting LaTeX:**
```latex
\cvlistdoubleitem{Item 1}{Item 4}
\cvlistdoubleitem{Item 2}{Item 5}
\cvlistdoubleitem{Item 3}{Item 6}
```

### Detailed Entries

Detailed entries are used for more complex content, such as job descriptions or project details. They allow for block content like paragraphs and lists.

#### Detailed Items (`cventry`)

**Markdown Example:**
```markdown
# Experience

**Lead Developer**
: 2020--Present | Awesome Corp, Inc. | Silicon Valley

    A detailed description of the job.

    - Developed and maintained critical software infrastructure.
    - Mentored junior developers and led code reviews.
```

**Resulting LaTeX:**
```latex
\section{Experience}
\cventry{2020--Present}{Lead Developer}{Awesome Corp, Inc.}{Silicon Valley}{}{
A detailed description of the job.
\begin{itemize}
\item Developed and maintained critical software infrastructure.
\item Mentored junior developers and led code reviews.
\end{itemize}
}
```

### Column-Based Entries (`cvcolumns`)

Use columns for structured content under the same categories.

**Markdown Example:**
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

**Resulting LaTeX:**
```latex
\begin{cvcolumns}
    \cvcolumn{Category 1}{Regular block content for category 1, which can include lists, code blocks, etc.}
    \cvcolumn{Category 2}{\begin{itemize}
    \item \textbf{Person 1}
    \item Person 2
    \item Person 3
    \end{itemize}}
    \cvcolumn{All the rest \& some more}{That person and those also (all available upon request).}
\end{cvcolumns}
```