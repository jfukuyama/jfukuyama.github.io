context("Check numerical derivative")
source("numerical_deriv.R")

test_that("derivatives match on simple functions", {
    expect_equal(deriv(function(x) x^2, 1), 2)
    expect_equal(deriv(function(x) 2 * x, -5), 2)
    expect_equal(deriv(function(x) x^2, 0), 0)
    expect_equal(deriv(function(x) 2 * x, 0), 2)
    expect_equal(deriv(function(x) exp(x), 0), exp(0))
})

test_that("error thrown when derivative doesn't exist", {
    expect_error(deriv(function(x) log(x), 0))
}) 
