// Generated by using Rcpp::compileAttributes() -> do not edit by hand
// Generator token: 10BE3573-1514-4C36-9D1C-5A225CD40393

#include <RcppArmadillo.h>
#include <Rcpp.h>

using namespace Rcpp;

// calc_bearings_rcpp
NumericMatrix calc_bearings_rcpp(const NumericMatrix& A, const NumericMatrix& Z);
RcppExport SEXP _gibbonsecr_calc_bearings_rcpp(SEXP ASEXP, SEXP ZSEXP) {
BEGIN_RCPP
    Rcpp::RObject rcpp_result_gen;
    Rcpp::RNGScope rcpp_rngScope_gen;
    Rcpp::traits::input_parameter< const NumericMatrix& >::type A(ASEXP);
    Rcpp::traits::input_parameter< const NumericMatrix& >::type Z(ZSEXP);
    rcpp_result_gen = Rcpp::wrap(calc_bearings_rcpp(A, Z));
    return rcpp_result_gen;
END_RCPP
}
// calc_distances_rcpp
NumericMatrix calc_distances_rcpp(const NumericMatrix& A, const NumericMatrix& Z);
RcppExport SEXP _gibbonsecr_calc_distances_rcpp(SEXP ASEXP, SEXP ZSEXP) {
BEGIN_RCPP
    Rcpp::RObject rcpp_result_gen;
    Rcpp::RNGScope rcpp_rngScope_gen;
    Rcpp::traits::input_parameter< const NumericMatrix& >::type A(ASEXP);
    Rcpp::traits::input_parameter< const NumericMatrix& >::type Z(ZSEXP);
    rcpp_result_gen = Rcpp::wrap(calc_distances_rcpp(A, Z));
    return rcpp_result_gen;
END_RCPP
}
// nearest_rcpp
NumericVector nearest_rcpp(const NumericMatrix& A, const NumericMatrix& B);
RcppExport SEXP _gibbonsecr_nearest_rcpp(SEXP ASEXP, SEXP BSEXP) {
BEGIN_RCPP
    Rcpp::RObject rcpp_result_gen;
    Rcpp::RNGScope rcpp_rngScope_gen;
    Rcpp::traits::input_parameter< const NumericMatrix& >::type A(ASEXP);
    Rcpp::traits::input_parameter< const NumericMatrix& >::type B(BSEXP);
    rcpp_result_gen = Rcpp::wrap(nearest_rcpp(A, B));
    return rcpp_result_gen;
END_RCPP
}
// negloglik_rcpp
double negloglik_rcpp(const List& data, const List& mask, const List& pars, const IntegerMatrix& detected, const IntegerMatrix& usage, int n, int S, int K, int M, double a, int detfunc_code, int bearings_pdf_code, int distances_pdf_code);
RcppExport SEXP _gibbonsecr_negloglik_rcpp(SEXP dataSEXP, SEXP maskSEXP, SEXP parsSEXP, SEXP detectedSEXP, SEXP usageSEXP, SEXP nSEXP, SEXP SSEXP, SEXP KSEXP, SEXP MSEXP, SEXP aSEXP, SEXP detfunc_codeSEXP, SEXP bearings_pdf_codeSEXP, SEXP distances_pdf_codeSEXP) {
BEGIN_RCPP
    Rcpp::RObject rcpp_result_gen;
    Rcpp::RNGScope rcpp_rngScope_gen;
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
    Rcpp::traits::input_parameter< int >::type detfunc_code(detfunc_codeSEXP);
    Rcpp::traits::input_parameter< int >::type bearings_pdf_code(bearings_pdf_codeSEXP);
    Rcpp::traits::input_parameter< int >::type distances_pdf_code(distances_pdf_codeSEXP);
    rcpp_result_gen = Rcpp::wrap(negloglik_rcpp(data, mask, pars, detected, usage, n, S, K, M, a, detfunc_code, bearings_pdf_code, distances_pdf_code));
    return rcpp_result_gen;
END_RCPP
}

static const R_CallMethodDef CallEntries[] = {
    {"_gibbonsecr_calc_bearings_rcpp", (DL_FUNC) &_gibbonsecr_calc_bearings_rcpp, 2},
    {"_gibbonsecr_calc_distances_rcpp", (DL_FUNC) &_gibbonsecr_calc_distances_rcpp, 2},
    {"_gibbonsecr_nearest_rcpp", (DL_FUNC) &_gibbonsecr_nearest_rcpp, 2},
    {"_gibbonsecr_negloglik_rcpp", (DL_FUNC) &_gibbonsecr_negloglik_rcpp, 13},
    {NULL, NULL, 0}
};

RcppExport void R_init_gibbonsecr(DllInfo *dll) {
    R_registerRoutines(dll, NULL, CallEntries, NULL, NULL);
    R_useDynamicSymbols(dll, FALSE);
}
