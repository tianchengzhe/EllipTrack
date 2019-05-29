.. include:: .special.rst

.. _parameters_overview_Page:

==========
Overview
==========

Organization of Parameters
**************************

Parameters are organized into four Matlab structures (*struct*) by the modules where they are used:

*  *global_setting*. Parameters used by all modules. Refer to :ref:`parameters_global_setting_Page`.
*  *segmentation_para*. Parameters for Segmentation. Refer to :ref:`parameters_segmentation_Page`.
*  *track_para*. Parameters for Track Linking. Refer to :ref:`parameters_track_linking_Page`.
*  *signal_extraction_para*. Parameters for Signal Extraction. Refer to :ref:`parameters_signal_extraction_Page`.

Parameter values can be accessed by the dot (.) operator.
For example, the path to the folder storing the images of the nuclear channel is specified by the parameter *nuc_raw_image_path* in the *global_setting* structure.
One may use the command ``global_setting.nuc_raw_image_path`` to access the value of this parameter.

Parameter Importance
********************

Parameters are classified into three categories by their importance to the tracking performance.

*  :redbold:`Essential`. Parameters specifying inputs and outputs, and parameters with a critical impact on the tracking performance. 
   Users should determine the parameter values carefully.
*  :bluebold:`Important`. Parameters with a significant impact on tracking performance.
   Users can tune the parameter values to improve the tracking performance significantly, though the default values usually work.
*  :greenbold:`Optional`. Parameters with a relatively less impact on the tracking performance.
   Users can generally use the default parameter values.
