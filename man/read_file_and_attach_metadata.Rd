% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/utils.R
\name{read_file_and_attach_metadata}
\alias{read_file_and_attach_metadata}
\title{Read a data file and attach metadata}
\usage{
read_file_and_attach_metadata(path)
}
\arguments{
\item{path}{[character(1)] Path to the data file to read}
}
\value{
A data frame with metadata attached as an attribute named "meta".
}
\description{
Reads an .rds or .sas7bdat file from the given path and attaches metadata about the file
as an attribute.
}
\keyword{internal}
