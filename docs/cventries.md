> This is part of specification for implementation of various types of CV entries in the pandoc-moderncv filter. It is a work in progress, and is subject to change.

# Overview  
## Background 
The `moderncv` LaTeX class is a popular choice for creating professional resumes. However, authoring resumes directly in LaTeX can be cumbersome for many users. This project aims to bridge the gap by allowing users to write their resumes in Markdown, which is more user-friendly, and then convert them into LaTeX using a Pandoc Lua filter. The filter will interpret specific Markdown conventions and YAML frontmatter to populate the `moderncv` template accurately, preserving all inline formatting and links.

## Purpose 

The main goal is to enable users to maintain their resumes in Markdown format while leveraging the powerful formatting capabilities of LaTeX's `moderncv` class. This allows for easier editing and version control of resumes, while still producing high-quality PDF outputs.

Establish a clear mapping between Markdown constructs and `moderncv` LaTeX macros, ensuring that users can easily understand how to structure their Markdown files to achieve the desired output in LaTeX.

Convert Markdown resumes into LaTeX documents conforming to the `moderncv` class by implementing a robust Pandoc Lua filter and minimal template changes so frontmatter and several Markdown conventions map cleanly into `moderncv` macros. The filter must preserve inline formatting (bold, italic, links, code) inside fields and descriptions.

## Goals  
- Automatically populate `moderncv` personal data from Markdown frontmatter.  
- Support two entry conventions under section headings for author-friendly authoring: `\cventry` (detailed entry + description) and `\cvitem` family (compact, inline fields).  
- Preserve inline formatting and links inside fields and descriptions.  
- Keep changes local to moderncv.lua and the top-level Pandoc template (moderncv.tex) only; 
- No modification of [moderncv](https://github.com/moderncv/moderncv) project is required.

## Scope
- Implement: moderncv.lua — Lua filter handling Meta and document transformations.  
- Template tweak: moderncv.tex — render `header-includes` in preamble 
- Documentation: update or add short guide in manual (e.g., README.md).
- Examples: provide example Markdown resumes demonstrating the new features and conventions.
- Provide a Makefile and build scripts for users to easily generate PDFs from Markdown.

## Pipe dreams
- Testing: ensure the filter works correctly with various Markdown inputs and produces valid LaTeX output.
- Provide a Makefile and build scripts for Windows.
- Provide template to generate docx and other formats from Markdown, using the same frontmatter and conventions.
- Provide templates for other LaTeX resume classes (e.g., `res`, `resume`, `awesomecv`).
- Provide a Docker image for users to easily generate PDFs from Markdown without installing dependencies.

# Primary CV components

## Metadata 
Put personal info in YAML frontmatter (e.g., `name`, `firstname`, `lastname`, `title`, `address`, `phone` or `phones`, `email`, `homepage` / `url`, `social` map). Filter injects corresponding LaTeX macros into `header-includes`.  

## Theme configuration
Configure `moderncv` theme from frontmatter under `theme` key: `fontsize`, `papersize`, `fontfamily`, `moderncvstyle`, `moderncvcolor`, `scale`. Filter injects corresponding LaTeX macros into `header-includes`.  

## CV Content

### Sectioning 
Top-level sections (`#`) represent CV topics, such as Education, Experience, Skills, etc. 
They contain entries. 
Second-level sections (`##`) are optional.

### Entries 
- Entries represent individual CV items (jobs, degrees, courses, skillsets, etc.)
- Entries are written as Pandoc Definition lists with custom structure.
- The structure of the Definition list defines the type of an entry, which ultimately determines how the entry is rendered in the final PDF document.
- All parts of the entries preserve their inner formatting. 


# Entry Syntax
The main idea is to use Markdown definition lists to represent entries. In general, a Definition lists look like this:

```markdown
Term 1
: definition 1
    Block content elements for definition 1 (optional)
: definition 2 (optional)
    Block content elements for definition 2 (optional)

Term 2
: definition 3
    Block content elements for definition 3 (optional)
: definition 4 (optional)
    Block content elements for definition 4 (optional)
```

Definition lists are a good fit for CV items, as they consist of a Term (item title) and one or more definitions (item content/description), which can be further described by regular blocks (paragraphs, lists, code blocks, etc.).

A slightly extended version of the DefList syntax is proposed here, where both Term and definitions can be composite, i.e. can be split into multiple fields by a separator (the pipe character '|'). This allows to represent more complex CV items with multiple fields, such as job title, employer, location, dates etc.

The general structure of a DefList item is as follows:

```markdown 
Term field 1 | Term field 2 | ...
: definition 1 field 1 | definition 1 field 2 | ...
    Block content elements for definition 1 (optional)
: definition 2 field 1 | definition 2 field 2 | ...
    Block content elements for definition 2 (optional)
```

Following the pandoc manual on [DefinitionLists](https://pandoc.org/MANUAL.html#definition-lists): 

> A Term may have multiple Definitions, and each Definition may consist of one or more block elements (paragraph, code block, list, etc.), each indented four spaces or one tab stop. The body of the definition (not including the first line) should be indented four spaces., 
We determine the type of entry according to the structure of the Definition list: 
- whether definitions have block content or not (either 0 or more)
- number of definitions per Term (either 1 or more)
- number of fields per Term (either 1 or more)
- number of fields per definition (either 1 or more)  

# Entry types
Thus 2 major types of entry macros emerge: 

1. **Compact Entries (`\cvitem` family)**  
2. **Detailed Entries (`\cventry`)**  

The rules that determine the exact macro, along with their mapping from Markdown to LaTeX, are in [cvitems.md](cvitems.md)
