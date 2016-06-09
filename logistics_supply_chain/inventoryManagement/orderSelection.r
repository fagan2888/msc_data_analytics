getQuantity <- function( m.val, sd.val, min.val, max.val ) {
  
  p <- 124
  c <- 100
  s <- 92
  d <- rnorm(10000, mean=m.val, sd=sd.val )
  f <- function(Q,p,c,s,d) mean(p*pmin(Q,d)+s*pmax((Q-d),0)-c*Q)
  q.val <- optimize(f, c(min.val,max.val), p=124, c=100, s=92, d=rnorm(10000, mean=m.val, sd=sd.val), maximum = T );
  
  return( q.val )
}

ms <- c(1017,1042,1358,2525,1100,2150,1113,4017,3296,2383)
sds <- c(388,646,496,680,762,807,1048,1113,2094,1394)
res <- data.frame( means=round(ms/2), stdvs=round(sds/2) )

res$quantities1 <- apply(res[,c('means','stdvs')], 1, function(x) getQuantity(x['means'],x['stdvs'],0,10000)[1]$maximum)
res$quantities2 <- apply(res[,c('means','stdvs')], 1, function(x) getQuantity(x['means'],x['stdvs'],600,10000)[1]$maximum)
res$quantities4 <- apply(res[,c('means','stdvs')], 1, function(x) getQuantity(x['means'],x['stdvs'],1200,10000)[1]$maximum)
