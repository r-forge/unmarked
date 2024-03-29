\name{unmarkedFrame-class}
\Rdversion{1.1}
\docType{class}
\alias{unmarkedFrame-class}
\alias{coordinates,unmarkedFrame-method}
\alias{coordinates}
\alias{coords}
\alias{getY}
\alias{getY,unmarkedFrame-method}
\alias{head,unmarkedFrame-method}
\alias{hist,unmarkedFrameDS-method}
\alias{mapInfo}
\alias{numSites}
\alias{numSites,unmarkedFrame-method}
\alias{numY}
\alias{numY,unmarkedFrame-method}
\alias{obsCovs,unmarkedFrame-method}
\alias{obsCovs<-,unmarkedFrame-method}
\alias{obsCovs}
\alias{obsCovs<-}
\alias{obsNum,unmarkedFrame-method}
\alias{obsNum}
\alias{obsToY,unmarkedFrame-method}
\alias{obsToY<-,unmarkedFrame-method}
\alias{obsToY}
\alias{obsToY<-}
\alias{plot,unmarkedFrame,missing-method}
\alias{powerAnalysis}
\alias{powerAnalysis,formula,unmarkedFramePCount,numeric-method}
\alias{projection,unmarkedFrame-method}
\alias{projection}
\alias{siteCovs,unmarkedFrame-method}
\alias{siteCovs<-,unmarkedFrame-method}
\alias{siteCovs}
\alias{siteCovs<-}
\alias{unmarkedFrameOccu-class}
\alias{unmarkedFrameMPois-class}
\alias{unmarkedFramePCount-class}
\alias{unmarkedFrameDS-class}
\alias{unmarkedMultFrame-class}

\title{Class "unmarkedFrame" }
\description{Methods for manipulating, summarizing and viewing unmarkedFrames}
\section{Objects from the Class}{
Objects can be created by calls to the constructor function 
	\code{\link{unmarkedFrame}}. These objects are passed to the data argument 
	of the fitting functions.
}
\section{Slots}{
	 \describe{
    \item{\code{y}:}{Object of class \code{"matrix"}}
    \item{\code{obsCovs}:}{Object of class \code{"optionalDataFrame"}}
    \item{\code{siteCovs}:}{Object of class \code{"optionalDataFrame"}}
    \item{\code{mapInfo}:}{Object of class \code{"optionalMapInfo"}}
    \item{\code{plotArea}:}{Object of class \code{"numeric"}}
    \item{\code{obsToY}:}{Object of class \code{"optionalMatrix"}}
  }
}
\section{Methods}{
  \describe{
    \item{[}{\code{signature(x = "unmarkedFrame", i = "numeric", j = "missing",
	 	drop = "missing")}: ... }
    \item{[}{\code{signature(x = "unmarkedFrame", i = "numeric", j = "numeric", 
		drop = "missing")}: ... }
    \item{[}{\code{signature(x = "unmarkedFrame", i = "missing", j = "numeric", 
		drop = "missing")}: ... }
    \item{coordinates}{\code{signature(object = "unmarkedFrame")}: extract 
		coordinates }
    \item{getY}{\code{signature(object = "unmarkedFrame")}: extract y matrix }
    \item{numSites}{\code{signature(object = "unmarkedFrame")}: extract M }
    \item{numY}{\code{signature(object = "unmarkedFrame")}: extract ncol(y) }
    \item{obsCovs}{\code{signature(object = "unmarkedFrame")}: extract 
		observation-level covariates }
    \item{obsCovs<-}{\code{signature(object = "unmarkedFrame")}: add or modify 
		observation-level covariates }
    \item{obsNum}{\code{signature(object = "unmarkedFrame")}: extract number of 
		observations }
    \item{obsToY}{\code{signature(object = "unmarkedFrame")}:  }
    \item{obsToY<-}{\code{signature(object = "unmarkedFrame")}: ... }
    \item{plot}{\code{signature(x = "unmarkedFrame", y = "missing")}: visualize 
      response variable.

    Takes additional argument \code{panels} which specifies how many
    panels data should be split over.}
    \item{projection}{\code{signature(object = "unmarkedFrame")}: extract 
		projection information }
    \item{show}{\code{signature(object = "unmarkedFrame")}: view data as 
		data.frame }
    \item{siteCovs}{\code{signature(object = "unmarkedFrame")}: extract 
		site-level covariates }
    \item{siteCovs<-}{\code{signature(object = "unmarkedFrame")}: add or modify 
		site-level covariates }
    \item{summary}{\code{signature(object = "unmarkedFrame")}: summarize data }
	 }
}
\note{ This is a superclass with child classes for each fitting function }

\seealso{\code{\link{unmarkedFrame}}, \code{\linkS4class{unmarkedFit}}, 
	\code{\link{unmarked-package}}
}
\examples{

# Organize data for pcount()
data(mallard)
mallardUMF <- unmarkedFramePCount(mallard.y, siteCovs = mallard.site,
	obsCovs = mallard.obs)


# Vizualize it
plot(mallardUMF, addgrid=FALSE, col=heat.colors)

mallardUMF


# Summarize it
summary(mallardUMF)

str(mallardUMF)

numSites(mallardUMF)

numY(mallardUMF)

obsNum(mallardUMF)


# Extract components of data
getY(mallardUMF)
	
obsCovs(mallardUMF)
obsCovs(mallardUMF, matrices = TRUE)

siteCovs(mallardUMF)

mallardUMF[1:5,]	# First 5 rows in wide format

mallardUMF[,1:2]	# First 2 observations



}
\keyword{classes}
