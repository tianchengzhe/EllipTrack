# Update Log (Denver Time)

## 2019.05.31  4.40am  (Commit 9-13)

*  Fix Maximal probability.

   **Motivation**. Can't handle Inf scores (event probabilities equal to 1). Disrupt the Track Linking module, especially the Post-Processing function.
   
   **Solution**. Probabilities are capped at 1 - 1e-10.
