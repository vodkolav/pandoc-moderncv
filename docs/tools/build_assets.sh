set -e

DOCS_DIR=docs/assets
IN_DIR=tmp
OUT_DIR=output
STYLES_DIR="templates"
LOGS_DIR=logs
STYLE=moderncv
PDFengine=xelatex
FILE_NAME=JohnnyCoder
TMP_FL=$IN_DIR/$FILE_NAME

# This script creates screenshots for the README file out of the same README file.
# So that when I update the README, I need only to 
# run 'make assets' and not crop the screenshots manually again.


echo making screenshots of the cvitems for readme

mkdir -p $IN_DIR

# extract all ```markdown examples from README file into separate md file,
# \newpage between them forces one example per page in the pdf output. 
# the rest of the page remains blank.
pandoc README.md -L docs/tools/extract_md.lua -t markdown_strict -o $IN_DIR/$FILE_NAME.md 

#pandoc README.md -L docs/assets/extract_md.lua -t json -o $IN_DIR/$FILE_NAME.json

# convert this temp file into pdf using the very same filter and template used for the project
pandoc --standalone --template templates/moderncv.tex \
        --lua-filter=moderncv.lua \
        --from markdown --to pdf \
        --output $TMP_FL.pdf $TMP_FL.md 

# extract each page as separate image while trimming the blank space of the page
convert -density 300 $TMP_FL.pdf \
    -trim +repage \
    -gravity NorthWest \
    -background white \
    -extent 2480x \
    $DOCS_DIR/%d.png


echo making screenshot of md file 
# make a screenshot of raw markdown file for the comparison showcase in README


# create another temp md file which contains the whole content of JohnnyCoder as 
# markdown fenced code block. We don't need to go deeper :)
pwd
echo "\`\`\`markdown" > $TMP_FL.md 
head -45 markdown/JohnnyCoder.md >> $TMP_FL.md 
echo "..." >> $TMP_FL.md 
echo "\`\`\`" >> $TMP_FL.md 
#mv JC.md docs/assets/JC.md

# convert that temp md into html, while applying a VS code CSS theme, so that
# it looks like a screenshot from an IDE.
pandoc $TMP_FL.md  \
        -s \
        --no-highlight \
        --self-contained \
        --css docs/tools/VScodeDark.css \
        --highlight-style zenburn \
        -o $TMP_FL.html

# Finally, convert the html into png image.
wkhtmltoimage --quality 75 --width 1024 --enable-local-file-access $TMP_FL.html $DOCS_DIR/JohnnyCoderMD.png

echo making screenshot of final pdf

# create a screenshot of final rendered PDF.
convert -density 500 -quality 300 \
        -background white -alpha off \
        $OUT_DIR/$FILE_NAME.pdf  $DOCS_DIR/$FILE_NAME.png;\

echo all done!