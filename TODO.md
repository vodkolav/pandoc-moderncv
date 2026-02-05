
# md -> latex
- map frontmatter title to cv job title
- map the rest of frontmatter items
- define moderncv theme variables (like \moderncvstyle{classic}, \usepackage[scale=0.8]{geometry} ) in frontmatter under settings 
- option to specify frontmatter metadata in a separate yaml file
- fix languages section (try to use moderncv's class)
- probably documentclass options should be specified in something different than Meta
- insert \filbreak between sections and definitinlists automatically (except for the first deflist after the section) 

# errors 

# Fixed

can't have multiple paragraphs within cventry's last parameter. current workaround: just removing double newline, but then the paragraphs merge into one. Fix: just use \ in the end of para

# Done

- move this whole project into a separate repo, independent from modern cv