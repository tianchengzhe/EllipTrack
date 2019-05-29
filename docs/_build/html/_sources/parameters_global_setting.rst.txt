.. include:: .special.rst

.. _parameters_global_setting_Page:

==============
Global Setting
==============

*  :reditalic:`nuc_raw_image_path`. Path to the folder containing images of the nuclear channel.
*  :reditalic:`nd2_frame_range`. Range of frames each ND2 file stores. 

   TIFF Format
     EllipTrack assumes that all images of a channel should be stored in the same folder, though images of different channels can be stored in different folders.

     :reditalic:`nuc_raw_image_path` should be a string specifying the path to the folder containing the images of the nuclear channel. 
     :reditalic:`nd2_frame_range` should be empty.

     .. admonition:: Example
        :class: hint

        A movie is stored in the TIFF format, and all the images of the nuclear channel are located in the folder ``X:/tracking_code/raw_images/``.
        The values of the parameters are

        .. code-block:: matlab

           nuc_raw_image_path = 'X:/tracking_code/raw_images/';
           nd2_frame_range = [];

   ND2 Format
     EllipTrack allows a movie to be stored in multiple folders, though the filenames of ND2 files should start with *WellXYY* where *XYY* is an alphanumerical identifier for the coordinates of the well in a multi-well plate.
     For example, consider a movie where cells are imaged in Well A03 (Row 1, Column 3) for 24 hrs. The movie is then paused for drug addition and cells are subsequently imaged for another 24 hrs. 
     The movie will be stored in two ND2 files in two separate folders: the first folder contains the images for the first 24 hrs, and the second folder contains the images for the latter 24 hrs.
     The filenames of both ND2 files will start with *WellA03*.

     If a movie is stored in *n* folders, :reditalic:`nuc_raw_image_path` should be an *n x 1* cell array where each row is a string specifying the path to a folder.
     :reditalic:`nd2_frame_range` should be an *n x 2* matrix where each row stores the start and end frame IDs of the folder.

     .. admonition:: Example
        :class: hint

        A movie is stored in two ND2 files. 
        The first file is located in the folder ``X:/tracking_code/raw_images/folder1/`` and contains the images from frame 1 to frame 92.
        The second file is located in the folder ``X:/tracking_code/raw_images/folder2/`` and contains the images from frame 93 to frame 180.
        The values of the parameters are 

        .. code-block:: matlab

           nuc_raw_image_path = {'X:/tracking_code/raw_images/folder1/';
                                 'X:/tracking_code/raw_images/folder2/'};
           nd2_frame_range = [1, 92;
                              93, 180];
     
     .. admonition:: Remark

        If the movie is stored in a single ND2 file, :reditalic:`nuc_raw_image_path` should still be a cell array.
        A common mistake is to forget adding *{}*, resulting in :reditalic:`nuc_raw_image_path` being a string.

        **Example**. The ND2 file is located in ``X:/tracking_code/raw_images/`` and contains the images from frame 1 to frame 100.
        The values of the parameters are 

        .. code-block:: matlab

           nuc_raw_image_path = {'X:/tracking_code/raw_images/'};
           nd2_frame_range = [1, 100];

.. admonition:: Formatting the Path 

   In order to maintain cross-platform compatibility, EllipTrack requires that all paths use forward slashes (/) rather than backward slashes (\\).
   In addition, paths to folders should end with a forward slash.

   Example 1. Path to a folder.
     **Incorrect format**. Use backward slashes rather than forward slashes; no forward slash at the end of the path.
     
     .. code-block:: matlab
    
        path = 'X:\tracking_code\raw_images';
    
     **Correct format**.

     .. code-block:: matlab

        path = 'X:/tracking_code/raw_images/';

   Example 2. Path to an MAT file.
     **Incorrect format**. Use backward slashes rather than forward slashes; use forward slash at the end of the path.

     .. code-block:: matlab

        path = 'X:\tracking_code\mat_files\cmosoffset.mat/';

     **Correct format**.

     .. code-block:: matlab

        path = 'X:/tracking_code/mat_files/cmosoffset.mat';
   
   A function *adjust_path* (defined at the end of *parameters.m*) is applied to every path to correct possible mistakes. Though formatting the paths manually is strongly suggested.

*  :reditalic:`valid_wells`: Movies being tracked.

  If *n* movies are tracked, :reditalic:`valid_wells` should be an *n x 3* matrix where each row specifies the *RowID*, *ColumnID*, and *SiteID* of a movie.

  .. admonition:: Example
     :class: hint

     Two movies are tracked. The first movie is captured in Site 3 of Well A02, and the second movie is captured in Site 6 of Well D05. 
     The value of the parameter is

     .. code-block:: matlab

        valid_wells = [1, 2, 3;
                       4, 5, 6];

  .. admonition:: Remark

     One may use the function `allcomb` to create combinatorial combinations. For example, if all movies from a 96-well plate (2 sites/well) are tracked, the value of the parameter can be set by

     .. code-block:: matlab
    
        valid_wells = allcomb(1:8, 1:12, 1:2);

*  :reditalic:`cmosoffset_path`: Path to the MAT file storing the camera dark noises (CMOS Offset).
*  :reditalic:`bias_path`: Path to the MAT file storing the illumination bias (Bias) of the nuclear channel.
*  :reditalic:`all_frames`: Frames to track.

  :reditalic:`all_frames` should be a numeric vector containing the frame IDs to track.

  .. admonition:: Example
     :class: hint

     To track from Frame 1 to Frame 100, set the parameter value to
     
     .. code-block:: matlab

        all_frames = 1:100;

     The IDs do not need to be consecutive. For example, 
     
     .. code-block:: matlab

        all_frames = 1:2:99;

     indicates that every second image from Frame 1 to Frame 99 will be tracked.

*  :reditalic:`nuc_signal_name`: Name of the nuclear channel.
*  :reditalic:`nuc_biomarker_name`: Name of the measured nuclear marker.

  .. admonition:: Example
     :class: hint

     Cells are tagged with an H2B-CFP marker. The values of the parameters should be

     .. code-block:: matlab
    
        nuc_signal_name = 'CFP';
        nuc_biomarker_name = 'H2B';

     Furthermore, if the images are stored in the TIFF format, the filenames of the nuclear images should follow the format 

     ::

        RowID_ColID_SiteID_CFP_FrameID.tif

*  :greenitalic:`if_global_correction`: Indicator variable of whether to perform global jitter correction. 

  A value of 1 indicates that the global jitter correction will be performed, and a value of 0 indicates that the local jitter correction will be performed.

  Note that global jitter correction requires that :reditalic:`valid_wells` contains at least six distinct wells. Otherwise, local jitter correction will be performed even if :greenitalic:`if_global_correction` is set to 1.

.. admonition:: Indicator Variables

   Unless specified, indicator variables always take a value of either 1 or 0, where 1 means that the indicated event occurs, and 0 means otherwise.

*  :reditalic:`output_path`: Path to the folder storing the outputs.