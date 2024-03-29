
# Royel et al. 2004 distance sampling

distsamp <- function(formula, data, 
	keyfun=c("halfnorm", "exp", "hazard", "uniform"), 
	output=c("density", "abund"), unitsOut=c("ha", "kmsq"), starts=NULL, 
	method="BFGS", control=list(), se = TRUE)
{
keyfun <- match.arg(keyfun)
output <- match.arg(output)
unitsOut <- match.arg(unitsOut)
db <- data@dist.breaks
tdWsq <- 2 / max(db)^2					# only used for pt-transects
strip.widths <- diff(db)				# only used for line-transects	
tlength <- data@tlength
survey <- data@survey
unitsIn <- data@unitsIn
if(all(is.na(data@plotArea))) {
	a <- calcAreas(dist.breaks = db, tlength = tlength, 
		survey = survey, output = output, M = numSites(data), 
		J = ncol(getY(data)), unitsIn = unitsIn, unitsOut = unitsOut)
	a <- c(t(a))
	data@plotArea <- a
	}
if(output == "abund" & length(table(tlength)) > 1)
	warning("Response is individuals per unit transect length")		
designMats <- getDesign2(formula, data)
X <- designMats$X; V <- designMats$V; y <- designMats$y
M <- nrow(y)
J <- ncol(y)
namat <- is.na(y)
a <- matrix(designMats$plotArea, M, J, byrow=TRUE)
lamParms <- colnames(X)
detParms <- colnames(V)
nAP <- length(lamParms)
nDP <- length(detParms)
nP <- nAP + nDP
pi <- matrix(NA, M, J)
switch(keyfun,
	halfnorm = { 
		altdetParms <- paste("sigma", colnames(V), sep="")
		if(is.null(starts)) {
			starts <- c(rep(0, nAP), log(max(db)), rep(0, nDP-1))
			names(starts) <- c(lamParms, detParms)
		} else {
			if(is.null(names(starts))) names(starts) <- c(lamParms, detParms)
			}
		nll <- function(param) {
			sigma <- drop(exp(V %*% param[(nAP+1):nP]))
			lambda <- drop(exp(X %*% param[1:nAP]))
			for(i in 1:M) 
			{
			switch(survey, 
				line = { 
					f.0 <- 2 * dnorm(0, 0, sd=sigma[i])
					int <- 2 * (pnorm(db[-1], 0, sd=sigma[i]) - 
						pnorm(db[-(J+1)], 0, sd=sigma[i]))
					pi[i,] <- int / f.0 / strip.widths 
					},
				point = {   
					for(j in 1:J) {
						pi[i, j] <- tdWsq * integrate(grhn, db[j], db[j+1], 
							sigma = sigma[i])$value
						}	
					})
			}
		ll <- dpois(y, lambda * pi * a, log=TRUE)
		ll[namat] <- 0
		-sum(ll)
		}},
	exp = { 
		altdetParms <- paste("rate", colnames(V), sep="")
		if(is.null(starts)) {
			starts <- c(rep(0, nAP), 0, rep(0, nDP-1))
			names(starts) <- c(lamParms, detParms)
		} else {
			if(is.null(names(starts)))
				names(starts) <- c(lamParms, detParms)
		}
		nll <- function(param) {
			rate <- drop(exp(V %*% param[(nAP+1):nP]))
			lambda <- drop(exp(X %*% param[1:nAP]))
			for(i in 1:M) 
			{
			switch(survey, 
				line = { 
					for(j in 1:J) {
						pi[i, j] <- integrate(gxexp, db[j], db[j+1],
							rate=rate[i])$value / strip.widths[j]
						}
					},
				point = {   
					for(j in 1:J) {
						pi[i, j] <- tdWsq * integrate(grexp, db[j], db[j+1], 
							rate = rate[i])$value
						}	
					})
			}
		ll <- dpois(y, lambda * pi * a, log=TRUE)
		ll[namat] <- 0
		-sum(ll)
		}},
	hazard = {	
		nDP <- length(detParms)
		nP <- nAP + nDP + 1
		altdetParms <- paste("shape", colnames(V), sep="")
		if(is.null(starts)) {
			starts <- c(rep(0, nAP), log(median(db)), rep(0, nDP-1), 1)
			names(starts) <- c(lamParms, detParms, "scale")
		} else {
			if(is.null(names(starts)))
				names(starts) <- c(lamParms, detParms, "scale")
		}
		nll <- function(param) {
			shape <- drop(exp(V %*% param[(nAP+1):(nP-1)]))
			scale <- drop(exp(param[nP]))
			lambda <- as.numeric(exp(X %*% param[1:nAP]))
			for(i in 1:M)
			{
			switch(survey, 
				line = { 
					for(j in 1:J) {
						pi[i, j] <- integrate(gxhaz, db[j], db[j+1],
							shape=shape[i], scale=scale)$value / strip.widths[j]
						}
					},
				point = {   
					for(j in 1:J) {
						pi[i, j] <- tdWsq * integrate(grhaz, db[j], db[j+1], 
							shape = shape[i], scale=scale)$value
						}	
					})
			}
		ll <- dpois(y, lambda * pi * a, log=TRUE)
		ll[namat] <- 0
		-sum(ll)
		}}, 
	uniform = {
		detParms <- character(0)
		altdetParms <- character(0)
		nDP <- 0	
		if(is.null(starts)) {
			starts <- rep(0, length(lamParms))
			names(starts) <- lamParms
		} else {
			if(is.null(names(starts)))
				names(starts) <- lamParms
			}
		nll <- function(param) 
			{
			lambda <- drop(exp(X %*% param))
			ll <- dpois(y, lambda * a, log=TRUE)
			ll[namat] <- 0
			-sum(ll)
			}
	})
fm <- optim(starts, nll, method=method, hessian=se, control=control)
opt <- fm
ests <- fm$par
if(se) {
	covMat <- tryCatch(solve(fm$hessian), error=function(x) 
		simpleError("Hessian is not invertible. Try using fewer covariates or providing starting values."))
	if(class(covMat)[1] == "simpleError") {
		print(covMat$message)
		covMat <- matrix(NA, nP, nP)
		} 
} else {
	covMat <- matrix(NA, nP, nP)
	}
estsAP <- ests[1:nAP]
if(keyfun == "hazard") {
	estsDP <- ests[(nAP+1):(nP-1)]
	estsScale <- ests[nP]
	}
else 
	estsDP <- ests[(nAP+1):nP]
covMatAP <- covMat[1:nAP, 1:nAP, drop=F]
if(keyfun=="hazard") {
	covMatDP <- covMat[(nAP+1):(nP-1), (nAP+1):(nP-1), drop=F]
	covMatScale <- covMat[nP, nP, drop=F]
	}
else if(keyfun!="uniform")
	covMatDP <- covMat[(nAP+1):nP, (nAP+1):nP, drop=F]
names(estsDP) <- altdetParms 
fmAIC <- 2 * fm$value + 2 * nP
stateName <- switch(output, abund = "Abundance", density = "Density")
stateEstimates <- unmarkedEstimate(name = stateName, 
	short.name = "lam", estimates = estsAP, covMat = covMatAP, 
	invlink = "exp", invlinkGrad = "exp")
if (keyfun != "uniform") {
	detEstimates <- unmarkedEstimate(name = "Detection", short.name = "p", 
		estimates = estsDP, covMat = covMatDP, invlink = "exp", 
		invlinkGrad = "exp")
	if(keyfun != "hazard")
		estimateList <- unmarkedEstimateList(list(state=stateEstimates, 
			det=detEstimates))
	else {
		scaleEstimates <- unmarkedEstimate(name = "Detection(scale)", 
			short.name = "p", estimates = estsScale, 
			covMat = covMatScale, invlink = "exp", invlinkGrad = "exp")
		estimateList <- unmarkedEstimateList(list(state=stateEstimates, 
			det=detEstimates, scale=scaleEstimates))
		}			
} else {
	estimateList <- unmarkedEstimateList(list(state=stateEstimates))
	}
dsfit <- new("unmarkedFitDS", fitType = "distsamp", call = match.call(), 
	opt = opt, formula = formula, data = data, keyfun=keyfun, 
	sitesRemoved = designMats$removed.sites, unitsOut=unitsOut, 
	estimates = estimateList, AIC = fmAIC, negLogLike = fm$value, 
	nllFun = nll, output=output)
return(dsfit)
}


# Detection functions

gxhn <- function(x, sigma) exp(-x^2/(2 * sigma^2))
gxexp <- function(x, rate) exp(-x / rate) 
gxhaz <- function(x, shape, scale)  1 - exp(-(x/shape)^-scale)
grhn <- function(r, sigma) exp(-r^2/(2 * sigma^2)) * r
grexp <- function(r, rate) exp(-r / rate) * r
grhaz <- function(r, shape, scale)  (1 - exp(-(r/shape)^-scale)) * r

dxhn <- function(x, sigma) 
	gxhn(x=x, sigma=sigma) / integrate(gxhn, 0, Inf, sigma=sigma)$value
drhn <- function(r, sigma) 
	grhn(r=r, sigma=sigma) / integrate(grhn, 0, Inf, sigma=sigma)$value
dxexp <- function(x, rate) 
	gxexp(x=x, rate=rate) / integrate(gxexp, 0, Inf, rate=rate)$value
drexp <- function(r, rate) 
	grexp(r=r, rate=rate) / integrate(grexp, 0, Inf, rate=rate)$value
dxhaz <- function(x, shape, scale)
	gxhaz(x=x, shape=shape, scale=scale) / integrate(gxhaz, 0, Inf, 
		shape=shape, scale=scale)$value
drhaz <- function(r, shape, scale)
	grhaz(r=r, shape=shape, scale=scale) / integrate(grhaz, 0, Inf, 
		shape=shape, scale=scale)$value
		



# Vectorized version of integrate()
vIntegrate <- Vectorize(integrate, c("lower", "upper"))


# Multinomial cell probabilities for line or point transects under half-normal model
cp.hn <- function(d, s, survey) 
{
switch(survey, 
	line = {
		strip.widths <- diff(d)
		f.0 <- 2 * dnorm(0, 0, sd=s)
		int <- 2 * (pnorm(d[-1], 0, sd=s) - pnorm(d[-length(d)], 0, sd=s))
		cp <- int / f.0 / strip.widths 
	},
	point = {
		W <- max(d)
		int <- as.numeric(vIntegrate(grhn, d[-length(d)], d[-1], 
			sigma=s)["value",])
		cp <- 2 / W^2 * int
	})
return(cp)
}



cp.exp <- function(d, rate, survey) 
{
	switch(survey, 
		line = {
			strip.widths <- diff(d)
			int <- as.numeric(vIntegrate(gxexp, d[-length(d)], d[-1],
				rate=rate)["value",])
			cp <- int / strip.widths
		},
		point = {
			W <- max(d)
			int <- as.numeric(vIntegrate(grexp, d[-length(d)], d[-1], 
				rate=rate)["value",])
			cp <- 2 / W^2 * int
		})
	return(cp)
}



cp.haz <- function(d, shape, scale, survey)
{
	switch(survey, 
		line = {
			strip.widths <- diff(d)
			int <- as.numeric(vIntegrate(gxhaz, d[-length(d)], d[-1], 
				shape=shape, scale=scale)["value",])
			cp <- int / strip.widths
		},
		point = {
			W <- max(d)
			int <- as.numeric(vIntegrate(grhaz, d[-length(d)], d[-1], 
				shape=shape, scale=scale)["value",])
			cp <- 2 / W^2 * int
		})
	return(cp)
}




        


# Prepare area argument for distsamp(). This is primarily for internal use

calcAreas <- function(dist.breaks, tlength, survey, output, M, J, unitsIn, 
	unitsOut)
{
if(J != length(dist.breaks) - 1)
	stop("J must equal length(dist.breaks) - 1")
if(!missing(tlength))
	if(length(tlength) > 0 & length(tlength) != M)
		stop("length(tlength) must equal M")
switch(unitsIn, 
	km = conv <- 1,
	m = conv <- 1000
	)
switch(output, 	
	density = {
		switch(survey, 
			line = {
				stripwidths <- (((dist.breaks*2)[-1] - 
					(dist.breaks*2)[-(J+1)])) / conv
				tl <- tlength / conv
				a <- rep(tl, each=J) * stripwidths						# km^2
				a <- matrix(a, nrow=M, ncol=J, byrow=TRUE)
				if(unitsOut == "ha") a <- a * 100
				},
			point = {
				W <- max(dist.breaks) / conv
				a <- matrix(rep(pi * W^2, each=J), M, J, byrow=TRUE) 	# km^2
				if(unitsOut == "ha") a <- a * 100			
				})
			},
	abund = { 
		switch(survey, 
			line = a <- matrix(rep(tlength, each=J), M, J, byrow=TRUE),
			point = a <- matrix(1, M, J))
		})
return(a)
}





# Convert individual-level distance data to the transect-level format required 
# by distsamp()

formatDistData <- function(distData, distCol, transectNameCol, dist.breaks)
{
transects <- distData[,transectNameCol]
M <- nlevels(transects)
J <- length(dist.breaks) - 1
y <- matrix(NA, M, J, 
	dimnames = list(levels(transects), paste("y", 1:J, sep=".")))
for(i in 1:M) {
	sub <- subset(distData, transects==rownames(y)[i])
	y[i,] <- table(cut(sub[,distCol], dist.breaks, include.lowest=TRUE))
	}
return(y)
}



## Sight distance to perpendicular distance

sight2perpdist <- function(sightdist, sightangle) 
{
if(any(0 > sightangle | sightangle > 180))
	stop("sightangle must be degrees in [0, 180]")
sightdist * sin(sightangle * pi / 180)
}
 