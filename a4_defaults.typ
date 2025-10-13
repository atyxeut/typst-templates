#import "@preview/zebraw:0.5.5": *

#let normal_text_size = 13pt;

// alias of numbered math.equation
#let eqn(content) = {
  math.equation(block: true, numbering: "(1)", content)
}

// display a right aligned Q.E.D. symbol
#let QED() = {
  h(1fr)
  $qed$
}

#let default_style(body) = {
  // page default style
  set page(paper: "a4", numbering: "1", number-align: center, margin: (x: 1.8cm, y: 1.2cm))

  // paragraph default style
  set par(
    justify: true,
    linebreaks: "simple",
  )

  // text default style
  set text(
    hyphenate: true,
    font: ("Libertinus Serif", "Noto Sans SC"),
    size: normal_text_size,
    weight: "light",
  )

  // heading default style
  set heading(numbering: none)

  // terms default style
  set terms(hanging-indent: 0em)

  // code block default style, ligature off
  show raw: set text(font: ("Fira Code", "Noto Sans SC"), size: 10pt, features: (calt: 0))
  // inline code block default style
  show raw.where(block: false): box.with(
    fill: luma(240),
    inset: (x: 4pt, y: 1pt),
    outset: (y: 3pt),
    radius: 0.2em,
  )

  // zebraw package style
  show: zebraw.with(inset: (top: 4pt, bottom: 4pt, left: 4pt, right: 4pt), indentation: 2, hanging-indent: true)

  body
}

