
# md -> latex
- map the rest of frontmatter items
- option to specify frontmatter metadata in a separate yaml file
- fix languages section (try to use moderncv's class)
- insert \filbreak between sections and definitinlists automatically (except for the first deflist after the section) 
- do proper recursive merge of frontmatter metadata with default settings, instead of just overriding the whole settings table. This way users can specify only the settings they want to change, without having to copy the whole default settings structure.
- allow to override frontmatter settings with command line variables, so that users can easily change settings without having to edit the markdown file. This is especially useful for users who want to use the same markdown file to generate multiple versions of their resume with different settings (e.g., different themes, colors, etc.).
- In all error messages, print the line number and the content of the line where the error occurred, to make it easier for users to find and fix the issue in their markdown file.
- implement skills matrix and publications sections.
- document non-moderncv features, like colorlinks
- find a away to get rid of aux and log files from output dir/ 
- make a pandoc-filters and docker package for this project, so that users can easily use it in their own pandoc projects
- make docx, html templates 
- clean up, refactor, and document the code
- rename theme to style

# errors 

# Fixed

can't have multiple paragraphs within cventry's last parameter. current workaround: just removing double newline, but then the paragraphs merge into one. Fix: just use \ in the end of para

# Done

- map frontmatter title to cv job title
- define moderncv theme variables (like \moderncvstyle{classic}, \usepackage[scale=0.8]{geometry} ) in frontmatter under settings 
- probably documentclass options should be specified in something different than Meta
- move this whole project into a separate repo, independent from modern cv