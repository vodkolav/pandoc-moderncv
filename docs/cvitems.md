



# Compact Entries (`\cvitem` family)

If
1. first definition has no body of block elements (paragraph, code block, list, etc.)


Then it's mapped to one of the `\cvitem` family of macros.

The rules that determine the exact macro, along with their mapping from Markdown to LaTeX, are as follows:

# Simple items
DefList with one definition and a single field in Term (e.g. no separators in Term)

## cvitem
A Simple item with one field in definition (e.g. no separators in definition), then it maps to `\cvitem`.

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
A Simple item with 2 fields (single separator) in the definition, maps to `\cvitemwithcomment`.

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

Complex items are defined as:  
A DefList with multiple definitions and composite Term: a Term that can also be split into fields by the same separator.  
In such case, the number of Term fields and number of definitions must match (and no more than 3?), otherwise an error is raised. [^1]

## cvdoubleitem / cv**triple**item

If all definitions have no more than one field, then 
- DefList is mapped according to the number of definitions to either `\cvdoubleitem` for 2 definitions or `\cvtripleitem` for 3 definitions,
- more than 3 definitions raises an error. 
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
- each Term field being a heading for its respective column, 
- each definition being a column; 
- each definition field being an item in itemize list for that column.
- mixed cases need no special treatment. For example, if some definitions have one field and some have more, then the ones with one field are just treated as having one item in their respective column. 

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

# Edge cases
Empty definitions or terms: these should not occur in practice, as such structure will not be recognized as a valid DefList by pandoc, and thus will not be processed by the filter. However, if it does occur, it can be treated as a special case and mapped to `\cvitem` with empty parameters.

# Pseudocode 
for item type determination logic

```pseudo
#definitions = 0 
    \\cvitem{term}{}

#definitions > 0 
    definition[1] has block content 
        #definitions > 1
            error.  cventry must have 1 definition.
        #definitions = 1
            def1.#fields < 4
                \\cventry{...}
            def1.#fields >= 4
                error. cventry supports no more than 4 fields
    definition[1] has NO block content 
        \\cvitem family...

        #definitions = 1 (also implies single Term field)
            Simple items...
            definition[1].#fields = 1 
                \\cvitem{term}{def} 
            definition[1].#fields = 2 
                \\cvitemwithcomment{term}{def.field1}{def.field2} 
            definition[1].#fields > 2
                error. up to 2 fields supported. use commas

        #definitions > 1 (also implies multiple Term fields)
            Term.#fields <> #definitions
                error. in complex items term.#fields must = #definitions

            Term.#fields = #definitions
                Complex items...
                exists definition: definition.#fields > 1 
                    \\cvcolumns...
                        \\cvcol{term1}{\\itemize{def1.f1, def1.f2, def1.f3,...}}
                        \\cvcol{term2}{\\itemize{def2.f1 }}
                        \\cvcol{term3}{\\itemize{def3.f1, def3.f2, }}
                        ... 

                forall definitions: definition.#fields = 1 
                    #definitions = 2 (also implies 2 Term fields)
                        \\cvdoubleitem{term1}{def1}{term2}{def2}
                    #definitions = 3 (also implies 3 Term fields)
                        \\cvtripleitem{term1}{def1}{term2}{def2}{term3}{def3}
                    #definitions > 3
                        error. up to 3 items supported

```

This should cover most common CV item types.


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

## Footnotes
[^1]: (or maybe not error, but some other item type/family can be defined - to be considered later. 
With current definition, both "composite Term" and "multiple definitions" - serve as indications for using complex item, which might be redundant). 