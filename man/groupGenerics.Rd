% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/groupGenerics.R
\name{groupGenerics}
\alias{groupGenerics}
\alias{Math.soma_adat}
\alias{antilog}
\alias{Ops.soma_adat}
\alias{==.soma_adat}
\alias{Summary.soma_adat}
\title{Group Generics for \code{soma_adat} Class Objects}
\usage{
\method{Math}{soma_adat}(x, ...)

antilog(x, base = 10)

\method{Ops}{soma_adat}(e1, e2 = NULL)

\method{==}{soma_adat}(e1, e2)

\method{Summary}{soma_adat}(..., na.rm = FALSE)
}
\arguments{
\item{x}{The \code{soma_adat} class object to perform the transformation.}

\item{...}{Additional arguments passed to the various group generics
as appropriate.}

\item{base}{A positive or complex number: the base with respect to
which logarithms are computed.}

\item{e1}{objects.}

\item{e2}{objects.}

\item{na.rm}{logical: should missing values be removed?}
}
\value{
A \code{soma_adat} object with the same dimensions of the input
object with the feature columns transformed by the specified generic.
}
\description{
S3 group generic methods to apply group specific prototype functions
to the RFU data \strong{only} of \code{soma_adat} objects.
The clinical meta data are \emph{not} transformed and remain unmodified in
the returned object (\code{\link[=Math]{Math()}} and \code{\link[=Ops]{Ops()}}) or are ignored for the
\code{\link[=Summary]{Summary()}} group. See \code{\link[=groupGeneric]{groupGeneric()}}.
}
\section{Functions}{
\itemize{
\item \code{antilog}: Performs the inverse or anti-log transform for a numeric vector of
\code{soma_adat} object. \strong{note:} default is \code{base = 10}, which differs from
the \code{\link[=log]{log()}} default base \emph{e}.

\item \code{Ops.soma_adat}: Performs binary mathematical operations on class \code{soma_adat}. See \code{\link[=Ops]{Ops()}}.

\item \code{==.soma_adat}: Compares left- and right-hand sides of the operator \emph{unless} the RHS
is also a \code{soma_adat}, in which case \code{\link[=diffAdats]{diffAdats()}} is invoked.

\item \code{Summary.soma_adat}: Performs summary calculations on class \code{soma_adat}. See \code{\link[=Summary]{Summary()}}.
}}

\section{Math}{

Group members:\preformatted{##  [1] "abs"      "acos"     "acosh"    "asin"     "asinh"    "atan"    
##  [7] "atanh"    "ceiling"  "cos"      "cosh"     "cospi"    "cummax"  
## [13] "cummin"   "cumprod"  "cumsum"   "digamma"  "exp"      "expm1"   
## [19] "floor"    "gamma"    "lgamma"   "log"      "log10"    "log1p"   
## [25] "log2"     "sign"     "sin"      "sinh"     "sinpi"    "sqrt"    
## [31] "tan"      "tanh"     "tanpi"    "trigamma" "trunc"
}

Commonly used generics of this group include:
\itemize{
\item \code{log()}, \code{log10()}, \code{log2()}, \code{antilog()},
\code{abs()}, \code{sign()}, \code{floor()}, \code{sqrt()}, \code{exp()}
}
}

\section{Ops}{

Group members:\preformatted{##  [1] "+"   "-"   "*"   "^"   "\%\%"  "\%/\%" "/"   "=="  ">"   "<"   "!="  "<=" 
## [13] ">="
}

Note that for the \verb{`==`} method if the RHS is also a \code{soma_adat},
\code{\link[=diffAdats]{diffAdats()}} is invoked which compares LHS vs. RHS.
Commonly used generics of this group include:
\itemize{
\item \code{+}, \code{-}, \code{*}, \code{/}, \code{^}, \code{==}, \code{>}, \code{<}
}
}

\section{Summary}{

Group members:\preformatted{## [1] "all"   "any"   "max"   "min"   "prod"  "range" "sum"
}

Commonly used generics of this group include:
\itemize{
\item \code{max()}, \code{min()}, \code{range()}, \code{sum()}, \code{any()}
}
}

\examples{
example_data$seq.3343.1

# Math Generics:
# -------------
# log-transformation
a <- log(example_data)
a$seq.3343.1

b <- log10(example_data)
b$seq.3343.1
isTRUE(all.equal(b, log(example_data, base = 10)))

# floor
c <- floor(example_data)
c$seq.3343.1

# square-root
d <- sqrt(example_data)
d$seq.3343.1

# rounding
e <- round(example_data)
e$seq.3343.1

# inverse log
antilog(1:4)

alog <- antilog(b)
all.equal(example_data, alog)    # return `b` -> linear space

# Ops Generics:
# -------------
plus1 <- example_data + 1
times2 <- example_data * 2

sq <- example_data^2
all.equal(sqrt(sq), example_data)

gt100k <- example_data > 100000
gt100k

example_data == example_data   # invokes diffAdats()

# Summary Generics:
# -------------
sum(example_data)

any(example_data < 100)  # low RFU analytes

sum(example_data < 100)  # how many

min(example_data)

min(example_data, 0)

max(example_data)

max(example_data, 1e+7)

range(example_data)
}
\seealso{
\code{\link[=groupGeneric]{groupGeneric()}}, \code{\link[=getGroupMembers]{getGroupMembers()}}, \code{\link[=getGroup]{getGroup()}}
}
\author{
Stu Field
}
