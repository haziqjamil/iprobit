################################################################################
#
#   iprobit: Binary and Multinomial Probit Regression with I-priors
#   Copyright (C) 2017  Haziq Jamil
#
#   This program is free software: you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation, either version 3 of the License, or
#   (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this program. If not, see <http://www.gnu.org/licenses/>.
#
################################################################################

#' @export
gen_mixture <- function(n = 500, m = 2, mu = m / 2 + 1, sd = 1,
                        proportion = rep(0.5, m), seed = NULL) {
  if (!is.null(seed)) set.seed(seed)

  # Angles
  angles <- seq(from = 0, by = 360 / m, length = m) * pi / 180

  # Means
  m1 <- mu * cos(angles)
  m2 <- mu * sin(angles)

  mix <- list(1)
  for (i in 1:m) {
    mix[[i]] <- mvtnorm::rmvnorm(n, mean = c(m1[i], m2[i]), sigma = diag(sd, 2))
  }

  # Classes
  y <- factor(sample(1:m, size = n, replace = TRUE, prob = proportion))

  # Data
  X <- matrix(NA, ncol = 2, nrow = n)
  for (i in 1:m) {
    X[y == i, ] <- mix[[i]][y == i, ]
  }

  res <- list(X = X[order(y), ], y = y[order(y)])
  class(res) <- "iprobitData"
  res
}

#' @export
gen_spiral <- function(n = 300, m = 2, cycles = 2, sd = 0, seed = NULL) {
  if (!is.null(seed)) set.seed(seed)

  angles <- seq(from = 0, by = 360 / m, length = m) * pi / 180

  y <- factor(c(rep(1, round(n / m) + n %% m), rep(2:m, each = round(n / m))))

  tmp <- mlbench::mlbench.1spiral(n = round(n / m) + n %% m, cycles = cycles, sd = sd)
  tmp <- tmp
  spirals <- list(tmp)
  for (i in 2:m) {
    a <- angles[i]
    tmp <- mlbench::mlbench.1spiral(n = round(n / m), cycles = cycles, sd = sd)
    tmp <- tmp
    spirals[[i]] <- tmp %*% matrix(c(cos(a), -sin(a), sin(a), cos(a)),
                                   nrow = 2, ncol = 2)
  }

  # Data
  X <- spirals[[1]]
  for (j in 2:m) {
    X <- rbind(X, spirals[[j]])
  }

  res <- list(X = X[order(y), ], y = y[order(y)])
  class(res) <- "iprobitData"
  res
}

#' @export
gen_circle <- function(n = 100, m = 2, sd = 0.1 / sqrt(m), seed = NULL) {
  if (!is.null(seed)) set.seed(seed)

  n.sim <- rep(n %/% m, m)
  n.sim[seq_len(n %% m)] <- n.sim[seq_len(n %% m)] + 1

  y <- factor(rep(1:m, n.sim))

  X <- NULL
  for (i in 1:m) {
    angles <- seq(from = 0, by = 360 / n.sim[i], length = n.sim[i]) * pi / 180
    tmp <- cbind(cos(angles) / m * i, sin(angles) / m * i) + rnorm(n.sim[i] * 2, sd = sd)
    X <- rbind(X, tmp)
  }

  res <- list(X = X[order(y), ], y = y[order(y)])
  class(res) <- "iprobitData"
  res
}

#' @export
plot.iprobitData <- function(x, ...) {
  plot.df <- data.frame(X = x$X, class = x$y)
  colnames(plot.df)

  ggplot(plot.df, aes(x = X.1, y = X.2, col = class)) +
    geom_point(alpha = 0.8) +
    labs(x = "X1", y = "X2", col = "Class") +
    theme_bw()
}

#' @export
as.data.frame.iprobitData <- function(x, ...) {
  data.frame(y = x$y, x$X)
}
