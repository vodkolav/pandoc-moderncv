---
author: Johnny Coder
title: Awesomeness Manager
email: email@example.com
phone:  +00 (0)12 345 6789
address:  Mytown, Mycountry
homepage: www.johndoe.com
quote: "In space, no one can hear you code."
social:
    linkedin: Johnny-Coder
    twitter: jdoe
    github: Johnny-Coder
---

Text without definition lists is rendered as regular paragraph, filling the whole width of the document. Often used in the "About" block, where you can briefly list your specialties.
 - List items are nice to have here 
 - They do a line break by definition. 

But regular consecutive paragraphs (newline was here, where'd it go?)
get concatenated into one unless backslash is used.\
Ending a line with a backslash forces a line break.


# Education (cventry)

year–year 
: Degree | Institution | City | Grade

    Description. Can be one or more lines, and can include lists, links, etc. \

2010-2014 (expected)
: **PhD, Computer Science** | Awesome University | MyTown

    Thesis title: Deep Learning Approaches to the Self-Awesomeness Estimation Problem
    - Minor: Awesomeology

    - Major: Awesome Science


# Master thesis (cvitem)

title 
: Title (cvitem)

supervisors 
: Supervisors (cvitem)

description 
: Short thesis abstract (cvitem)

# Experience

## Vocational (cventry)
<!-- single term, single definition, 1 - 4 fields, has block content -->

1647-1650 
: Job title | Employer | City 

    General description no longer than 1–2 lines.
    Detailed achievements:
    - Achievement 1
    - Achievement 2 (with sub-achievements)
        - Sub-achievement (a);
        - Sub-achievement (b), with sub-sub-achievements (don’t do this!);
            · Sub-sub-achievement i;
            · Sub-sub-achievement ii;
            · Sub-sub-achievement iii;
        - Sub-achievement (c);
    * Achievement 3
    * Achievement 4

1645-1647
: Job title | Employer | City

    Description line 1 \
    Description line 2 \
    Description line 3 \

## Miscellaneous (cventry)

year–year 
: Job title | Employer | City

    Description


# Interests (cvitem)
<!-- single term, single definition, single field, no block content -->

hobby 1 
: Description 

hobby 2 
: Description 

hobby 3 
: Description


# Languages (cvitemwithcomment)
<!-- single term, single definition, 2 fields, no block content -->

Language 1 
: Skill level | Comment

Language 2 
: Skill level | Comment

Language 3 
: Skill level | Comment

Language 4 
: Skill level | Comment

Note: up to 2 fields supported. you can put more content in the field itself, but it will not be split into more fields.

# Computer skills (cvdoubleitem ,cvtripleitem)
<!-- 2 or 3 terms, single definition, 2 or 3 fields, no block content -->

**Left** | **Right**
: content left | content right 

category 2 | category 5 
: XXX, YYY, ZZZ | XXX, YYY, ZZZ

**left** | **center** | **right** 
: content left | content center | content right 

category 3 | category 6
: XXX, YYY, ZZZ | XXX, YYY, ZZZ


# Extra 1(cvlistitem)
<!-- single term (omitted), multiple definitions, single field, no block content -->

list (omitted)
: Item 1 
: Item 2 
: Item 3. This item is particularly long and therefore normally spans over several lines. Did you notice the indentation when the line wraps?


# Extra 2 (cvlistdoubleitem)
<!-- single term (omitted), multiple definition, 2 fields, no block content -->

double list (omitted)
: Item 1 | Item 4 
: Item 2 | Item 5 
: Item 3 | Item 6. Like item 3 in the single column list before, this item is particularly long to wrap over several lines 


# References (cvcolumns)
<!-- single term (omitted), multiple definitions, single field in all definitions, has block content -->
here, block content formatting is preserved.

columns (omitted)
: Category 1 

    reguar block content for category 1, \
    which can include lists, code blocks, etc.

: Category 2 

    - **Person 1**
    - Person 2
    - Person 3

: All the rest & some more

    That person \
    and those also \
    (all available upon request).

<!-- 
# Skill matrix (cvskillentry, under construction)

Skill matrix Alternatively, provide a skill matrix to show off your skills
basic knowledge
extensive project experience
intermediate knowledge with some project experience
deepened expert knowledge
expert / specialist

| What | Level | Skill | Years | Comment |
|---|---|---|---|---|
| Language:|3|Python | 2 | I’m so experienced in Python and have realised a million projects. At least.|
| Language: | 2 | Lilypond | 14 | So much sheet music! Man, I’m the best! |
| Language: | 3 |LATEX | 14 | Clearly I rock at LATEX |
| OS: | 3 | Linux | 2 | I only use Archlinux btw |
| Methods: | 4 | SCRUM | 8 | SCRUM master for 5 years | -->


# Publications (under construction)
[1] John Doe. Title, year.

[2] John Doe. Title, year.

[3] John Doe and Author 1. Title. Publisher, edition edition, year.

[4] John Doe and Author 2. Title. Publisher, edition edition, year.

[5] John Doe and Author 3. Title, year.