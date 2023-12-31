% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/tags_filter.R
\name{tags_filter}
\alias{tags_filter}
\title{Filter objects matching specified keys/tags}
\usage{
tags_filter(
  input_path,
  filters,
  output_path,
  invert_match = FALSE,
  omit_referenced = FALSE,
  remove_tags = FALSE,
  overwrite = FALSE,
  echo_cmd = FALSE,
  echo = TRUE,
  spinner = TRUE,
  verbose = FALSE,
  progress = FALSE
)
}
\arguments{
\item{input_path}{A string. The path to the OSM data/history file to which
the filters should be applied. Please see \link{file_formats} for a list of
supported file formats.}

\item{filters}{A string. The filter expressions that should be applied to the
input file. Please see the "Filter expressions" section for a description
of the filter expression format.}

\item{output_path}{A string. The path to the file where the output should be
written to. Please see \link{file_formats} for a list of supported file formats.}

\item{invert_match}{A logical. Whether to invert the sense of matching - i.e.
to exclude objects with matching tags. Defaults to \code{FALSE}.}

\item{omit_referenced}{A logical. Whether to omit the nodes referenced from
matching ways and members referenced from matching relations. Defaults to
\code{FALSE}.}

\item{remove_tags}{A logical. Whether to remove tags from objects that are
not matching the filter expression but are included to complete references
(nodes in ways and members of relations). Defaults to \code{FALSE}. Please note
that if an object is both matching the filter and used as a reference it
will keep its tags.}

\item{overwrite}{A logical. Whether existing files should be overwritten by
the output. Defaults to \code{FALSE}.}

\item{echo_cmd}{A logical. Whether to print the Osmium command generated by
the function call to the screen. Defaults to \code{FALSE}.}

\item{echo}{A logical. Whether to print the standard output and error
generated by the Osmium call to the screen. Defaults to \code{TRUE}.}

\item{spinner}{A logical. Whether to show a reassuring spinner while the
Osmium call is being executed. Defaults to \code{TRUE}.}

\item{verbose}{A logical. Whether to display detailed information on the
running command. Defaults to \code{FALSE}.}

\item{progress}{A logical. Whether to display a progress bar while running
the command. Defaults to \code{FALSE}.}
}
\value{
The normalized path to the output file.
}
\description{
Get objects matching at least one of the specified expressions from the input
and write them to the output. All objects matching the expressions will be
kept in the output, and objects referenced by them will also be added to the
output (unless \code{omit_referenced = TRUE}). Objects will be written out in the
order they are found in the input. Please note that the function will only
work correctly on history files if \code{omit_referenced} is \code{TRUE}, and it cannot
be used on change files.
}
\section{Filter expressions}{

A filter expression specifies a tag or tags that should be found in the data
and the type of object (node, way or relation) that should be matched.

The object type(s) comes first, then a slash (/) and then the rest of the
expression. Object types are specified as 'n' (for nodes), 'w' (for ways),
'r' (for relations) and 'a' (for areas - closed ways with 4 or more nodes and
relations with \code{type=multipolygon} or \code{type=boundary} tag). Any combination
of them can be used. If the object type is not specified, the expression
matches all object types.

Some examples:
\itemize{
\item \code{n/amenity} - matches all nodes with the key "amenity".
\item \code{nw/highway} - matches all nodes or ways with the key "highway".
\item \verb{/note} - matches objects of any type with the key "note".
\item \code{note} - matches objects of any type with the key "note".
\item \code{w/highway=primary} - matches all ways with the key "highway" and value
"primary".
\item \code{w/highway!=primary} - matches all ways with the key "highway" and a value
other than "primary".
\item \verb{r/type=multipolygon,boundary} - matches all relations with key "type" and
value "multipolygon" or "boundary".
\item \verb{w/name,name:de=Kastanienallee,Kastanienstrasse} - matches any way with a
"name" or "name:de" tag with the value "Kastanienallee" or
"Kastanienstrasse".
\item \verb{n/addr:*} - matches all nodes with any key starting with "addr:"
\item \verb{n/name=*Paris} - matches all nodes with a name that contains the word
"Paris".
\item \code{a/building} - matches any closed ways with 4 or more nodes or relations
tagged "building". Relations must also have a tag "type=multipolygon" or
"type=boundary".
}

If there is no equal sign ("=") in the expression, only keys are matched and
values can be anything. If there is an equal sign ("=") in the expression,
the key is to the left and the value to the right. An exclamation sign ("!")
before the equal sign means: a tag with that key, but not the value(s) to the
right of the equal sign. A leading or trailing asterisk ("*") can be used for
substring or prefix matching, respectively. Commas (",") can be used to
separate several keys or values.

All filter expressions are case-sensitive. There is no way to escape the
special characters such as "=", "\emph{" and ",". You can not mix
comma-expressions and "}"-expressions.

The specified filter expressions are matched in the order they are given. To
achieve best performance, put expressions expected to match more often first.

Area matches (with leading "a/") do not check whether the matched object is a
valid (multi)polygon, they only check whether an object might possibly be
turned into a (multi)polygon. This is the case for all closed ways (where the
first and last node are the same) with 4 or more nodes and for all relations
that have an additional "type=multipolygon" or "type=boundary" tag.
}

\examples{
\dontshow{if (identical(tolower(Sys.getenv("NOT_CRAN")), "true")) (if (getRversion() >= "3.4") withAutoprint else force)(\{ # examplesIf}
pbf_path <- system.file("extdata/cur.osm.pbf", package = "rosmium")

# get all amenity nodes
output <- tags_filter(pbf_path, "n/amenity", tempfile(fileext = ".osm.pbf"))
nodes <- sf::st_read(output, layer = "points", quiet = TRUE)
head(nodes$other_tags)

# get all objects (nodes, ways or relations) with an addr:* tag
output <- tags_filter(
  pbf_path,
  "addr:*",
  tempfile(fileext = ".osm.pbf"),
  omit_referenced = TRUE
)
nodes <- sf::st_read(output, layer = "points", quiet = TRUE)
head(nodes$other_tags)

# get all nodes and ways with a highway tag and all relations tagged with
# type=restriction plus all referenced objects
output <- tags_filter(
  pbf_path,
  "nw/highway r/type=restriction",
  tempfile(fileext = ".osm.pbf")
)
ways <- sf::st_read(output, layer = "lines", quiet = TRUE)
head(ways$highway)
relations <- sf::st_read(output, layer = "other_relations", quiet = TRUE)
head(relations$other_tags)
\dontshow{\}) # examplesIf}
}
