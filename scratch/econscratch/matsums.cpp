#include "Rcpp.h"
using namespace Rcpp;



// Cols ----------------


// [[Rcpp::export]]
NumericVector Sugar_colSums(const NumericMatrix& x) {
  return colSums(x);
}

// Rows ----------------

// [[Rcpp::export]]
NumericVector Sugar_rowSums(const NumericMatrix& x) {
  return rowSums(x);
}

