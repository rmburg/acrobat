// Acrobat, a typst package to handle acronyms

// features not in Acrostiche:
// - long and short variants
// features not in Acrostiche or Acrotastic:
// - backlinks
// - capitalized variants
// - clean source code
// - issues enabled on GitHub

// TODO:
// - show list of acronyms
//   - with backlinks
// - support italic definitions
//   - allow setting arbitrary styles, like a show rule?
// - Add messages to all panic() and assert() calls

#let normalize-definition(definition) = {
  if type(definition) == str {
    (singular: definition, plural: definition)
  } else if type(definition) == array and definition.len() == 2 {
    let (singular, plural) = definition
    if plural == auto {
      (singular: singular, plural: singular + "s")
    } else {
      (singular: singular, plural: plural)
    }
  } else {
    panic("Acronym definitions must either be a string or an array with two elements")
  }
}

#let init-acronyms(definitions) = {
  assert(type(definitions) == dictionary)

  let normalized-definitions = for (acronym, definition) in definitions {
    assert(type(acronym) == str)

    ((acronym): normalize-definition(definition))
  }

  state("acrobat-definitions").update(normalized-definitions)
}

#let format-definition-short(acronym, plural: false) = {
  if plural {
    acronym + "s"
  } else {
    acronym
  }
}

#let format-definition-long(definition, plural: false) = {
  if plural {
    definition.plural
  } else {
    definition.singular
  }
}

#let format-definition-full(acronym, definition, plural: false) = {
  format-definition-long(definition, plural: plural) + " ("
  format-definition-short(acronym, plural: plural) + ")"
}

#let acr(acronym, plural: false, capitalize: false, form: auto, mark-used: true) = context {
  assert(type(acronym) == str)
  assert(type(plural) == bool)
  assert(type(capitalize) == bool)
  assert(type(mark-used) == bool)
  assert(form == auto or form == "short" or form == "long" or form == "full")

  let definitions = state("acrobat-definitions").get()
  if definitions == none {
    panic()
  }
  if acronym not in definitions {
    panic()
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
    format-definition-short(acronym, plural: plural)
  } else if form == "long" {
    format-definition-long(definition, plural: plural)
  } else if form == "full" {
    format-definition-full(acronym, definition, plural: plural)
  }

  show regex("^\w"): if capitalize { it => upper(it) } else { it => it }

  [#definition-str #label("acrobat-backlink-target-" + acronym)]
  
  if mark-used {
    state(used-state-key).update(true)
  }
}

#let acrpl(..args) = acr(..args, plural: true)
#let acrfull(..args) = acr(..args, mark-used: false, form: "full")
#let acrfullpl(..args) = acr(..args, mark-used: false, form: "full", plural: true)
#let acrlong(..args) = acr(..args, mark-used: false, form: "long")
#let acrlongpl(..args) = acr(..args, mark-used: false, form: "long", plural: true)
#let acrshort(..args) = acr(..args, mark-used: false, form: "short")
#let acrshortpl(..args) = acr(..args, mark-used: false, form: "short", plural: true)
#let Acr(..args) = acr(..args, capitalize: true)
#let Acrpl(..args) = acr(..args, capitalize: true, plural: true)
#let Acrfull(..args) = acr(..args, mark-used: false, capitalize: true, form: "full")
#let Acrfullpl(..args) = acr(..args, mark-used: false, capitalize: true, form: "full", plural: true)
#let Acrlong(..args) = acr(..args, mark-used: false, capitalize: true, form: "long")
#let Acrlongpl(..args) = acr(..args, mark-used: false, capitalize: true, form: "long", plural: true)

#let reset-acronym(acronym) = context {
  state("acrobat-used-" + acronym).update(false)
}

#let reset-all-acronyms() = context {
  let definitions = state("acrobat-definitions", (:)).get()

  for key in definitions.keys() {
    reset-acronym(key)
  }
}
