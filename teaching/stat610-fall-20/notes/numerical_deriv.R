deriv = function(fn, x) {
    eps = .Machine$double.eps
    if(x == 0) {
        h = 2 * eps
    } else {
        h = sqrt(eps) * x
    }
    deriv = (fn(x + h) - fn(x - h)) / (2 * h)
    return(deriv)
}
