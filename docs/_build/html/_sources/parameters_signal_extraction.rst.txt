.. include:: .special.rst

.. _parameters_signal_extraction_Page:

=================
Signal Extraction
=================

Overview
********

*signal_extraction_para* consists of two types of parameters:

*  **Signal Channels**. Parameters defining the signal channels, i.e. all channels other than the nuclear channel.
*  **ROI**. Parameters defining the regions of interest for signal extraction.

Signal Channels
***************

*  :reditalic:`additional_signal_names`: Names of the signal channels.
*  :reditalic:`additional_biomarker_names`: Names of the measured markers in the signal channels.

  For a movie with *n* signal channels, both :reditalic:`additional_signal_names` and :reditalic:`additional_biomarker_names` should be an *n x 1* cell array where each row stores a channel name and a biomarker name, respectively.

  .. admonition:: Example
     :class: hint
     
     A movie has 3 channels: *CFP* for the nuclear marker, *mCherry* for the CDK2 sensor, and *YFP* for the ERK sensor. 
     The values of the parameters should be

     .. code-block:: matlab

        additional_signal_names = {'mCherry';
                                   'YFP'};
        additional_biomarker_names = {'CDK2';
                                      'ERK'};
    
  .. admonition:: Remark
     
     Use empty cell array if a movie has no signal channels.

     .. code-block:: matlab

        additional_signal_names = {};
        additional_biomarker_names = {};

*  :reditalic:`additional_raw_image_paths`: Paths to the folders containing images of the signal channels.

  TIFF Format
    For a movie with *n* signal channels, :reditalic:`additional_raw_image_paths` should be an *n x 1* cell array where each row is a string specifying the path to the folder containing the images of one signal channel.

    .. admonition:: Example
       :class: hint

       A movie has 3 channels: *CFP* for the nuclear marker, *mCherry* for the CDK2 sensor, and *YFP* for the ERK sensor. 
       The movie is stored in the TIFF format. The images of the *mCherry* channnel are located in ``X:/tracking/raw_images/mCherry/``, and the images of the *YFP* channel are located in ``X:/tracking/raw_images/YFP/``.
       The value of the parameter should be

       .. code-block:: matlab

          additional_raw_image_paths = {'X:/tracking/raw_images/mCherry/';
                                        'X:/tracking/raw_images/YFP/'};

  ND2 Format
    For a movie with *n* signal channels, :reditalic:`additional_raw_image_paths` should be an *n x 1* cell array where each row has the same content as :reditalic:`nuc_raw_image_path` in *global_setting*.

    .. admonition:: Example
       :class: hint

       A movie has 3 channels: *CFP* for the nuclear marker, *mCherry* for the CDK2 sensor, and *YFP* for the ERK sensor. 
       The movie is stored in two ND2 files in two separate folders. 
       The first file is located in ``X:/tracking/raw_images/folder1/``, and the second file is located in ``X:/tracking_raw_images/folder2/``.
       The value of the parameter should be

       .. code-block:: matlab

          additional_raw_image_paths = {{'X:/tracking/raw_images/folder1/';
                                         'X:/tracking/raw_images/folder2/'};
                                        {'X:/tracking/raw_images/folder1/';
                                         'X:/tracking/raw_images/folder2/'}};
       
       Or simply use the following script to set the parameter value automatically.

       .. code-block:: matlab

          additional_raw_image_paths = cell(length(additional_signal_names), 1);
          additional_raw_image_paths(:) = {global_setting.nuc_raw_image_path};

*  :reditalic:`additional_bias_paths`: Paths to the MAT files storing the illumination bias of the signal channels.

  For a movie with *n* signal channels, :reditalic:`additional_bias_paths` should be an *n x 1* cell array where each row stores the path to the illumination bias of one signal channel.

  .. admonition:: Example
     :class: hint

       A movie has 3 channels: *CFP* for the nuclear marker, *mCherry* for the CDK2 sensor, and *YFP* for the ERK sensor. 
       Illumination bias of the *mCherry* channel is stored in ``X:/tracking/mat_files/mCherry.mat``, and illumination bias of the *YFP* channel is stored in ``X:/tracking/mat_files/YFP.mat``.
       The value of the parameter should be

       .. code-block:: matlab

          additional_bias_paths = {'X:/tracking/mat_files/mCherry.mat';
                                   'X:/tracking/mat_files/YFP.mat'};

.. admonition:: Do Not Forget to Add "{}"

   EllipTrack requires the parameters to be organized in their correct data structures. 
   A common mistake is to forget adding the necessary "{}", especially when a movie only contains one signal channel.

   **Example 1**. A movie has 3 channels: *CFP* for the nuclear marker, *mCherry* for the CDK2 sensor, and *YFP* for the ERK sensor.
   The movie is stored in the TIFF format, and all the images are located in the folder ``X:/tracking/raw_images/``. 
   The correct value of :reditalic:`additional_raw_image_paths` is 

   .. code-block:: matlab

      additional_raw_image_paths = {'X:/tracking/raw_images/';
                                    'X:/tracking/raw_images/'};

   The first row is for the *mCherry* channel and the second row is for the *YFP* channel.

   **Example 2**. A movie has 3 channels: *CFP* for the nuclear marker, *mCherry* for the CDK2 sensor, and *YFP* for the ERK sensor.
   The movie is stored in one ND2 file located in ``X:/tracking/raw_images/``.
   The correct value of :reditalic:`additional_raw_image_paths` is 

   .. code-block:: matlab

      additional_raw_image_paths = {{'X:/tracking/raw_images/'};
                                    {'X:/tracking/raw_images/'}};

   Each row should be an cell array, even when the movie is stored in one folder.

   **Example 3**. A movie has 2 channels: *CFP* for the nuclear marker and *mCherry* for the CDK2 sensor.
   The movie is stored in the TIFF format.
   All the images are located in the folder ``X:/tracking/raw_images/``.
   Illumination bias of the *mCherry* channel is stored in ``X:/tracking/mat_files/mCherry.mat``.
   The correct values of the parameters are

   .. code-block:: matlab

      additional_signal_names = {'mCherry'};
      additional_biomarker_names = {'CDK2'};
      additional_raw_image_paths = {'X:/tracking/raw_images/'};
      additional_bias_paths = {'X:/tracking/mat_files/mCherry.mat'};

   All parameters should be cell arrays, even if the movie only contains one signal channel.

   **Example 4**. A movie has 2 channels: *CFP* for the nuclear marker and *mCherry* for the CDK2 sensor.
   The movie is stored in one ND2 file located in the folder ``X:/tracking/raw_images/``.
   The correct value of :reditalic:`additional_raw_image_paths` is

   .. code-block:: matlab

      additional_raw_image_paths = {{'X:/tracking/raw_images/'}};
   
   The outer "{}" is for signal channels, and the inner "{}" is for folders.

   **Example 5**. A movie has only one channel: *CFP* for the nuclear marker.
   The correct values of the parameters are

   .. code-block:: matlab

      additional_signal_names = {};
      additional_biomarker_names = {};
      additional_raw_image_paths = {};
      additional_bias_paths = {};

   All parameters should be empty cell arrays.   

*  :reditalic:`if_compute_cyto_ring`. Indicator variables of whether to extract the signals in the cytoplasmic ring.

  For a movie with *n* signal channels, :reditalic:`if_compute_cyto_ring` should be an *n x 1* array where each row stores the indicator variable for one signal channel.

  .. admonition:: Example
     :class: hint

     A movie has 3 channels: *CFP* for the nuclear marker, *mCherry* for the CDK2 sensor, and *YFP* for the FIRE sensor.
     The CDK2 sensor is a kinase translocation sensor, and calculation of CDK2 activities requires the signals in both the nucleus and the cytopasmic ring.
     Meanwhile, the FIRE sensor is a nuclear sensor, and calculation of FIRE activities requires only the signal in the nucleus.
     The value of the parameter should be

     .. code-block:: matlab

        if_compute_cyto_ring = [1,
                                0];

ROI
***

Definitions of ROIs are illustrated in :numref:`para_signal_extraction`.

.. _para_signal_extraction:

.. figure:: _static/images/para_signal_extraction.png
   :width: 300
   :align: center

   Schematic diagram of ROI definition.

Since ellipse contours may not match the nuclear contour accurately, EllipTrack discards the pixels surrounding the ellipse contour (white region) from signal calculation.
Consequently, the region of nucleus is defined by the pixels inside and at least :greenitalic:`nuc_outer_size` pixels away from the nuclear contour.
The region of cytoplasmic ring is defined by the pixels outside and between :greenitalic:`cyto_ring_inner_size` and :greenitalic:`cyto_ring_outer_size` pixels away from the nuclear contour.

For each ROI, EllipTrack first performs background subtraction by subtracting the pixel intensities with the average intensity of the image background.
Here, the image background is defined by pixels at least :greenitalic:`foreground_dilation_size` pixels away from any nucleus.
EllipTrack then removes the outlier intensities in each ROI by keeping only the intensities between :greenitalic:`lower_percentile` and :greenitalic:`higher_percentile` percentiles.
Finally, EllipTrack computes the mean and :greenitalic:`intensity_percentile` percentile intensity of the region.

*  :greenitalic:`cyto_ring_inner_size`: Minimal distance (in pixels) between the region of cytoplasmic ring and the ellipse contour.
*  :greenitalic:`cyto_ring_outer_size`: Maximal distance (in pixels) between the region of cytoplasmic ring and the ellipse contour.
*  :greenitalic:`nuc_outer_size`: Minimal distance (in pixels) between the region of nucleus and the ellipse contour.
*  :greenitalic:`foreground_dilation_size`: Minimal distance (in pixels) between the image background and a nucleus.
*  :greenitalic:`intensity_percentile`: Measured percentile (between 0 and 100) of each region.
*  :greenitalic:`lower_percentile`: Lower percentile (between 0 and 100) of intensities to keep.
*  :greenitalic:`higher_percentile`: Higher percentile (between 0 and 100, greater than :greenitalic:`lower_percentile`) to keep.
