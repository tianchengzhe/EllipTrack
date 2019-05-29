.. include:: .special.rst

.. _parameters_track_linking_Page:

=============
Track Linking
=============

Algorithm
*********

EllipTrack implements a previously published probabilistic track linking algorithm (Magnusson *et al.* 2015).
In brief, the algorithm uses a machine learning algorithm to predict cell behaviors, and then constructs cell tracks by maximizing the probability of cell lineage trees.

.. _parameters_track_linking_terminology:

Terminology
===========

Based on the original publication (Magnusson *et al.* 2015), EllipTrack uses the following terminologies.

Event
  A behavior that an ellipse displays.

  Two types of events are considered in EllipTrack: Morphological Events and Motion Events.

  **Morphological Events** are events related to the status of cells and ellipses. There are six morphologicial events:
  
  *  **Number of Cells**. Number of cell nuclei in the ellipse. EllipTrack assumes that an ellipse may contain zero, one, and two cell nuclei and defines an event for each cell number (3 events: **No Cell**, **One Cell**, and **Two Cells**).
  *  **Mitotic Cell (Before M)**. Cell is mitotic and will divide into two daughter cells in the next frame.
  *  **Newly Born Cell (After M)**. Cell is newly born and its mother underwent mitosis in the previous frame.
  *  **Apoptosis**. Cell is apoptotic and will disappear in the next frame.

     The latter three events only occur in ellipses containing one cell nucleus.

  **Motion Events** are events related to cell migration. There are two motion events:
  
  *  **Migration**. Cell migrates from a position in the current frame to a new position in a later frame.
  *  **Move In/Out**. Cell migrates from/to outside in the previous/next frame to/from the field of view in the current frame.

Cell Track
  A sequence of ellipses describing the behaviors of a cell.

Lineage Tree
  A tree of cell tracks describing the behaviors of a cell lineage.

For example, consider the lineage tree in :numref:`sample_lineage_tree`. 
The cell in Frame 1 (represented by the ellipse :math:`E_{1,1}`) undergoes mitosis and divides into two daughter cells in Frame 2 (:math:`E_{2,1}` and :math:`E_{2,2}`).
These two cells are under-segmented in Frame 3 (:math:`E_{3,1}`) and are again correctly segmented in Frame 4 (:math:`E_{4,1}` and :math:`E_{4,2}`).
The bottom cell (:math:`E_{4,2}`) undergoes apoptosis and disappears in Frame 5, while the top cell (:math:`E_{4,1}`) continues to exist (:math:`E_{5,1}`).

.. _sample_lineage_tree:

.. figure:: _static/images/track_lineage_example.png
   :width: 500
   :align: center
   
   Example lineage tree.

Events of the ellipses in this example are

*  :math:`E_{1,1}`. One Cell, Mitotic Cell.
*  :math:`E_{2,1}` and :math:`E_{2,2}`. One Cell, Newly Born Cell.
*  :math:`E_{3,1}`. Two Cells.
*  :math:`E_{4,1}` and :math:`E_{5,1}`. One Cell.
*  :math:`E_{4,2}`. One Cell, Apoptotic Cell.

There are three cell tracks

*  Track 1. :math:`E_{1,1}`
*  Track 2. :math:`E_{2,1} \rightarrow E_{3,1} \rightarrow E_{4,1} \rightarrow E_{5,1}`
*  Track 3. :math:`E_{2,2} \rightarrow E_{3,1} \rightarrow E_{4,2}`

and one lineage tree consists of all ellipses (and therefore all cell tracks) in :numref:`sample_lineage_tree`.

Computation of Probabilities
============================

Event
-----

Event probabilities are computed by machine learning algorithms.

Morphological Events
  EllipTrack constructs Linear Discriminant Analysis (LDA) classifiers with user-provided training datasets, 
  and then applies the classifiers to every ellipse in the movie to predict its probability of exhibiting these events.
  Event-specific details are
  
  **Number of Cells**. A multi-class LDA classifier is constructed for all three events. 
  Ellipses labeled as "No Cells" and "Two Cells" are used as the training samples for **No Cell** and **Two Cells**, 
  while all other ellipses are used as the samples for **One Cell**.

  **Mitotic Cell (Before M)**, **Newly Born Cell (After M)**, and **Apoptosis**. 
  For each event, a binary LDA classifier is constructed.
  Ellipses labeled as "Before M"/"After M"/"Apoptotic" are used as the training samples for exhibiting the event,
  while all other ellipses are used as the samples for not exhibiting the event.
  
  In case training samples of an event are absent, EllipTrack assumes that this event occurs with a small probability defined by :greenitalic:`empty_prob`.

  .. admonition:: Remark

     The event **One Cell** should be interpreted as ellipses containing one cell nucleus but the cell is neither mitotic, newly born, nor apoptotic.
     
Motion Events
  EllipTrack models cell migration by Random Walk. 

  Migration
    EllipTrack models this process with a two-dimensional Random Walk.
    Depending on whether ellipse similarity is considered or not (controlled by :greenitalic:`if_similarity_for_migration`), EllipTrack provides two methods to compute this probability.
    
    If ellipse similarity is not considered, EllipTrack computes the probability of migrating from Ellipse :math:`E_{i,m}` (i-th ellipse in Frame m) to Ellipse :math:`E_{j,n}` (j-th ellipse in Frame n) by

    .. math:: 
       :label: migration_no_similarity

       P(E_{i,m} \rightarrow E_{j,n}) = \frac{1}{2\pi\sigma^2(n-m)}\exp\left\{-\frac{\Delta x^2+\Delta y^2}{2\sigma^2(n-m)}\right\}
    
    Here, :math:`\Delta x` and :math:`\Delta y` are the distances between the ellipse centroids in the x and y directions. 
    :math:`\sigma` is the standard deviation of Random Walk and this value can be intepreted as the average distance a cell travels in one frame and one direction;
    :math:`n-m` is the number of frames ("gap") between these two ellipses. 
    If gap is greater than one, the cell skips intermediate frames by directly migrating from Frame m to Frame n.

    If ellipse similarity is considered, EllipTrack computes the probability by

    .. math::
      
       P(E_{i,m} \rightarrow E_{j,n}) = \frac{S(E_{i,m}, E_{j,n}) P_{mig}}{S(E_{i,m}, E_{j,n}) P_{mig} + (1-S(E_{i,m}, E_{j,n}))P_{nonmig}}

    Here, :math:`P_{mig}` is computed by Equation :eq:`migration_no_similarity`; 
    :math:`S(E_{i,m}, E_{j,n})` is the probability that these two ellipses represent the same cell;
    and :math:`P_{nonmig}` is the null probability of migration (defined by :greenitalic:`likelihood_nonmigration`).
    
    To compute :math:`S(E_{i,m}, E_{j,n})`, EllipTrack constructs a binary LDA classifier 
    where the feature differences between ellipses belonging to the same cell track are used as the training samples for representing the same cell,
    and the feature differences between randomly selected ellipses are used as the training samples for not representing the same cell.
    EllipTrack then applies the classifier to the feature difference between :math:`E_{i,m}` and :math:`E_{j,n}` to compute the probability.

  Move In/Out
    EllipTrack assumes that ellipses enter/leave the field of view by migrating from/to the nearest border.
    By modeling this process with a one-dimensional Random Walk, EllipTrack computes this probability by 
    
    .. math::

       P(E_{i,m}) = \frac{1}{\sqrt{2\pi\sigma^2}}\exp\left\{-\frac{\Delta s^2}{2\sigma^2}\right\}.
    
    Here, :math:`\Delta s` is the distance between the ellipse centroid and its nearest border; and :math:`\sigma` is the standard deviation of random walk as defined in **Migration**.
    
Cell Track
----------

The probability of a cell track is defined as the product of the probabilities of morphological events in each ellipse and the probabilities of migration events between ellipses.

For the lineage tree in :numref:`sample_lineage_tree`, the probabilities of the cell tracks are

.. math::

   \begin{align}
     P(\mathrm{Cell\ Track\ 1}) =& P(E_{1,1}\ \mathrm{one\ cell})P(E_{1,1}\ \mathrm{mitotic}) \\
                                 & P(E_{1,1}\ \mathrm{not\ newly\ born})P(E_{1,1}\ \mathrm{not\ apoptotic}) \\
     P(\mathrm{Cell\ Track\ 2}) =& P(E_{2,1}\ \mathrm{one\ cell})P(E_{2,1}\ \mathrm{not\ mitotic}) \\
                                 & P(E_{2,1}\ \mathrm{newly\ born})P(E_{2,1}\ \mathrm{not\ apoptotic}) \cdots \\
                                 & P(E_{5,1}\ \mathrm{one\ cell})P(E_{5,1}\ \mathrm{not\ mitotic}) \\
                                 & P(E_{5,1}\ \mathrm{not\ newly\ born})P(E_{5,1}\ \mathrm{not\ apoptotic}) \\
                                 & P(E_{2,1}\rightarrow E_{3,1})P(E_{3,1}\rightarrow E_{4,1})P(E_{4,1}\rightarrow E_{5,1}) \\
     P(\mathrm{Cell\ Track\ 3}) =& P(E_{2,2}\ \mathrm{one\ cell})P(E_{2,2}\ \mathrm{not\ mitotic}) \\
                                 & P(E_{2,2}\ \mathrm{newly\ born})P(E_{2,2}\ \mathrm{not\ apoptotic}) \cdots \\
                                 & P(E_{4,2}\ \mathrm{one\ cell})P(E_{4,2}\ \mathrm{not\ mitotic}) \\
                                 & P(E_{4,2}\ \mathrm{not\ newly\ born})P(E_{4,2}\ \mathrm{apoptotic}) \\
                                 & P(E_{2,2}\rightarrow E_{3,1})P(E_{3,1}\rightarrow E_{4,2})
   \end{align}  

where :math:`P(E_{1,1}\ \mathrm{not\ newly\ born}) = 1 - P(E_{1,1}\ \mathrm{newly\ born})` and similar for other terms.

Lineage Tree
------------

The probability of a cell lineage tree is defined by the product of the probabilities of the cell tracks and the migration probabilities between mitotic cells and newly born cells.

For the lineage tree in :numref:`sample_lineage_tree`, the probability of the lineage tree is

.. math::

   \begin{align}
     P(\mathrm{Lineage\ Tree}) =& P(\mathrm{Cell\ Track\ 1})P(\mathrm{Cell\ Track\ 2})P(\mathrm{Cell\ Track\ 3}) \\
                               & P(E_{1,1}\rightarrow E_{2,1})P(E_{1,1}\rightarrow E_{2,2})
   \end{align}

Construction of Cell Tracks
===========================

EllipTrack implements a Dynamic Programming algorithm (Magnusson *et al.* 2015) to construct cell tracks.
In brief, EllipTrack repeatedly constructs a new cell track by searching for the one increasing the probability of the existing lineage trees by the greatest folds.
This procedure terminates when a pre-defined number of cell tracks (defined by :greenitalic:`max_num_tracks`) has been constructed, 
or when the fold-change of the probability by adding the new cell track is below a pre-defined threshold (defined by :greenitalic:`min_track_score`).

Calculation of Fold Change
--------------------------

To illustrate how a new cell track alters the probability of cell lineage trees, consider the lineage tree in :numref:`sample_lineage_tree2`.

.. _sample_lineage_tree2:

.. figure:: _static/images/track_lineage_example2.png
   :width: 600
   :align: center
   
   Example lineage tree for fold-change calculation.

The lineage trees originally contains a single cell track :math:`E_{1,1}\rightarrow E_{2,1}\rightarrow E_{3,1}\rightarrow E_{4,1}`. 
The probability is

.. math::

   \begin{align}
     P(\mathrm{before}) \propto& P(E_{2,1}\ \mathrm{one\ cell})P(E_{1,2}\ \mathrm{no\ cell})P(E_{3,2}\ \mathrm{no\ cell}) \\
                               & P(E_{1,2}\not\to E_{2,1}) P(E_{2,1}\not\to E_{3,2}) P(E_{3,2}\ \mathrm{not\ apoptotic})
   \end{align}

where :math:`P(E_{1,2}\not\to E_{2,1}) = 1 - P(E_{1,2}\to E_{2,1})` and :math:`P(E_{2,1}\not\to E_{3,2}) = 1 - P(E_{2,1}\to E_{3,2})`.

After adding a new cell track :math:`E_{1,2}\rightarrow E_{2,1}\rightarrow E_{3,2}\not\to`, the probability of the cell lineage trees becomes

.. math::
   
   \begin{align}
      P(\mathrm{after}) \propto& P(E_{2,1}\ \mathrm{two\ cells})P(E_{1,2}\ \mathrm{one\ cell})P(E_{3,2}\ \mathrm{one\ cell}) \\
                               & P(E_{1,2}\rightarrow E_{2,1}) P(E_{2,1}\rightarrow E_{3,2}) P(E_{3,2}\ \mathrm{apoptotic})
   \end{align}

The fold-change of probabilities can be then calculated by

.. math::

   \begin{align}
     \frac{P(\mathrm{after})}{P(\mathrm{before})} =& \frac{P(E_{2,1}\ \mathrm{two\ cells})}{P(E_{2,1}\ \mathrm{one\ cell})} \frac{P(E_{1,2}\ \mathrm{one\ cell})}{P(E_{1,2}\ \mathrm{no\ cell})} \frac{P(E_{3,2}\ \mathrm{one\ cell})}{P(E_{3,2}\ \mathrm{no\ cell})} \\
                                                   & \frac{P(E_{1,2}\rightarrow E_{2,1})}{P(E_{1,2}\not\to E_{2,1})} \frac{P(E_{2,1}\rightarrow E_{3,2})}{P(E_{2,1}\not\to E_{3,2})} \frac{P(E_{3,2}\ \mathrm{apoptotic})}{P(E_{3,2}\ \mathrm{not\ apoptotic})}
   \end{align}

.. admonition:: Conversion to Scores

   To avoid working with numbers below machine precision, EllipTrack converts probabilities of events to scores as follows

   .. math::

      C(\mathrm{New\ Event}) = \ln P(\mathrm{New\ Event}) - \ln P(\mathrm{Old\ Event})
   
   For example, the score for changing from ":math:`E_{3,2}\ \mathrm{not\ apoptotic}`" to ":math:`E_{3,2}\ \mathrm{apoptotic}`" is defined by

   .. math::
      
      \begin{align}
          & C(E_{3,2}\ \mathrm{apoptotic}) \\
        = & \ln P(E_{3,2}\ \mathrm{apoptotic}) - \ln P(E_{3,2}\ \mathrm{not\ apoptotic})
      \end{align}

   Similarily, EllipTrack defines the score of a cell track by the logarithm of its fold-change to the probability of cell lineage trees (:math:`C=\ln P(\mathrm{after}) - \ln P(\mathrm{before})`). 
   For example, the score of the new cell track in :numref:`sample_lineage_tree2` can be expressed as

   .. math::

      \begin{align}
        C =& C(E_{2,1}\ \mathrm{two\ cells}) + C(E_{1,2}\ \mathrm{one\ cell}) + C(E_{3,2}\ \mathrm{one\ cell}) \\
           & + C(E_{1,2}\rightarrow E_{2,1}) + C(E_{2,1}\rightarrow E_{3,2}) + C(E_{3,2}\ \mathrm{apoptotic})
      \end{align}

Mitosis
-------

EllipTrack detects mitosis events by examining whether the first ellipse of a new cell track is likely to represent a newly born cell or not.
If so and there exists a cell track with a high probability of being a newly born cell in this frame and a high probability of being a mitotic cell in the previous frame, EllipTrack will create a mitosis event. 
To be precise, EllipTrack will split the existing cell track into two: one for mother (up to the previous frame) and the other for daughter (from this frame).
Both the new cell track and the daughter track will be recorded as the daughters of the mother track.
Meanwhile, if the first ellipse of the new cell track is likely to enter the field of view via a **Move In** event, no mitosis events will be created.

To illustrate this procedure, consider the lineage tree in :numref:`sample_lineage_tree3` which contains one cell track :math:`E_{1,1}\rightarrow E_{2,1}\rightarrow E_{3,1}\rightarrow E_{4,1}` originally.

.. _sample_lineage_tree3:

.. figure:: _static/images/track_lineage_example3.png
   :width: 600
   :align: center
   
   Example lineage tree for mitosis detection.

A new cell track :math:`E_{3,2}\rightarrow E_{4,2}` is created. 
If the first ellipse (:math:`E_{3,2}`) enters the field of view via a **Move In** event, the score of the new cell track is

.. math::

   \begin{align}
     C_1 =& C(E_{3,2}\ \mathrm{one\ cell}) + C(E_{4,2}\ \mathrm{one\ cell}) \\
          & C(E_{3,2}\ \mathrm{move\ in}) + C(E_{3,2}\rightarrow E_{4,2})
   \end{align}

Meanwhile, if :math:`E_{3,2}` is a newly born cell whose mother and sister are :math:`E_{2,1}` and :math:`E_{3,1}`, the score of the new cell track is

.. math::

   \begin{align}
     C_2' =& C(E_{3,2}\ \mathrm{one\ cell}) + C(E_{4,2}\ \mathrm{one\ cell}) \\
          & C(E_{3,2}\ \mathrm{newly\ born}) + C(E_{3,2}\rightarrow E_{4,2})
   \end{align}

In addition, a mitosis event leads to :math:`E_{2,1}` being a mitotic cell, :math:`E_{3,1}` being a newly born cell, and :math:`E_{2,1}` migrating to :math:`E_{3,2}`.
Therefore, the total score is

.. math::

   C_2 = C_2' + C(E_{2,1}\ \mathrm{mitotic}) + C(E_{3,1}\ \mathrm{newly\ born}) + C(E_{2,1}\rightarrow E_{3,2})

If :math:`C_2 > C_1`, EllipTrack will split the existing cell track into two (Track 1: :math:`E_{1,1}\rightarrow E_{2,1}`, Track 2: :math:`E_{3,1}\rightarrow E_{4,1}`), 
name the new cell track as Track 3, and assign both Track 2 and Track 3 as the daughters of Track 1.
Meanwhile, if :math:`C_1 \geq C_2`, no mitosis events will be created.

Post-Processing
===============

EllipTrack implements a four-step procedure to correct tracking mistakes: correction of track swaps due to under-segmentation,
comprehensive examination and correction of track swaps, identification of undetected mitosis events, and removal of invalid cell tracks.

First, EllipTrack examines whether cell tracks are incorrectly mapped due to under-segmentation.
Since the Dynamic Programming algorithm is memoryless, EllipTrack loses cell identities when multiple cell tracks are mapped to the same ellipse.
Consequently, EllipTrack randomly maps the cell tracks to the cells when they are no longer under-segmented.
For example, consider the lineage trees in :numref:`sample_lineage_tree4`. 
EllipTrack loses the identities of the blue and green cells at Frame 2, and therefore randomly maps the cell tracks to the ellipses in Frame 4, which leads to 50% of mappings being incorrect.

.. _sample_lineage_tree4:

.. figure:: _static/images/track_lineage_example4.png
   :width: 400
   :align: center

   Example lineage tree for post-processing

To correct these mistakes, EllipTrack examines the migration probabilities between ellipses before and after under-segmentation 
and maps the cell tracks in the order with greater probabilities.
For example, in :numref:`sample_lineage_tree4`, EllipTrack compares the scores :math:`C(E_{1,1}\rightarrow E_{4,1}) + C(E_{1,2}\rightarrow E_{4,2})` and :math:`C(E_{1,1}\rightarrow E_{4,2}) + C(E_{1,2}\rightarrow E_{4,1})`.
If the former score is greater, EllipTrack maps the blue cell track to :math:`E_{4,1}` and maps the green cell track to :math:`E_{4,2}`. 
Meanwhile, if the latter score is greater, EllipTrack maps these two cell tracks in the opposite order.

Second, EllipTrack systematically examines every two cell tracks between every two neighboring frames.
Two cell tracks will be swapped if this swap increases the score of cell lineage trees by at least :greenitalic:`min_swap_score`.

Third, EllipTrack identifies previously undetected mitosis events by searching for non-daughter cell tracks whose first ellipse has a high probability of being a newly born cell (greater than or equal to :greenitalic:`fixation_min_prob_after_mitosis`).
For each such non-daughter cell track, EllipTrack examines whether there exists a nearby cell track (no more than ``migration_sigma * max_migration_distance_fold`` pixels away)
which has a high probability of being a mitotic cell in the previous frame (greater than or equal to :greenitalic:`fixation_min_prob_before_mitosis`) 
and a high probability of being a newly born cell in the current frame (greater than or equal to :greenitalic:`fixation_min_prob_after_mitosis`).
If found, EllipTrack creates a mitosis event between this nearby cell track and the non-daughter cell track.

Finally, EllipTrack removes all cell tracks shorter than :greenitalic:`min_track_length` frames and all cell tracks skipping more than :greenitalic:`max_num_frames_to_skip` frames.
Mitosis associated with these invalid cell tracks will be removed as well.

Parameters
**********

*track_para* consists of four types of parameters:

*  **Predict Probabilities**. Parameters for computing event probabilities.
*  **Construct Cell Tracks**. Parameters for constructing cell tracks.
*  **Post-Processing**. Parameters for post-processing.
*  **Visualization**. Parameters for visualization.

.. _parameters_track_linking_predict:

Predict Probabilities
=====================

*  :reditalic:`training_data_path`. Paths to the training datasets.

   This parameter should be formatted in the same fashion as the namesake in :ref:`parameters_segmentation_correction` of :ref:`parameters_segmentation_Page`.

*  :greenitalic:`empty_prob`. Probability of an event (between 0 and 1) if no training samples are provided.
*  :blueitalic:`if_switch_off_before_mitosis`. Indicator variable of whether to ignore the probability of being an mitotic cell (Before M) during mitosis detection.
*  :greenitalic:`if_switch_off_after_mitosis`. Indicator variable of whether to ignore the probability of being a newly born cell (After M) during mitosis detection.
*  :greenitalic:`if_similarity_for_migration`. Indicator variable of whether to consider ellipse similarity when computing migration probabilities.
*  :blueitalic:`migration_sigma`. Standard deviation (in pixels) of random walk in one frame and one direction. If NaN is chosen, the value will be inferred from the training datasets.
*  :greenitalic:`max_migration_distance_fold`. Maximal distances (expressed as folds of :blueitalic:`migration_sigma`) an ellipse can travel in one frame and one direction. 
*  :greenitalic:`likelihood_nonmigration`. Null probability (between 0 and 1) for migration.
*  :greenitalic:`min_inout_prob`. Minimal probability (between 0 and 1) of migrating in/out of the field of view.
*  :greenitalic:`max_gap`. Maximal gap (in frames) of migration. Gap = number of frames to skip + 1.

Construct Cell Tracks
=====================

*  :greenitalic:`skip_penalty`. Penalty score for skipping one frame.
*  :greenitalic:`multiple_cells_penalty`. Penalty score for two cells co-existing in one ellipse.
*  :greenitalic:`min_mitosis_prob`. Minimal probability (between 0 and 1) of mitotic and newly born cells for mitosis detection.
*  :greenitalic:`max_num_tracks`. Maximal number of tracks to construct.
*  :greenitalic:`min_track_score`. Minimal score of a track.
*  :greenitalic:`min_track_score_per_step`. Minimal score of a track between two neighboring frames.
*  :greenitalic:`max_recorded_link`. For each ellipse, maximal number of migration events to keep. 

Post-Processing
===============

*  :greenitalic:`min_swap_score`. Minimal score for swapping cell tracks.
*  :greenitalic:`fixation_min_prob_before_mitosis`. Minimal probability of mitotic cells (Before M) for mitosis detection.
*  :greenitalic:`fixation_min_prob_after_mitosis`. Minimal probability of newly born cells (After M) for mitosis detection.
*  :greenitalic:`min_track_length`. Minimal length (in frames) of a valid track.
*  :greenitalic:`max_num_frames_to_skip`. Maximal number of frames a valid track can skip.

Visualization
=============

*  :reditalic:`if_print_vistrack`. Indicator variable of whether to generate "Vistrack Movies" where fitted ellipses are overlaid on the nuclear images and Cell Track IDs are displayed next to the ellipses they mapped to (similar to Figure 1H).
*  :reditalic:`vistrack_path`. Path to the folder storing "Vistrack Movies".
