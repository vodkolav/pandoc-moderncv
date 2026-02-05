
# CV items specification

This is part of specification for implementation of various types of CV items in the pandoc-moderncv filter. It is a work in progress, and is subject to change.

The main idea is to use Markdown definition lists (DefList further below) to represent CV items. In general , DefLists look like this:

```markdown
Term 1
: definition 1
: definition 2

Term 2
: definition 3
: definition 4
```
Definition lists are a good fit for CV items, as they consist of a Term (item title) and one or more definitions (item content/description).

A modified DefList syntax is proposed here, where both Term and definitions can be composite, i.e. can be split into multiple fields by a separator (the pipe character '|'). This allows to represent more complex CV items with multiple fields, such as job title, employer, location, dates etc.

The type of CV item is determined by the structure of the definition list: number of definitions per Term, and number of fields per Term and definition.

The general structure of a DefList item is as follows:

```markdown 
Term field 1 | Term field 2 | ...
: definition 1 field 1 | definition 1 field 2 | ...
: definition 2 field 1 | definition 2 field 2 | ...
```

Following are the various types of CV items supported, along with their mapping from Markdown to LaTeX.

# Simple items
DefList with one definition per Term.

## cvitem
If the DefList has one definition per Term and no separators in Term and definition, then it maps to `\cvitem`.

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
## cvitemwithcomment
If the DefList has one definition per Term and 2 fields (single separator) in the definition, it maps to `\cvitemwithcomment`.

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
DefList with multiple definitions per Term.

## cvdoubleitem / cvtripleitem
If a DefList has multiple definitions for each Term, but no more than two fields in each definition, they get mapped to `\cvdoubleitem` or `\cvtripleitem` - according to the number of definitions, but no more than 3, otherwise an error is raised.  
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

## cvcolumns

If a DefList has multiple definitions for each term (same as above: either 2 or 3, no more), but more (unlike above) than two fields in any of the definitions, then the DefList is mapped to `\cvcolumns`, with each definition being a column, first field being the category and the rest being an itemize list within that column. Term is omitted as well.

```markdown
# References (cvcolumns)

Table
: Category 1 | Person 1 | Person 2 | Person 3
: Category 2 | Person 42 | Person 0.37 | (more upon request)
: All the rest \& some more | That person, and those also (all available upon request)
```

# Complex items - Alternative implementation

Alternatively, Complex items may be defined as:  
A DefList with composite Term: one that can also be split into fields by the same separator.  
In such case, the number of Term fields and number of definitions must match (and no more than 3?), otherwise an error is raised.

> (or maybe some other item type/family can be defined - to be considered later. In such case, both composite Term and multiple definitions - serve as indications for using complex item, which might be redundant). 

## cvdoubleitem / cv**triple**item

If each definition has no more than one field, then 
- DefList is mapped to either `\cvdoubleitem` or `\cvtripleitem `
- according to the number of definitions, but no more than 3; otherwise an error is raised. 
- each Term field being an item category. 
- each definition being the item content. 

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
If any definition has more than one field, then:
- the DefList is mapped to `\cvcolumns`, 
- with each Term field being a heading for its respective column, 
- and each definition being a column; 
- each definition field is an item in itemize list for that column.

```markdown
Category 1 | Category 2 | All the rest \& some more 
: Person 1 | Person 2 | Person 3
: Person 42 | Person 0.37 | (more upon request)
: That person, and those also (all available upon request)
```

```latex
\begin{cvcolumns}
  \cvcolumn{Category 1}{\begin{itemize}\item Person 1\item Person 2\item Person 3\end{itemize}}
  \cvcolumn{Category 2}{\begin{itemize}\item Person 42 \item Person 0.37 \item (more upon request)\end{itemize}}
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
\end{cvcolumns}
```

## cvlistitem / cvlistdoubleitem

Consider using cvlistitem / cvlistdoubleitem for items within cventry instead of itemize lists. 

```latex
\cvlistitem{<item >}
\cvlistdoubleitem{<item 1>}{ item 2>}
```

## Skill matrix 
Consider using md tables for Skill matrix macros, smth like:

```markdown
# Skills matrix
| Skill       | Level  | Experience (years) |
|-------------|--------|--------------------|
| Python      | Expert | 10                 |
| C++         | Good   | 7                  |
```
maps to

```latex
\cvskill{Python}{Expert}{10}
\cvskill{C++}{Good}{7}
```