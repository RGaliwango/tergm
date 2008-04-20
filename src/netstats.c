#include "netstats.h"
#include "MCMC.h"
/*****************
 void network_stats_wrapper

 Wrapper for a call from R.  Return the change in the statistics when
 we go from an empty graph to the observed graph.  If the empty graph
 has true global values equal to zero for all statistics, then this
 change gives the true global values for the observed graph.
*****************/
void network_stats_wrapper(int *heads, int *tails, int *dnedges, 
			   int *dn, int *dflag,  int *bipartite,
			   int *nterms, char **funnames,
			   char **sonames, double *inputs,  double *stats)
{
  int directed_flag, hammingterm;
  Vertex n_nodes;
  Edge n_edges, nddyads;
  Network nw[2];
  Model *m;
  ModelTerm *thisterm;
  Vertex bip;

/*	     Rprintf("prestart with setup\n"); */
  n_nodes = (Vertex)*dn; 
  n_edges = (Edge)*dnedges;     
  directed_flag = *dflag;
  bip = (Vertex)*bipartite;
  
  m=ModelInitialize(*funnames, *sonames, inputs, *nterms);
  nw[0]=NetworkInitialize(NULL, NULL, 0,
                          n_nodes, directed_flag, bip, 0);

  hammingterm=ModelTermHamming (*funnames, *nterms);
/*	     Rprintf("start with setup\n"); */
  if(hammingterm>0){
    thisterm = m->termarray + hammingterm - 1;
    nddyads = (Edge)(thisterm->inputparams[0]);
    /* Initialize discordance network to the reference network. */
    nw[1]=NetworkInitializeD(thisterm->inputparams+1, 
			     thisterm->inputparams+1+nddyads, nddyads,
			     n_nodes, directed_flag, bip, 0);
  }

  /* Compute the change statistics and copy them to stats for return to R. */
  SummStats(n_edges, heads, tails, nw, m,stats);
  
  ModelDestroy(m);
  NetworkDestroy(nw);
  if (hammingterm > 0)
    NetworkDestroy(&nw[1]);
}


/****************
 void SummStats Computes summary statistics for a network. Must be
 passed an empty network (and a possible discordance network) and 
 passed an empty network
*****************/
void SummStats(Edge n_edges, Vertex *heads, Vertex *tails,
	       Network *nwp, Model *m, double *stats){

  ShuffleEdges(heads,tails,n_edges); /* Shuffle edgelist. */

  /* Doing this one toggle at a time saves a lot of toggles... */
  for(Edge e=0; e<n_edges; e++){
    ModelTerm *mtp = m->termarray;
    double *dstats = m->workspace;

    for (unsigned int i=0; i < m->n_terms; i++){
      mtp->dstats = dstats; /* Stuck the change statistic here.*/
      if(!mtp->s_func)
	(*(mtp->d_func))(1, heads+e, tails+e, 
			 mtp, nwp);  /* Call d_??? function */
      dstats += (mtp++)->nstats;
    }

    for (unsigned int i=0; i < m->n_stats; i++){
      stats[i]+=m->workspace[i];
    }

    ToggleEdge(heads[e],tails[e],nwp);
  }

  ModelTerm *mtp = m->termarray;
  double *dstats = m->workspace;
  for (unsigned int i=0; i < m->n_terms; i++){
    mtp->dstats = dstats; /* Stuck the change statistic here.*/
    if(mtp->s_func)
      (*(mtp->s_func))(mtp, nwp);  /* Call s_??? function */
    dstats += (mtp++)->nstats;
  }
}