\name{unmarkedFit-class}
\Rdversion{1.1}
\docType{class}
\alias{unmarkedFit}
\alias{unmarkedFit-class}
\alias{getData}
\alias{getData,unmarkedFit-method}
\alias{hessian}
\alias{hessian,unmarkedFit-method}
\alias{hist,unmarkedFitDS-method}
\alias{mle}
\alias{mle,unmarkedFit-method}
\alias{names,unmarkedFit-method}
\alias{nllFun}
\alias{nllFun,unmarkedFit-method}
\alias{parboot,unmarkedFit-method}
\alias{plot,unmarkedFit,missing-method}
\alias{predict,unmarkedFit-method}
\alias{profile,unmarkedFit-method}
\alias{residuals,unmarkedFit-method}
\alias{residuals,unmarkedFitOccu-method}
\alias{residuals,unmarkedFitOccuRN-method}
\alias{update,unmarkedFit-method}
\alias{sampleSize}
\alias{sampleSize,unmarkedFit-method}
\alias{unmarkedFitOccu-class}
\alias{unmarkedFitPCount-class}
\alias{unmarkedFitDS-class}
\alias{unmarkedFitMPois-class}
\alias{plot,profile,missing-method}
\alias{show,unmarkedFit-method}
\alias{summary,unmarkedFit-method}
\alias{summary,unmarkedFitDS-method}

\title{Class "unmarkedFit" }
\description{Contains fitted model information which can be manipulated or 
extracted using the methods described below.
}
\section{Slots}{
	\describe{
    \item{\code{fitType}:}{Object of class \code{"character"} }
    \item{\code{call}:}{Object of class \code{"call"} }
    \item{\code{formula}:}{Object of class \code{"formula"} }
    \item{\code{data}:}{Object of class \code{"unmarkedFrame"} }
    \item{\code{sitesRemoved}:}{Object of class \code{"numeric"} }
    \item{\code{estimates}:}{Object of class \code{"unmarkedEstimateList"} }
    \item{\code{AIC}:}{Object of class \code{"numeric"} }
    \item{\code{opt}:}{Object of class \code{"list"} containing results from 
		\code{\link{optim}} }
    \item{\code{negLogLike}:}{Object of class \code{"numeric"} }
    \item{\code{nllFun}:}{Object of class \code{"function"} }
    \item{\code{knownOcc}:}{unmarkedFitOccu only: sites known to be occupied}
    \item{\code{K}:}{unmarkedFitPCount only: upper bound used in integration}
    \item{\code{mixture}:}{unmarkedFitPCount only: Mixing distribution}
    \item{\code{keyfun}:}{unmarkedFitDS only: detection function used by 
		\link{distsamp}}
	\item{\code{unitsOut}:}{unmarkedFitDS only: density units}	 
  }
}
\section{Methods}{
  \describe{
    \item{[}{\code{signature(x = "unmarkedFit", i = "ANY", j = "ANY", 
		drop = "ANY")}: extract either 'det' or 'state' coefficient information }
    \item{backTransform}{\code{signature(obj = "unmarkedFit")}: back-transform
		parameters to original scale when no covariate effects are modeled }
    \item{coef}{\code{signature(object = "unmarkedFit")}: returns parameter 
		estimates. type can be 'state' or 'det'. If altNames=T estimate names 
		are more specific. }
    \item{confint}{\code{signature(object = "unmarkedFit")}: Returns confidence
		intervals. Must specify type and method (either "normal" or "profile") }
    \item{fitted}{\code{signature(object = "unmarkedFit")}: returns expected
		values of Y }
    \item{getData}{\code{signature(object = "unmarkedFit")}: extracts data }
    \item{getP}{\code{signature(object = "unmarkedFit")}: calculates and extracts 
		expected detection probabilities }
    \item{hessian}{\code{signature(object = "unmarkedFit")}: Returns hessian 
		matrix }
    \item{linearComb}{\code{signature(obj = "unmarkedFit", 
		coefficients = "matrixOrVector")}: Returns estimate and SE on original 
		scale when covariates are present }
    \item{mle}{\code{signature(object = "unmarkedFit")}: Same as coef(fit)? }
    \item{names}{\code{signature(x = "unmarkedFit")}: Names of parameter levels }
    \item{nllFun}{\code{signature(object = "unmarkedFit")}: returns negative 
		log-likelihood used to estimate parameters }
    \item{parboot}{\code{signature(object = "unmarkedFit")}: Parametric 
		bootstrapping method to assess goodness-of-fit }
    \item{plot}{\code{signature(x = "unmarkedFit", y = "missing")}: Plots 
		expected vs. observed values }
    \item{predict}{\code{signature(object = "unmarkedFit")}: Returns predictions 
		and standard errors for original data or for covariates in a new 
		data.frame }
    \item{profile}{\code{signature(fitted = "unmarkedFit")}: used by confint 
		method='profile' }
    \item{residuals}{\code{signature(object = "unmarkedFit")}: returns residuals }
    \item{sampleSize}{\code{signature(object = "unmarkedFit")}: returns number 
		of sites in sample }
    \item{SE}{\code{signature(obj = "unmarkedFit")}: returns standard errors }
    \item{show}{\code{signature(object = "unmarkedFit")}: concise results }
    \item{summary}{\code{signature(object = "unmarkedFit")}: results with more 
		details }
    \item{update}{\code{signature(object = "unmarkedFit")}: refit model with 
		changes to one or more arguments }
    \item{vcov}{\code{signature(object = "unmarkedFit")}: returns 
		variance-covariance matrix }
	 }
}
\note{ This is a superclass with child classes for each fit type }
\examples{
showClass("unmarkedFit")

# Format removal data for multinomPois 
data(ovendata)
ovenFrame <- unmarkedFrameMPois(y = ovendata.list$data,
	siteCovs = as.data.frame(scale(ovendata.list$covariates[,-1])), 
	type = "removal")

# Fit a model
(fm1 <- multinomPois(~ 1 ~ ufp + trba, ovenFrame))

# Apply a bunch of methods to the fitted model

names(fm1)
fm1['state']
fm1['det']

backTransform(fm1, whichEstimate ='det')

coef(fm1, type='state')

confint(fm1, type='state', method='profile')

fitted(fm1)

getData(fm1)

getP(fm1)

# Return predicted abundance at specified covariate values
linearComb(fm1, c(Int = 1, ufp = 0, trba = 0), type='state')

# Assess goodness-of-fit
parboot(fm1)

plot(fm1)

# Predict abundance at specified covariate values.
newdat <- data.frame(ufp = 0, trba = seq(-1, 1, length=10))

predict(fm1, type='state', newdata=newdat)

sampleSize(fm1)

summary(fm1)

(fmNull <- update(fm1, formula = ~1 ~1))

vcov(fm1, type='state')


}
\keyword{classes}
