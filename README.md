# EllipTrack

EllipTrack is a new global-local hybrid cell tracker optimized for tracking modern large-scale movies. The key innovation of EllipTrack is the introduction of a local track correction module, which systematically corrects the tracking mistakes of the global track linking algorithm from Magnusson and colleagues. Benchmark reveals that EllipTrack outperforms the existing state-of-the-art cell trackers and can identify nearly error-free cell lineages from multiple large-scale movies.

## System Requirement

* Hardware: A modern computer, at least 8GB RAM.

* Software: MATLAB (Mathworks), R2017a or later.

  Required toolboxes: System Identification Toolbox, Image Processing Toolbox, Computer Vision Toolbox, Statistics and Machine Learning Toolbox, Parallel Computing Toolbox, and MATLAB Distributed Computing Server.

  A C++ compiler in MATLAB with C++11 support. Install a free minGW compiler [here](<https://www.mathworks.com/matlabcentral/answers/313290-how-do-i-install-mingw-for-use-in-matlab>).

## Installation

* Download EllipTrack: Click "Clone or download" on the top of this page, select "Download ZIP", and extract files.

* Compile *generate_tracks.cpp*: Navigate MATLAB to the *functions/track_linking* folder, and execute

  ```matlab
  mex -largeArrayDims generate_tracks.cpp
  ```

* Install BioformatsImage: Follow the instruction [here](https://biof-git.colorado.edu/biofrontiers-imaging/bioformats-image-toolbox/wikis/home).

## Documentation

Documentation is available [here](<http://elliptrack.readthedocs.org/>).

