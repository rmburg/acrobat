// Acrobat, a typst package to handle acronyms

// features not in Acrostiche:
// - long and short variants
// features not in Acrostiche or Acrotastic:
// - backlinks
// - capitalized variants
// - italic variants
// - clean source code
// - issues enabled on GitHub
// - custom short form
// - content instead of str

// TODO:
// - show list of acronyms
//   - with backlinks
// - Add messages to all panic() and assert() calls
// - rename acr -> ac?
// - add "mark as used" function
// - setup/config function
//   - "show rules"
//     - first long

#let normalize-definition(acronym, definition) = {
  if type(definition) == str or type(definition) == content {
    (short: acronym, long: (singular: definition, plural: auto))
  } else if type(definition) == array and definition.len() == 2 {
    let (singular, plural) = definition
    (short: acronym, long: (singular: singular, plural: plural))
  } else if type(definition) == dictionary {
    let keys = definition.keys()

    for key in keys {
      assert(key in ("short", "long"))
    }
    assert("long" in keys, message: "Dictionary-style acronym definitions must contain a `long` key")

    let long = definition.long
    let (singular, plural) = if type(long) == str or type(long) == content {
      (long, auto)
    } else if type(long) == array and long.len() == 2 {
      let (singular, plural) = long
      (singular, plural)
    } else {
      panic("Acronym definitions must either be of type str, content, or an array with two elements. Found " + repr(definition))
    }

    (
      short: definition.at("short", default: acronym),
      long: (singular: singular, plural: plural)
    )
  } else {
    panic("Acronym definitions must either be of type str, content, dictionary, or an array with two elements. Found " + repr(definition))
  }
}

#let init-acronyms(definitions) = {
  assert(type(definitions) == dictionary)

  let normalized-definitions = for (acronym, definition) in definitions {
    assert(type(acronym) == str)

    ((acronym): normalize-definition(acronym, definition))
  }

  state("acrobat-definitions").update(normalized-definitions)
}

#let maybe(op, enable, it) = {
  if enable { op(it) } else { it }
}

#let append-s(it) = it + "\u{2060}s"

#let format-definition-short(definition, plural: false) = {
  show regex(".+"): maybe.with(append-s, plural)

  definition.short
}

#let format-definition-long(definition, plural: false, italic: false, capitalize: false) = {
  show regex("^\w"): maybe.with(upper, capitalize)
  show: maybe.with(emph, italic)

  if not plural or definition.long.plural == none {
    definition.long.singular
  } else if definition.long.plural == auto {
    show regex(".+"): append-s
    definition.long.singular
  } else {
    definition.long.plural
  }
}

#let format-definition-full(definition, plural: false, italic: false, capitalize: false) = [
  #format-definition-long(definition, plural: plural, italic: italic, capitalize: capitalize)
  (#format-definition-short(definition, plural: plural))
]

#let acr(acronym, plural: false, capitalize: false, italic: false, form: auto, mark-used: true) = context {
  assert(type(acronym) == str)
  assert(type(plural) == bool)
  assert(type(capitalize) == bool)
  assert(type(italic) == bool)
  assert(type(mark-used) == bool)
  assert(form == auto or form == "short" or form == "long" or form == "full")

  let definitions = state("acrobat-definitions").get()
  if definitions == none {
    panic("Acronyms have not yet been defined. Call `init-acronyms` first")
  }
  if acronym not in definitions {
    panic("Acronym \"" + acronym + "\" has not been defined")
  }
  let definition = definitions.at(acronym)

  let used-state-key = "acrobat-used-" + acronym
  let used = state(used-state-key, false).get()

  let form = if form == auto {
    if used {
      "short"
    } else {
      "full"
    }
  } else {
    form
  }
  
  let definition-str = if form == "short" {
    format-definition-short(definition, plural: plural)
  } else if form == "long" {
    format-definition-long(definition, plural: plural, italic: italic, capitalize: capitalize)
  } else if form == "full" {
    format-definition-full(definition, plural: plural, italic: italic, capitalize: capitalize)
  }

  [#definition-str #label("acrobat-backlink-target-" + acronym)]
  
  if mark-used {
    state(used-state-key).update(true)
  }
}

#let acrpl = acr.with(plural: true)
#let acrfull = acr.with(mark-used: false, form: "full")
#let acrfullit = acr.with(mark-used: false, form: "full", italic: true)
#let acrfullpl = acr.with(mark-used: false, form: "full", plural: true)
#let acrfullplit = acr.with(mark-used: false, form: "full", plural: true, italic: true)
#let acrlong = acr.with(mark-used: false, form: "long")
#let acrlongit = acr.with(mark-used: false, italic: true)
#let acrlongpl = acr.with(mark-used: false, form: "long", plural: true)
#let acrlongplit = acr.with(mark-used: false, form: "long", plural: true, italic: true)
#let acrshort = acr.with(mark-used: false, form: "short")
#let acrshortpl = acr.with(mark-used: false, form: "short", plural: true)
#let Acr = acr.with(capitalize: true)
#let Acrpl = acr.with(capitalize: true, plural: true)
#let Acrfull = acr.with(mark-used: false, capitalize: true, form: "full")
#let Acrfullit = acr.with(mark-used: false, capitalize: true, form: "full", italic: true)
#let Acrfullpl = acr.with(mark-used: false, capitalize: true, form: "full", plural: true)
#let Acrfullplit = acr.with(mark-used: false, capitalize: true, form: "full", plural: true, italic: true)
#let Acrlong = acr.with(mark-used: false, capitalize: true, form: "long")
#let Acrlongit = acr.with(mark-used: false, capitalize: true, form: "long", italic: true)
#let Acrlongpl = acr.with(mark-used: false, capitalize: true, form: "long", plural: true)
#let Acrlongplit = acr.with(mark-used: false, capitalize: true, form: "long", plural: true, italic: true)

#let reset-acronym(acronym) = context {
  state("acrobat-used-" + acronym).update(false)
}

#let reset-all-acronyms() = context {
  let definitions = state("acrobat-definitions", (:)).get()

  for key in definitions.keys() {
    reset-acronym(key)
  }
}
