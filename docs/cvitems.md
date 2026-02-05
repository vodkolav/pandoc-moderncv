
# CV items specification

This is part of specification for implementation of various types of CV items in the pandoc-moderncv filter. It is a work in progress, and is subject to change.

# Simple items

## cvitem

```markdown
# Interests (cvitem)

hobby 1
: Description (cvitem)

hobby 2
: Description (cvitem)

hobby 3
: Description (cvitem)
```
maps to 

```latex
\section{Interests}
\cvitem{hobby 1}{Description (cvitem)}
\cvitem{hobby 2}{Description (cvitem)}
\cvitem{hobby 3}{Description (cvitem)}
```

```markdown
# Languages (cvitemwithcomment)

**Klingon**
: native speaker | fluent in reading and writing

**English** 
: so-so | learned in kindergarten

Language 3
: Skill level | Comment

Language 4
: Skill level | Comment 

```
maps to 

```latex
\section{Languages (cvitemwithcomment)}
\cvitemwithcomment{Klingon}{native speaker}{fluent in reading and writing}
\cvitemwithcomment{English}{so-so}{learned in kindergarten}
\cvitemwithcomment{Language 3}{Skill level}{Comment}
\cvitemwithcomment{Language 4}{Skill level}{Comment} 
```

# Complex items

If a DefList has multiple definitions for each term, but no more than two fields in each definition, they get mapped to \cvdoubleitem or \cvtripleitem - according to the number of definitions, but no more than 3, in which case an error is raised. 
The Term (line1, line2,... below) of each definition is omitted, only the definitions' contents are used. 
Double and triple items may be mixed in the same section, but is unadvised for readability.

```markdown
# Computer skills (cvdoubleitem)

line1
: category 1 | XXX, YYY, ZZZ
: category 4 | XXX, YYY, ZZZ

line2
: category 2 | XXX, YYY, ZZZ
: category 5 | XXX, YYY, ZZZ

line3 (cvtripleitem)
: category 7 | XYZ
: category 8 | XYZ
: category 9 | XYZ

line4
: category 3 | XXX, YYY, ZZZ
: category 6 | XXX, YYY, ZZZ
```
maps to 

```latex
\cvdoubleitem{category 1}{XXX, YYY, ZZZ}{category 4}{XXX, YYY, ZZZ}
\cvdoubleitem{category 2}{XXX, YYY, ZZZ}{category 5}{XXX, YYY, ZZZ}
\cvtripleitem{category 7}{XYZ}{category 8}{XYZ}{category 9}{XYZ} 
\cvdoubleitem{category 3}{XXX, YYY, ZZZ}{category 6}{XXX, YYY, ZZZ}
```

If a DefList has multiple definitions for each term (as above, either 2 or 3, no more), but more (unlike above) than two fields in any of the definitions, then the DefList is mapped to `\cvcolumns`, with each definition being a column, first field being the category and the rest being an itemize list within that column. Term is omitted as well.

```markdown
# References (cvcolumns)

Table
: Category 1 | Person 1 | Person 2 | Person 3
: Category 2 | Person 42 | Person 0.37 | (more upon request)
: [0.5]All the rest \& some more | That person, and those also (all available upon request)
```

# Complex items - Alternative implementation

Alternatively, A sub-family 'complex items' may be defined: The Term can also be composite by splitting it into fields by "|".  
In such case, the number of term fields and number of definitions must match (and no more than 3?), otherwise an error is raised (or maybe some other item type/family can be defined - to be considered later. In such case, both composite Term and multiple definitions - serve as indications for using complex item, which might be redundant). 

## cvdoubleitem / cv**triple**item

If each definition has no more than one field, then DefList is mapped to `\cvdoubleitem` or `\cvtripleitem `- each Term field being an item category and each definition being the content. 

```markdown
# Computer skills (cvdoubleitem)
category 1 | category 4
: content - XXX, YYY, ZZZ
: more content - XXX, YYY, ZZZ

category 2 | category 5 
: XXX, YYY, ZZZ
: XXX, YYY, ZZZ

category 7 | category 8 | category 9 (cvtripleitem)
: XYZ
: XYZ
: XYZ

category 3 | category 6
: XXX, YYY, ZZZ
: XXX, YYY, ZZZ
```
maps to 

```latex
\cvdoubleitem{category 1}{XXX, YYY, ZZZ}{category 4}{XXX, YYY, ZZZ}
\cvdoubleitem{category 2}{XXX, YYY, ZZZ}{category 5}{XXX, YYY, ZZZ}
\cvtripleitem{category 7}{XYZ}{category 8}{XYZ}{category 9}{XYZ} 
\cvdoubleitem{category 3}{XXX, YYY, ZZZ}{category 6}{XXX, YYY, ZZZ}
```

## cvcolumns
If any definition has more than one field, the DefList is mapped to `\cvcolumns`, with each Term field being a heading for its respective column, and each definition being a column; each definition field is an item in itemize list for that column.

```markdown
Category 1 | Category 2 | All the rest \& some more 
: Person 1 | Person 2 | Person 3
: Person 42 | Person 0.37 | (more upon request)
: That person, and those also (all available upon request)
```

```latex
\begin{cvcolumns}
  \cvcolumn{Category 1}{\begin{itemize}\item Person 1\item Person 2\item Person 3\end{itemize}}
  \cvcolumn{Category 2}{Amongst others:\begin{itemize}\item Person 1, and\item Person 2\end{itemize}(more upon request)}
  \cvcolumn{All the rest \& some more}{\textit{That} person, and \textbf{those} also (all available upon request).}
\end{cvcolumns}
```


# Features to consider implementation later

## In case of complex items / cvcolumns :
Each Term field might have an optional width specification in square brackets, e.g. [0.5], to control the relative width of that column.

```markdown
Category 1 | Category 2 | [0.5]All the rest \& some more 
: Person 1 | Person 2 | Person 3
: Person 42 | Person 0.37 | (more upon request)
: That person, and those also (all available upon request)
```
maps to

```latex
\begin{cvcolumns}
  \cvcolumn{Category 1}{\begin{itemize}\item Person 1\item Person 2\item Person 3\end{itemize}}
  \cvcolumn{Category 2}{Amongst others:\begin{itemize}\item Person 1, and\item Person 2\end{itemize}(more upon request)}
  \cvcolumn[0.5]{All the rest \& some more}{\textit{That} person, and \textbf{those} also (all available upon request).}
\end{cvcolumns}```