#  File R/summary.statistics.networkDynamic.R in package tergm, part of the Statnet suite
#  of packages for network analysis, http://statnet.org .
#
#  This software is distributed under the GPL-3 license.  It is free,
#  open source, and has the attribution requirements (GPL Section 7) at
#  http://statnet.org/attribution
#
#  Copyright 2008-2018 Statnet Commons
#######################################################################

#' Calculation of networkDynamic statistics.
#' 
#' A method for \code{\link[ergm]{summary_formula}} to calculate the
#' specified statistics for an observed \code{\link{networkDynamic}} at the
#' specified time point(s).  See \code{\link{ergm-terms}} for more information
#' on the statistics that may be specified.
#' 
#' 
#' @aliases summary.formula
#' @param object An \code{\link{formula}} object with a
#'   \code{\link{networkDynamic}} as its LHS. (See
#'   \code{\link[ergm]{summary_formula}} for more details.)
#' @param at A vector of time points at which to calculate the
#'   statistics.
#' @param basis An optional \code{\link{networkDynamic}} object
#'   relative to which the statistics should be calculated.
#' @param \dots Further arguments passed to or used by methods.
#' @return A matrix with \code{length(at)} rows, one for each time
#'   point in \code{at}, and columns for each term of the formula,
#'   containing the corresponding statistics measured on the network.
#' @seealso [ergm()], [`networkDynamic`], [`ergm-terms`],
#'   [summary.formula]
#' @keywords models
#' @examples
#' 
#' # create a toy dynamic network
#' my.nD <- network.initialize(100,directed=FALSE)
#' activate.vertices(my.nD, onset=0, terminus = 10)
#' add.edges.active(my.nD,tail=1:2,head=2:3,onset=5,terminus=8)
#' 
#' # use a summary formula to display number of isolates and edges
#' # at discrete time points
#' summary(my.nD~isolates+edges, at=1:10)
#' @importFrom ergm summary_formula
#' @export
summary_formula.networkDynamic <- function(object, at,..., basis=NULL){
  if (missing(at) || !is.numeric(at)){
    stop( "summary_formula.networkDynamic requires an 'at' parameter specifying the time points at which to summarize the formula")
  }
  if(!is.null(basis)) object <- nonsimp_update.formula(object, basis~., from.new="basis")
  duration.dependent <- is.durational(object)
  t(rbind(sapply(at,
              function(t){
                nw <- network.extract.with.lasttoggle(ergm.getnetwork(object), t, duration.dependent)
                f <- nonsimp_update.formula(object, nw~., from.new="nw")
                # make sure this is dispatched to the .network  and not .networkDynamic version
                # of summary statistics to avoid recurisve calls
                getS3method("summary_formula","network")(f,...)
              }
          )
      )
  )
}
