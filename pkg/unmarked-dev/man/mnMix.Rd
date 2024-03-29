\name{mnMix}
\alias{mnMix}
\title{Fit Multinomial-Multinomial Mixture Models}
\usage{mnMix(formula, data, constraint)}
\description{Fit latent abundance models to categorical data such as frog
calling data (Royle and Link 2005).  Currently, covariates can only be
supplied to the detection process (as in Royle and Link 2005).}
\details{See \link{unmarkedFrame} for detailed descriptions of passing data to the
\code{umf} argument.
See \link{unmarked} for a general description of the specifying covariates to the
stateformula and detformula arguments.

This function fits the model described in Royle and Link (2005).  This
function assumes that a site has a latent categorical state, taking on
values from 0 to K.  Thus, there are K + 1 multinomial states.  Here, we
estimate the probabilities \eqn{\mathbf{\psi}}{\bold{psi}}, of falling
into the K + 1 categories.

Further, the latent states are observed with error, and the detection
process also follows a multinomial distribution according to equation
(3) on page 2508 of Royle and Link (2005).  The user may specify
covariates of the \eqn{p}'s, which are modeled as in equation (4) on
p. 2509.

The \code{constraint} argument specifies which constraints are placed on
the multinomial detection parameters to reduce model complexity.  The
same constraint vector format is used as described on page 2508 of Royle
and Link (2005).  The default is to allow the \eqn{p_k}'s (\eqn{k = 1,
2, \ldots, K}{k = 1, 2, ..., K}) separate parameters, but constrain the
the \eqn{\beta}{beta}'s to be all equal.}
\value{still need to convert to UMfit}
\author{Ian Fiske \email{ianfiske@gmail.com}}
\references{Royle, J. Andrew, and William A. Link. 2005. A General Class of Multinomial Mixture Models for Anuran Calling Survey Data. Ecology 86, no. 9: 2505--2512.}
\keyword{models}
\arguments{
\item{formula}{double right-hand side formula for detection and abundance 
covariates, in that order.}
\item{data}{unmarkedFrame supplying data.}
\item{constraint}{vector to describe which detection parameters are
the same (see \emph{Details})}}
\examples{data(gf)
gfUMF <- unmarkedFrame(gf.data, obsCovs = gf.obs)
fm.mmx1 <- mnMix(~ samp1 + samp3 + temp ~ 1, con=c(1,2,2,3,3,3), gfUMF)
fm.mmx1}
