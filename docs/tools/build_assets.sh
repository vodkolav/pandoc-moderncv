set -e

DOCS_DIR=docs/assets
IN_DIR=tmp
OUT_DIR=output
STYLES_DIR="templates"
LOGS_DIR=logs
STYLE=moderncv
PDFengine=xelatex
FILE_NAME=readme_fenced
TMP_FL=$IN_DIR/$FILE_NAME

# make screenshots of the cvitems for readme

mkdir -p $IN_DIR

pandoc README.md -L docs/tools/extract_md.lua -t markdown_strict -o $IN_DIR/$FILE_NAME.md 

#pandoc README.md -L docs/assets/extract_md.lua -t json -o $IN_DIR/$FILE_NAME.json

pandoc --standalone --template templates/moderncv.tex \
        --lua-filter=moderncv.lua \
        --from markdown --to pdf \
        --output $TMP_FL.pdf $TMP_FL.md 

convert -density 300 $TMP_FL.pdf \
    -trim +repage \
    -gravity NorthWest \
    -background white \
    -extent 2480x \
    $DOCS_DIR/%d.png


# make screenshot of md file 

pwd
echo "\`\`\`markdown" > $TMP_FL.md 
head -45 markdown/JohnnyCoder.md >> $TMP_FL.md 
echo "..." >> $TMP_FL.md 
echo "\`\`\`" >> $TMP_FL.md 
#mv JC.md docs/assets/JC.md

#cd docs/assets/ && 
pandoc $TMP_FL.md  \
        -s \
        --no-highlight \
        --self-contained \
        --css docs/tools/VScodeDark.css \
        --highlight-style zenburn \
        -o $TMP_FL.html
        
#cd docs/assets/ && 
wkhtmltoimage --quality 100 --width 1024 --enable-local-file-access $TMP_FL.html $DOCS_DIR/JohnnyCoderMD.png

# make screenshot of final pdf

convert -density 500 -quality 300 \
        -background white -alpha off \
        $(OUT_DIR)/$FILE_NAME.pdf  $DOCS_DIR/$FILE_NAME.png;\
