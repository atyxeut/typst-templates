#import "@preview/mannot:0.4.0": *
#import "@preview/shadowed:0.3.0": *
#import "@preview/zebraw:0.6.3": *

#let regular_text_font = "LXGW WenKai GB"
#let bold_text_font = "LXGW ZhenKai GB"
#let math_font = "XCharter Math"
#let code_font = "Maple Mono NL NF"

#let char_width = 4.8mm
#let char_width_over_2 = char_width / 2;
#let char_width_over_4 = char_width / 4;
#let char_width_over_8 = char_width / 8;
#let char_width_over_12 = char_width / 12;
#let char_width_over_16 = char_width / 16;

// font size
#let char_height = char_width / 1.2

#let space_over_2 = h(char_width_over_2, weak: true)
#let space_over_4 = h(char_width_over_4, weak: true)
#let space_over_8 = h(char_width_over_8, weak: true)
#let space_over_12 = h(char_width_over_12, weak: true)
#let space_over_16 = h(char_width_over_16, weak: true)

#let equation_no_spacing_flag = state("equation_no_spacing", false)
#let equation_no_left_spacing_flag = state("equation_no_left_spacing", false)
#let equation_no_right_spacing_flag = state("equation_no_right_spacing", false)

#let style(body) = {
  set heading(numbering: none)
  show heading: set text(weight: "bold", font: bold_text_font)
  show heading.where(level: 1): set text(size: char_height * 1.5)
  show heading.where(level: 2): set text(size: char_height * 1.3)
  show heading.where(level: 3): set text(size: char_height * 1.1)

  set text(
    cjk-latin-spacing: auto,
    spacing: char_width_over_4,
    size: char_height,
    font: regular_text_font,
    weight: "regular",
    hyphenate: true,
  )

  set par(
    justify: true,
    linebreaks: "simple",
  )

  let (margin_x, margin_y) = (10mm, 8mm)
  let page_width = 30 * char_width + margin_x * 2
  set page(width: page_width, height: auto, margin: (x: margin_x, y: margin_y))

  show math.equation: set text(weight: "regular", font: (math_font, regular_text_font))
  show math.equation: it => {
    show regex("[,:;]"): char => char + space_over_4
    it
  }

  // add default spacing around equations
  show math.equation.where(block: false): it => {
    if equation_no_spacing_flag.get() {
      return it
    }
    let last_char(expression) = {
      if expression.has("children") and expression.children.len() > 0 {
        last_char(expression.children.last())
      } else if expression.has("body") {
        last_char(expression.body)
      } else if expression.has("base") {
        last_char(expression.base)
      } else if expression.has("text") {
        if type(expression.text) == str {
          expression.text.clusters().last()
        } else {
          last_char(expression.text)
        }
      } else {
        repr(expression)
      }
    }
    let it = (
      if not equation_no_left_spacing_flag.get() { space_over_16 }
        + it
        + if not equation_no_right_spacing_flag.get()
          and (last_char(it.body) not in ("，", "：", "；", "、", "。", "？")) {
          space_over_16
        }
    )
    it
  }

  let code_font_size_factor = 0.75
  show raw: set text(
    font: code_font,
    size: char_height * code_font_size_factor,
    features: (calt: 0),
    spacing: char_width_over_2 * code_font_size_factor,
  )
  show raw.where(block: false): box.with(
    fill: luma(240),
    inset: (x: 4pt, y: 1pt),
    outset: (y: 3pt),
    radius: 1pt,
  )
  show: zebraw.with(inset: (top: 4pt, bottom: 4pt, left: 4pt, right: 4pt), indentation: 2, hanging-indent: true)

  body
}

#let begin_chapter(chapter) = {
  [
    #align(center)[
      #show heading: it => text(chapter, size: char_height * 1.7)
      #heading(chapter)
    ]
    #line(length: 100%, stroke: 0.75pt + black)
    #label(chapter)
  ]
}

#let begin_title(chapter, title) = { [= #title #label(chapter + "-" + title)] }

// must give a permanent `label_name`
#let content_block(text_color: white, background_color, label_name, title, en: auto, content) = {
  let cur_inset = 14pt
  [
    #v(1em)
    #shadow(radius: 2pt, dx: 1pt, dy: 1pt, blur: 2pt, fill: background_color.lighten(80%))[
      #block(
        fill: background_color.lighten(95%),
        stroke: 0.5pt + background_color.lighten(50%),
        radius: 2pt,
        width: 100%,
        inset: cur_inset,
        above: 2em,
      )[
        #place(
          top + left,
          dx: 10pt - cur_inset,
          dy: -10pt - cur_inset,
          rect(fill: background_color.lighten(20%), radius: 1pt, inset: 2.5pt, outset: 2pt)[
            #set text(fill: text_color)
            #title #space_over_12 #if en != auto { "(" + en + ")" }
          ],
        )
        #content
      ]
    ]
    #label(label_name)
  ]
}

// definition block
#let def_bg_color = rgb("#243daf")
#let def(label_name, title, en: auto, content) = content_block(
  def_bg_color,
  label_name,
  title,
  en: en,
  content,
)

// proposition block
#let prop_counter = counter("prop")
#let prop_bg_color = rgb("#d97706")
#let prop(label_name, content) = {
  prop_counter.step()
  context content_block(
    prop_bg_color,
    label_name,
    "命题" + prop_counter.display(),
    content,
  )
}

// theorem block
#let thm_bg_color = rgb("#be123c")
#let thm(label_name, title, en: auto, content) = content_block(
  thm_bg_color,
  label_name,
  title,
  en: en,
  content,
)

// corollary block
#let cor_bg_color = rgb("#7e22ce")
#let cor(label_name, title, en: auto, content) = content_block(
  cor_bg_color,
  label_name,
  title,
  en: en,
  content,
)

// algorithm block
#let algo_bg_color = rgb("#0e7490")
#let algo(label_name, title, en: auto, content) = content_block(
  algo_bg_color,
  label_name,
  title,
  en: en,
  content,
)

// proof block
#let proof_bg_color = black
#let proof(name: auto, content) = block(
  inset: (left: 0pt, right: 0pt, top: 0pt, bottom: 0pt),
  [
    #text("证明" + if name != auto { name }, fill: proof_bg_color, weight: "bold", font: bold_text_font) #h(
      char_width_over_2,
      weak: true,
    )
    #content
    #show math.equation: set text(font: "New Computer Modern Math")

    #h(1fr) #text(fill: proof_bg_color)[$qed$]
  ],
)

// example block
#let eg_counter = counter("eg")
#let eg_bg_color = rgb("#334155")
#let eg(label_name, source: auto, content) = {
  eg_counter.step()
  context content_block(
    eg_bg_color,
    label_name,
    "例" + eg_counter.display() + if source != auto { " (" + source + ")" },
    content,
  )
}

// a hyperlink to a label with description
#let tp(label_name, ..desc) = {
  set text(weight: "medium")
  let target = label(label_name)

  let content = if desc.pos().len() == 0 {
    if label_name.starts-with("prop-") {
      context underline("命题" + str(prop_counter.at(query(target).first().location()).first()))
    } else if label_name.starts-with("eg-") {
      context underline("例" + str(eg_counter.at(query(target).first().location()).first()))
    }
  } else {
    text[#show math.equation.where(block: false): it => {
        let left_flag = equation_no_left_spacing_flag.get()
        let right_flag = equation_no_right_spacing_flag.get()
        box(
          it,
          stroke: (bottom: 0.2mm + black),
          outset: (bottom: 0.7mm),
          inset: (
            left: if not left_flag { char_width_over_16 } else { 0mm },
            right: if not right_flag { char_width_over_16 } else { 0mm },
          ),
        )
      }
      #underline(desc.pos().first())]
  }
  link(target, content)
}

// a hyperlink to a label with given description
#let tpd(label_name, desc) = {
  set text(weight: "medium")
  let target = label(label_name)

  link(target, text[#show math.equation.where(block: false): it => {
      let left_flag = equation_no_left_spacing_flag.get()
      let right_flag = equation_no_right_spacing_flag.get()
      box(
        it,
        stroke: (bottom: 0.2mm + black),
        outset: (bottom: 0.7mm),
        inset: (
          left: if not left_flag { char_width_over_16 } else { 0mm },
          right: if not right_flag { char_width_over_16 } else { 0mm },
        ),
      )
    }
    #underline(desc)])
}

#let keyword(content, en: auto) = {
  set text(weight: "medium")
  text(content)
  space_over_12
  text(if en != auto { "(" + en + ")" })
}

// remove default spacing before/after an equation
#let nseq(equation, keep: none) = {
  if keep == none {
    equation_no_spacing_flag.update(true)
  } else if keep == "left" {
    equation_no_right_spacing_flag.update(true)
  } else if keep == "right" {
    equation_no_left_spacing_flag.update(true)
  }
  equation
  if keep == none {
    equation_no_spacing_flag.update(false)
  } else if keep == "left" {
    equation_no_right_spacing_flag.update(false)
  } else if keep == "right" {
    equation_no_left_spacing_flag.update(false)
  }
}

// numbered block equation
#let eqn(content) = {
  math.equation(block: true, numbering: "(1)", content)
}

#let eqrect(content) = markrect(outset: char_width_over_8, content);

#let rfact(x, n) = $#x^overline(#n)$
#let ffact(x, n) = $#x^underline(#n)$

#let stirling1(n, k) = $vec(#n, #k, delim: "[")$
#let stirling2(n, k) = $vec(#n, #k, delim: "{")$
#let eulerian(n, k) = $vec(#n, #k, delim: chevron)$
#let multinom(n, ..k) = $binom(#n, #k.pos().join("," + space_over_4))$
