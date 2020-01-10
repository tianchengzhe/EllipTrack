# Update Log (Denver Time)

## 2019.05.31  4.40am  (Commit 9-13)

*  Fix Maximal probability.

   **Motivation**. Can't handle Inf scores (event probabilities equal to 1). Disrupt the Track Linking module, especially the Post-Processing function.
   
   **Solution**. Probabilities are capped at 1 - 1e-10.

## 2019.06.18  1.00am  (Commit 14)

*  Calculation of variance

## 2019.09.08  9.18am  (Commit 15)

*  Accelerate track linking module

## 2019.09.08  3.39pm  (Commit 16-17)

*  Fix "jitter_adjusted_all_ellipse_info"

## 2020.01.10  3.23am  (Commit 18)

*  Redesign for paper revision

