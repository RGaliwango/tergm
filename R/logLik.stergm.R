
logLik.stergm<-function(object, add=FALSE, force.reeval=FALSE, eval.loglik=add || force.reeval, control=control.logLik.stergm(), ...){
  check.control.class()
  if(object$estimate=="EGMME") stop("Log-likelihood for ",object$estimate," is not meaningful.")
  
  if(!is.null(control$seed))  set.seed(as.integer(control$seed))

  if(add){
    object$formation.fit <- logLik(object$formation.fit, add=TRUE, force.reeval=FALSE, eval.loglik = add || force.reeval, control=control$control.form)
    object$dissolution.fit <- logLik(object$dissolution.fit, add=TRUE, force.reeval=FALSE, eval.loglik = add || force.reeval, control=control$control.diss)
    
    object
  }else{
    llk.form <- logLik(object$formation.fit, add=FALSE, force.reeval=FALSE, eval.loglik = add || force.reeval, control=control$control.form)
    llk.diss <- logLik(object$dissolution.fit, add=FALSE, force.reeval=FALSE, eval.loglik = add || force.reeval, control=control$control.diss)

    llk <- llk.form + llk.diss
    attr(llk,"df") <- attr(llk.form,"df") + attr(llk.diss,"df")
    attr(llk,"nobs") <- attr(llk.form,"nobs") + attr(llk.diss,"nobs")
    
    llk
  }
}