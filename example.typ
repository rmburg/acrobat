#import "acrobat.typ"
#import acrobat: *

#init-acronyms((
  "ABC": "a b c",
  // Custom plural
  "DEF": ("d e f", "ds e f"),
  // Custom short form, useful for nonstandard formatting
  "GHI": (
    short: [_GHI_],
    long: "g h i",
  ),
  // Custom short form and plural
  "JKL": (
    short: [_JKL_],
    long: ("j k l", "js k l")
  ),
  // Generate the plural automatically by appending an "s" to the singular
  // Equivalent to `"MNO": "m n o"`
  "MNO": ("m n o", auto),
  // No plural, will output the singular instead
  "PQR": ("p q r", none),
))

#let functions = dictionary(acrobat).pairs().filter(((name, fun)) => lower(name).starts-with("acr"))
#let test-acronym = "GHI"

#table(
  columns: 3,
  rows: 15,
  [function],[output(first)],[output(not first)],
  ..functions.map(((name, function)) => {
    (
      raw(name),
      [#reset-acronym(test-acronym)#function(test-acronym)],
      [#function(test-acronym)]
    )
  }).flatten(),
)
