
setClass("unmarkedLinComb",
         representation(parentEstimate = "unmarkedEstimate",
                        estimate = "numeric",
                        covMat = "matrix",
                        coefficients = "matrix"))

setClass("unmarkedBackTrans",
         representation(parentLinComb = "unmarkedLinComb",
                        estimate = "numeric",
                        covMat = "matrix"))

setClassUnion("linCombOrBackTrans", c("unmarkedLinComb", "unmarkedBackTrans"))

setMethod("show",
          signature(object = "unmarkedLinComb"),
          function(object) {
            
            cat("Linear combination(s) of",object@parentEstimate@name,"estimate(s)\n\n")

            df.coefs <- as.data.frame(object@coefficients)
            colnames(df.coefs) <- names(object@parentEstimate@estimates)
            lcTable <- data.frame(Estimate = object@estimate, SE = SE(object))
            lcTable <- cbind(lcTable, df.coefs)
            if(nrow(lcTable) > 1) {
              print(lcTable, digits = 3, row.names = 1:nrow(lcTable))
            } else {
              print(lcTable, digits = 3, row.names = FALSE)
            }
            cat("\n")
            

          })

setMethod("show",
          signature(object = "unmarkedBackTrans"),
          function(object) {
            cat("Backtransformed linear combination(s) of",object@parentLinComb@parentEstimate@name,"estimate(s)\n\n")

            lcTable <- data.frame(LinComb = object@parentLinComb@estimate)

            df.coefs <- as.data.frame(object@parentLinComb@coefficients)
            colnames(df.coefs) <- names(object@parentLinComb@parentEstimate@estimates)

            lcTable <- cbind(lcTable, df.coefs)
            
            btTable <- data.frame(Estimate = object@estimate, SE = SE(object))

            btTable <- cbind(btTable, lcTable)
            
            if(nrow(btTable) > 1) {
              print(btTable, digits = 3, row.names = 1:nrow(btTable))
            } else {
              print(btTable, digits = 3, row.names = FALSE)
            }
            
            cat("\nTransformation:", object@parentLinComb@parentEstimate@invlink,"\n")
          })


setMethod("backTransform",
          signature(obj = "unmarkedLinComb"),
          function(obj) {
            
            ## In general, MV delta method is Var=J*Sigma*J^T where J is Jacobian
            ## In this case, J is diagonal with elements = gradient
            ## This reduces to scaling the rows and then columns of Sigma by the gradient
            e <- do.call(obj@parentEstimate@invlink,list(obj@estimate))
            grad <- do.call(obj@parentEstimate@invlinkGrad,list(obj@estimate))
            
            if(length(obj@estimate) > 1) {
              v <- diag(grad) %*% obj@covMat %*% diag(grad)
            } else {
              v <- grad^2 * obj@covMat
            }
            
            umbt <- new("unmarkedBackTrans", parentLinComb = obj,
                        estimate = e, covMat = v)
            umbt
          })


setMethod("SE", "linCombOrBackTrans",
          function(obj) {
            sqrt(diag(obj@covMat))
          })

setMethod("coef", "linCombOrBackTrans",
          function(object) {
            object@estimate
          })

setMethod("vcov", "linCombOrBackTrans",
          function(object) {
            object@covMat
          })

setMethod("confint", "unmarkedLinComb",
          function(object, parm, level = 0.95) {
            if(missing(parm)) parm <- 1:length(object@estimate)
            ests <- object@estimate[parm]
            ses <- SE(object)[parm]
            z <- qnorm((1-level)/2, lower.tail = FALSE)
            lower.lim <- ests - z*ses
            upper.lim <- ests + z*ses
            ci <- as.matrix(cbind(lower.lim, upper.lim))
            colnames(ci) <- c((1-level)/2, 1- (1-level)/2)
            rownames(ci) <- 1:nrow(ci)
            if(nrow(ci) == 1) rownames(ci) <- ""
            ci
          })

setMethod("confint", "unmarkedBackTrans",
          function(object, parm, level = 0.95) {
            if(missing(parm)) parm <- 1:length(object@estimate)
            ci.orig <- callGeneric(object@parentLinComb, parm, level)
            invlink <- object@parentLinComb@parentEstimate@invlink
            lower.lim <- do.call(invlink, list(ci.orig[,1]))
            upper.lim <- do.call(invlink, list(ci.orig[,2]))
            ci <- as.matrix(cbind(lower.lim, upper.lim))
            colnames(ci) <- c((1-level)/2, 1- (1-level)/2)
            rownames(ci) <- 1:nrow(ci)
            if(nrow(ci) == 1) rownames(ci) <- ""
            ci
          })
