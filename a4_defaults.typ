#import "@preview/zebraw:0.3.0": *

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
  set page(paper: "a4", numbering: "1", number-align: center, margin: (x: 1.25cm, y: 1cm))

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
  set heading(numbering: "1.1")
  // put numbering on the right for certain headings
  show heading: it => {
    let include_list = ("Proposition",)
    let is_special_heading(content) = {
      if type(content) == str {
        for s in include_list {
          if content.starts-with(s) {
            return true
          }
        }
      } else {
        for s in include_list {
          if content.first().fields().values().first().starts-with(s) {
            return true
          }
        }
      }
      return false
    }

    let numbering_left_aligned_it = block({
      counter(heading).display(it.numbering)
      h(0.3em)
      it.body
    })

    let numbering_right_aligned_it = block({
      it.body
      h(0.3em)
      counter(heading).display(it.numbering)
    })

    if it.level == 1 {
      set text(normal_text_size + 6pt)
      numbering_left_aligned_it
    } else if it.level == 2 {
      set text(normal_text_size + 3pt)
      let content = it.body.fields().values().first()
      if type(content) == str {
        if is_special_heading(content) {
          numbering_right_aligned_it
        } else {
          numbering_left_aligned_it
        }
      } else {
        if is_special_heading(content) {
          block({
            content.first().fields().values().first()
            h(0.3em)
            counter(heading).display(it.numbering)
            h(0.3em)
            content.slice(1).join()
          })
        } else {
          numbering_left_aligned_it
        }
      }
    } else if it.level == 3 {
      numbering_left_aligned_it
    } else if it.level == 4 {
      // set text(normal_text_size - 3pt)
      numbering_left_aligned_it
    } else {
      // set text(normal_text_size - 6pt)
      numbering_left_aligned_it
    }
  }

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
  // turns on ligature for inline code blocks
  show raw.where(block: false): set text(features: (calt: 1))

  // zebraw package style
  show: zebraw.with(inset: (top: 4pt, bottom: 4pt, left: 0pt, right: 0pt))

  body
}
