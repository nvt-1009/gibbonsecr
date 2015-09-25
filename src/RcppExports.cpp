// This file was generated by Rcpp::compileAttributes
// Generator token: 10BE3573-1514-4C36-9D1C-5A225CD40393

#include <RcppArmadillo.h>
#include <Rcpp.h>

using namespace Rcpp;

// calc_bearings_rcpp
NumericMatrix calc_bearings_rcpp(const NumericMatrix& A, const NumericMatrix& Z);
RcppExport SEXP gibbonsecr_calc_bearings_rcpp(SEXP ASEXP, SEXP ZSEXP) {
BEGIN_RCPP
    Rcpp::RObject __result;
    Rcpp::RNGScope __rngScope;
    Rcpp::traits::input_parameter< const NumericMatrix& >::type A(ASEXP);
    Rcpp::traits::input_parameter< const NumericMatrix& >::type Z(ZSEXP);
    __result = Rcpp::wrap(calc_bearings_rcpp(A, Z));
    return __result;
END_RCPP
}
// calc_distances_rcpp
NumericMatrix calc_distances_rcpp(const NumericMatrix& A, const NumericMatrix& Z);
RcppExport SEXP gibbonsecr_calc_distances_rcpp(SEXP ASEXP, SEXP ZSEXP) {
BEGIN_RCPP
    Rcpp::RObject __result;
    Rcpp::RNGScope __rngScope;
    Rcpp::traits::input_parameter< const NumericMatrix& >::type A(ASEXP);
    Rcpp::traits::input_parameter< const NumericMatrix& >::type Z(ZSEXP);
    __result = Rcpp::wrap(calc_distances_rcpp(A, Z));
    return __result;
END_RCPP
}
// negloglik_rcpp
double negloglik_rcpp(const List& data, const List& mask, const List& pars, const IntegerMatrix& detected, const IntegerMatrix& usage, int n, int S, int K, int M, double a, int detectfn_code, int bearings_pdf_code, int distances_pdf_code);
RcppExport SEXP gibbonsecr_negloglik_rcpp(SEXP dataSEXP, SEXP maskSEXP, SEXP parsSEXP, SEXP detectedSEXP, SEXP usageSEXP, SEXP nSEXP, SEXP SSEXP, SEXP KSEXP, SEXP MSEXP, SEXP aSEXP, SEXP detectfn_codeSEXP, SEXP bearings_pdf_codeSEXP, SEXP distances_pdf_codeSEXP) {
BEGIN_RCPP
    Rcpp::RObject __result;
    Rcpp::RNGScope __rngScope;
    Rcpp::traits::input_parameter< const List& >::type data(dataSEXP);
    Rcpp::traits::input_parameter< const List& >::type mask(maskSEXP);
    Rcpp::traits::input_parameter< const List& >::type pars(parsSEXP);
    Rcpp::traits::input_parameter< const IntegerMatrix& >::type detected(detectedSEXP);
    Rcpp::traits::input_parameter< const IntegerMatrix& >::type usage(usageSEXP);
    Rcpp::traits::input_parameter< int >::type n(nSEXP);
    Rcpp::traits::input_parameter< int >::type S(SSEXP);
    Rcpp::traits::input_parameter< int >::type K(KSEXP);
    Rcpp::traits::input_parameter< int >::type M(MSEXP);
    Rcpp::traits::input_parameter< double >::type a(aSEXP);
    Rcpp::traits::input_parameter< int >::type detectfn_code(detectfn_codeSEXP);
    Rcpp::traits::input_parameter< int >::type bearings_pdf_code(bearings_pdf_codeSEXP);
    Rcpp::traits::input_parameter< int >::type distances_pdf_code(distances_pdf_codeSEXP);
    __result = Rcpp::wrap(negloglik_rcpp(data, mask, pars, detected, usage, n, S, K, M, a, detectfn_code, bearings_pdf_code, distances_pdf_code));
    return __result;
END_RCPP
}
