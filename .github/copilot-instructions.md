# AI Coding Agent Instructions for `pandoc-moderncv`

This document provides essential guidance for AI coding agents working on the `pandoc-moderncv` project. Follow these instructions to ensure productivity and alignment with the project's goals.

## Project Overview

`pandoc-moderncv` is a Pandoc Lua filter that converts Markdown files into LaTeX resumes using the `moderncv` class. The filter processes YAML frontmatter for personal information and maps Markdown definition lists to LaTeX macros for CV entries.

### Key Files and Directories

- `moderncv.lua`: The core Lua filter that implements the Markdown-to-LaTeX conversion.
- `templates/moderncv.tex`: The Pandoc template compatible with the `moderncv` LaTeX class.
- `markdown/`: Contains example Markdown resumes.
- `output/`: Stores generated `.tex` and auxiliary files.
- `logs/`: Contains debug logs for troubleshooting.

## Developer Workflows

### Building Resumes

To generate a LaTeX resume from a Markdown file, use the following command:

```bash
make pdf
```

This command invokes Pandoc with the appropriate options and the `moderncv.lua` filter. Ensure that the `moderncv` LaTeX class is installed on your system.

### Debugging

- Check `logs/debug_log.txt` for detailed logs if the filter does not behave as expected.
- Use `print` statements in `moderncv.lua` to debug Lua code.

## Code Conventions

### YAML Frontmatter

The filter expects specific fields in the YAML frontmatter of Markdown files. Examples include:

```yaml
firstname: John
lastname: Doe
title: Curriculum Vitae
email: john.doe@example.com
```

### Markdown Definition Lists

- Use `:` to define entries.
- Separate fields with `|` for multi-field entries.

Example:

```markdown
2020--2025
: **Job Title** | Company Name | Location
```

### LaTeX Macros

The filter maps Markdown constructs to `moderncv` LaTeX macros:

- `\cventry` for detailed entries.
- `\cvitem` and `\cvitemwithcomment` for compact entries.

## Tips for AI Agents

- **Understand the YAML structure**: The filter heavily relies on YAML metadata. Familiarize yourself with the supported fields.
- **Follow the Markdown-to-LaTeX mapping**: Refer to the README for examples of how Markdown is converted.
- **Use the `logs/` directory**: Debug logs are invaluable for troubleshooting.
- **Preserve existing patterns**: Maintain consistency with the established Markdown and LaTeX conventions.

## External Dependencies

- `moderncv` LaTeX class: Ensure it is installed and accessible.
- Pandoc: Required for Markdown-to-LaTeX conversion.

## Additional Resources

- [README.md](../README.md): Comprehensive usage instructions and examples.
- [moderncv.lua](../moderncv.lua): Core implementation of the filter.

---

For any unclear or incomplete sections, please provide feedback to iterate on this document.
