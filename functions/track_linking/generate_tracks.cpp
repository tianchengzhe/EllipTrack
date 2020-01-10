// generate_tracks.cpp
// C++ version of generate_tracks.m
// Perform dynamical programming algorithm to find the best cell tracks in the movie
// Based on Magnusson, et al, Global Linking of Cell Tracks Using the Viterbi Algorithm,
// IEEE Transactions on Medical Imaging, 34(4): 911-929 (2015)
// as well as Sam Cooper's NucliTrack program.
//
// Last Update: 2017.10.12, 18.11
// All errors should be resolved. Need to accelerate the algorithm.
// Recorded version: 20171013

#include <algorithm>
#include <numeric>
#include <iostream>
#include "mex.h"
#include "matrix.h"
#include <string>
#include <vector>
#include <cmath>
#include <limits>

// Define a default NaN value for int type, because there is no universal NaN in C++
// This value should be negative, as all valid values for the int vectors are positive
#define NaN_int -100
// For double type, just use the built-in NaN function
#define NaN_double std::numeric_limits<double>::quiet_NaN()
#define Inf_double std::numeric_limits<double>::infinity()
#define Inf_int std::numeric_limits<int>::max()
#define max_recorded_link 5

// Define a class to describe a frame during the construction of state space diagram
// corresponding to the new_frame struct in matlab script
class Frame {
public:
    // constructor
    Frame() {}
    
    Frame(int num_entries) :
    current_score(std::vector<double>(num_entries, NaN_double)),
    previous_id(std::vector<int>(num_entries, NaN_int)),
    gap_to_previous_id(std::vector<int>(num_entries, NaN_int)),
    mitosis_track_id(std::vector<int>(num_entries, NaN_int)),
    if_apoptosis(std::vector<int>(num_entries, NaN_int)),
    swap_track_id(std::vector<int>(num_entries, NaN_int)),
    migration_link_id(std::vector<int>(num_entries, NaN_int)),
    swap_new_to_old_id(std::vector<int>(num_entries, NaN_int)),
    swap_old_to_new_id(std::vector<int>(num_entries, NaN_int)) {}
    
    // copy constructor
    Frame(const Frame& copy_instance):
    current_score(copy_instance.current_score),
    previous_id(copy_instance.previous_id),
    gap_to_previous_id(copy_instance.gap_to_previous_id),
    mitosis_track_id(copy_instance.mitosis_track_id),
    if_apoptosis(copy_instance.if_apoptosis),
    swap_track_id(copy_instance.swap_track_id),
    migration_link_id(copy_instance.migration_link_id),
    swap_new_to_old_id(copy_instance.swap_new_to_old_id),
    swap_old_to_new_id(copy_instance.swap_old_to_new_id) {}
    
    // values
    std::vector<double> current_score; // current best score at this detection
    std::vector<int> previous_id; // point to the previous detection which gives it the best score
    std::vector<int> gap_to_previous_id; // frame ID difference to the previous detection
    std::vector<int> mitosis_track_id; // whether this cell will undergo mitosis
    std::vector<int> if_apoptosis; // whether this cell will undergo apoptosis
    std::vector<int> swap_track_id; // point to the track to swap
    std::vector<int> migration_link_id; // point to the migration link entry
    std::vector<int> swap_new_to_old_id; // for swap, migration link id for new track pos to old track pos
    std::vector<int> swap_old_to_new_id; // for swap, migration link id for old track pos to new track pos
};

// Define a class to describe a track during the backtracking, post-processing, etc
// corresponding to the new_track struct in matlab script
class Track {
public:
    // constructor
    Track() {}
    
    Track(int num_frames) :
    current_id(std::vector<int>(num_frames, NaN_int)),
    gap_to_previous_id(std::vector<int>(num_frames, NaN_int)),
    gap_to_next_id(std::vector<int>(num_frames, NaN_int)),
    if_apoptosis(std::vector<int>(num_frames, NaN_int)),
    daughters(std::vector<std::vector<int> >(num_frames, std::vector<int>())),
    migration_link_id(std::vector<int>(num_frames, NaN_int)) {}
    
    // copy constructor
    Track(const Track& copy_instance) :
    current_id(copy_instance.current_id),
    gap_to_previous_id(copy_instance.gap_to_previous_id),
    gap_to_next_id(copy_instance.gap_to_next_id),
    if_apoptosis(copy_instance.if_apoptosis),
    daughters(copy_instance.daughters),
    migration_link_id(copy_instance.migration_link_id) {}
    
    // clear all content within a range
    void clear(int start_id, int end_id) {
        for (int i=start_id; i<end_id; ++i) {
            current_id[i] = NaN_int;
            gap_to_previous_id[i] = NaN_int;
            gap_to_next_id[i] = NaN_int;
            if_apoptosis[i] = NaN_int;
            daughters[i].clear();
            migration_link_id[i] = NaN_int;
        }
    }
    
    // copy all content within a range
    void copy(Track& copy_instance, int start_id, int end_id) {
        for (int i=start_id; i<end_id; ++i) {
            current_id[i] = copy_instance.current_id[i];
            gap_to_previous_id[i] = copy_instance.gap_to_previous_id[i];
            gap_to_next_id[i] = copy_instance.gap_to_next_id[i];
            if_apoptosis[i] = copy_instance.if_apoptosis[i];
            daughters[i] = copy_instance.daughters[i];
            migration_link_id[i] = copy_instance.migration_link_id[i];
        }
    }
                  
    // values
    std::vector<int> current_id; // store the id of the detection for every frame. NaN for X or Y
    std::vector<int> gap_to_previous_id; // store the gap to the previous frame ID
    std::vector<int> gap_to_next_id; // store the gap to the next frame ID
    std::vector<int> if_apoptosis; // whether cells will undergo apoptosis, 0 for no, 1 for yes
    std::vector<std::vector<int> > daughters; // if this cell will undergo mitosis, it stores all the descendents of this cell. Otherwise empty.
    std::vector<int> migration_link_id; // all migration links
};

// Define a struct to save the migration link information
struct Migration_Link {
    double score;
    int gap_to_previous;
    int previous_id;
    
    Migration_Link() : score(-Inf_double), gap_to_previous(NaN_int), previous_id(NaN_int) {}
};

// Define a struct to save the best migration information when completing the state space diagram
struct Migration_State {
    double score;
    int gap_to_previous;
    int previous_id;
    int migration_link_id;
    
    Migration_State() : score(-Inf_double), gap_to_previous(NaN_int), previous_id(NaN_int), migration_link_id(NaN_int) {}
};

// Define a struct to save the best swap information when completing the state space diagram
struct Swap_State {
    double score;
    int gap_to_previous;
    int previous_id;
    int track_id;
    int track_current_id;
    int track_gap_to_previous;
    int old_to_new_id;
    int new_to_old_id;
    int migration_link_id;
    
    Swap_State() : score(-Inf_double), gap_to_previous(NaN_int), previous_id(NaN_int), track_id(NaN_int), track_current_id(NaN_int), track_gap_to_previous(NaN_int), old_to_new_id(NaN_int), new_to_old_id(NaN_int), migration_link_id(NaN_int) {}
};

// Define a struct to describe the mitosis information when completing the state space diagram
struct Mitosis_State {
    double score;
    int track_id;
    int track_previous_id;
    int migration_link_id;
    
    Mitosis_State() : score(-Inf_double), track_id(NaN_int), track_previous_id(NaN_int), migration_link_id(NaN_int) {}
};

// Define a struct to store mitosis information during backtracking
struct Backtracking_Info {
    int frame_id;
    int detection_id;
    int track_id;
    int migration_link_id;
    int old_to_new_id;
    int new_to_old_id;
    
    Backtracking_Info() : frame_id(NaN_int), detection_id(NaN_int), track_id(NaN_int), migration_link_id(NaN_int), old_to_new_id(NaN_int), new_to_old_id(NaN_int) {}
};

// Define a struct to describe track parameters
// Refer to parameters.m for meaning
struct Track_Para {
    double skip_penalty;
    double multiple_cells_penalty;
    double min_track_score;
    double min_track_score_per_step;
};

// Define a function to sort the vector and return the index!
// Copied from https://stackoverflow.com/questions/1577475/c-sorting-and-keeping-track-of-indexes
// Require c++ 11
// Change from < to > in return line to sort descendently
template <typename T>
std::vector<int> sort_indexes(const std::vector<T> &v) {
    
    // initialize original index locations
    std::vector<int> idx(v.size());
    std::iota(idx.begin(), idx.end(), 0);
    
    // sort indexes based on comparing values in v
    std::sort(idx.begin(), idx.end(),
              [&v](int i1, int i2) {
                  return v[i1] > v[i2];
              });
    
    return idx;
}

//SEARCH_POSSIBLE_LINK Search for the id of the possible migration link
//
//  Input
//      all_migration_links: all the possible migration links
//      cand_gap_to_previous: the gap_to_previous value of the link to search
//      cand_previous_id: the previous_id value of the link to search
//  Output
//      NaN_int for not found. link number if found
//
int search_possible_link(std::vector<Migration_Link>& all_migration_links, int cand_gap_to_previous, int cand_previous_id) {
    
    for (int i=0; i<all_migration_links.size(); ++i) {
        if (all_migration_links[i].gap_to_previous == cand_gap_to_previous && all_migration_links[i].previous_id == cand_previous_id) {
            return i;
        }
    }
    
    return NaN_int;
    
}

//ADJUST_STEPSCORE Change the score to -Inf if the score for a step is below a threshold
//
//  Input
//      score: score of a step to examine
//      track_para: parameters associated with tracking
//  Output
//      score if it's above the minimal threshold; otherwise -Inf
//
double adjust_stepscore(double score, Track_Para& track_para) {
    if (score < track_para.min_track_score_per_step) {
        return -Inf_double;
    } else {
        return score;
    }
}

//ADJUST_STATE_TO_TRACK Change recorded_state_to_track information based on track swap, mitosis detection, etc
//  Input
//      recorded_state_to_track: state to track information
//      ref_track: reference track to modify
//      start_frame_id: start frame id to modify
//      end_frame_id: end frame id to modify. [start_frame_id, end_frame_id)
//      old_value: value to remove
//      new_value: value to add
//  Output
//      recorded_state_to_track: modified state to track information
//
int adjust_state_to_track(std::vector<std::vector<std::vector<int> > >& recorded_state_to_track, Track& ref_track, int start_frame_id, int end_frame_id, int old_value, int new_value) {
    if (old_value == NaN_int) { // only add new value
        for (int i=start_frame_id; i<end_frame_id; ++i) {
            if (ref_track.current_id[i] != NaN_int) {
                recorded_state_to_track[i][ref_track.current_id[i]].push_back(new_value);
            }
        }
    } else if (new_value == NaN_int) { // only remove old value
        for (int i=start_frame_id; i<end_frame_id; ++i) {
            if (ref_track.current_id[i] != NaN_int) {
                std::vector<int>& temp = recorded_state_to_track[i][ref_track.current_id[i]];
                temp.erase(std::remove(temp.begin(), temp.end(), old_value), temp.end());
            }
        }
    } else { // replace old value by new value
        for (int i=start_frame_id; i<end_frame_id; ++i) {
            if (ref_track.current_id[i] != NaN_int) {
                std::vector<int>& temp = recorded_state_to_track[i][ref_track.current_id[i]];
                std::replace(temp.begin(), temp.end(), old_value, new_value);
            }
        }
    }
    return 0;
}

//GENERATE_TRACKS Generate tracks from the data
//
//  Input
//      all_num_detections: all the number of detections per frame
//      all_morphology_stepscore: output from classification algorithm, converted to score
//      all_stepscore_migration: score of a cell to migrate from one position
//      to the next, now only save the best possible L links
//      all_stepscore_inout_frame: score of a cell to move in/out of frames
//      track_para: parameters associated with tracking
//   Output
//      all_tracks: all complete tracks
//
//   Correspondance to matlab version's data structure
//      all_num_detections:
//          matlab: a vector array;
//          c++: a vector
//      all_morphology_stepscore
//          matlab: a cell array, each element is num_detection x num_label matrix
//          c++: 3-level vector array. Outer->Inner: frame, current detection id, label ID
//      all_stepscore_migration
//          matlab: a cell array, where each element is a cell matrix. The element of every cell matrix is a vector
//          c++: 3-level vector array. Outer->Inner: frame, current detection id, links saved as Migration_Link struct instance
//      all_stepscore_inout_frame
//          matlab, a cell array, where each element is a vector array
//          c++: 2-level vector array. Outer->Inner: frame, current detection id
//
int generate_tracks(std::vector<int>& all_num_detections, std::vector<std::vector<std::vector<double> > >& all_morphology_stepscore, std::vector<std::vector<std::vector<Migration_Link> > >& all_stepscore_migration, std::vector<std::vector<double> >& all_stepscore_inout_frame, Track_Para& track_para, std::vector<Track>& all_tracks) {
    
    // Part 1. Global Structures
    // number of frames in the movie
    int num_frames = all_num_detections.size();
    
    // currently recorded number of cells per detection per frame. Put 0 as an initial state
    std::vector<std::vector<int> > recorded_num_cells(num_frames);
    for (int i=0; i<num_frames; i++) {
        recorded_num_cells[i] = std::vector<int>(all_num_detections[i], 0);
    }
    
    // currently recorded mitosis events of cells per detection and frame. Put 0 (no mitosis) as an initial state.
    std::vector<std::vector<int> > recorded_if_mitosis(recorded_num_cells);
    
    // currently recorded mitosis exit events of cells per detection and frame.
    std::vector<std::vector<int> > recorded_if_mitosis_exit(recorded_num_cells);
    
    // currently recorded apoptosis events
    std::vector<std::vector<int> > recorded_if_apoptosis(recorded_num_cells);
    
    // currently recorded moving-in
    std::vector<std::vector<int> > recorded_moving_in(recorded_num_cells);
    
    // currently recorded moving-out
    std::vector<std::vector<int> > recorded_moving_out(recorded_num_cells);
    
    // currently recorded migration
    std::vector<std::vector<std::vector<int> > > recorded_migration(num_frames);
    for (int i=0; i<num_frames; ++i) {
        std::vector<std::vector<int> > temp;
        for (int j=0; j<all_num_detections[i]; ++j) {
            temp.push_back(std::vector<int>(all_stepscore_migration[i][j].size(), 0));
        }
        recorded_migration[i] = temp;
    }
    
    // currently state to track record
    std::vector<std::vector<std::vector<int> > > recorded_state_to_track(num_frames);
    std::vector<int> temp; temp.reserve(2);
    for (int i=0; i<num_frames; ++i) {
        recorded_state_to_track[i] = std::vector<std::vector<int> >(all_num_detections[i], temp);
    }
    
    // all recorded tracks
    int num_tracks = all_tracks.size();

    // Part 2. Construct one track
    while (1) {
        // Step 1. Fill in state space diagram
        std::vector<Frame> state_space; state_space.reserve(num_frames);
        
        // Frame 1
        {
            // set up data structure
            int num_detections = all_num_detections[0];
            Frame new_frame(num_detections+2); // the last two are X1 (exit) and Y1 (entry)
            
            // set up entries for all detections
            for (int i=0; i<num_detections; ++i) {
                int prev_cellcount = recorded_num_cells[0][i];
                if (prev_cellcount <= 2) { // note that we only train 0, 1, 2 cells per detection
                    new_frame.current_score[i] = all_morphology_stepscore[0][i][prev_cellcount];
                } else { // both previous and current are at least 3 cells per detection -> 0
                    new_frame.current_score[i] = 0;
                }
            }
            // no need to update other structures, since there is no preceding frame
            
            // set up entries for second-to-last entry X0
            new_frame.current_score[num_detections] = 0;
            
            // set up entries for the last entry Y0
            new_frame.current_score[num_detections+1] = 0;
            
            // change the score to -Inf if it falls below min_track_score_per_step
            for (int i=0; i<=num_detections+1; ++i) {
                new_frame.current_score[i] = adjust_stepscore(new_frame.current_score[i], track_para);
            }
            
            // save this frame
            state_space.push_back(new_frame);
        }
        
        // Other Frames
        for (int i=1; i<num_frames; ++i) {
            // set up data structure
            int num_detections = all_num_detections[i];
            int previous_frame_num_detections = all_num_detections[i-1];
            Frame new_frame(num_detections + 2); // the last two are Xi (exit) and Yi (entry)
            
            // set up entries for the last entry Yi
            new_frame.current_score[num_detections+1] = state_space[i-1].current_score[previous_frame_num_detections+1];
            new_frame.previous_id[num_detections+1] = previous_frame_num_detections+1;
            new_frame.gap_to_previous_id[num_detections+1] = 1;
            
            // set up entries for the second-to-last entry Xi
            // Possibility 1. Disappear by leaving the image
            std::vector<double> current_score_leaving_frame; current_score_leaving_frame.reserve(previous_frame_num_detections);
            for (int j=0; j<previous_frame_num_detections; ++j) {
                double temp = all_stepscore_inout_frame[i-1][j]*(!recorded_moving_out[i-1][j]);
                // temp = adjust_stepscore(temp, track_para); 
                current_score_leaving_frame.push_back(state_space[i-1].current_score[j] + temp);
            }
            double max_current_score_leaving_frame = *std::max_element(current_score_leaving_frame.begin(), current_score_leaving_frame.end());
            
            // Possibility 2. Disappear by apoptosis
            std::vector<double> current_score_apoptosis; current_score_apoptosis.reserve(previous_frame_num_detections);
            for (int j=0; j<previous_frame_num_detections; ++j) {
                double temp = all_morphology_stepscore[i-1][j][5]*(!recorded_if_apoptosis[i-1][j]);
                // temp = adjust_stepscore(temp, track_para);
                current_score_apoptosis.push_back(state_space[i-1].current_score[j] + temp);
            }
            double max_current_score_apoptosis = *std::max_element(current_score_apoptosis.begin(), current_score_apoptosis.end());
            
            // Possibility 3. Keep the original entry
            double current_score_nothing = state_space[i-1].current_score[previous_frame_num_detections];
            
            // find the best decision
            if (current_score_nothing > max_current_score_leaving_frame && current_score_nothing > max_current_score_apoptosis) { // best is to do nothing
                new_frame.current_score[num_detections] = current_score_nothing;
                new_frame.previous_id[num_detections] = previous_frame_num_detections;
                new_frame.gap_to_previous_id[num_detections] = 1;
            } else if (max_current_score_leaving_frame > max_current_score_apoptosis) { // best is cells migrating out of the frame
                // find out the id of the detection to migrate out of the frame
                int best_previous_id = std::find(current_score_leaving_frame.begin(), current_score_leaving_frame.end(), max_current_score_leaving_frame) - current_score_leaving_frame.begin();
                // denote values
                new_frame.current_score[num_detections] = max_current_score_leaving_frame;
                new_frame.previous_id[num_detections] = best_previous_id;
                new_frame.gap_to_previous_id[num_detections] = 1;
            } else { // best is cells die
                // find out the id of the detection to die
                int best_previous_id = std::find(current_score_apoptosis.begin(), current_score_apoptosis.end(), max_current_score_apoptosis) - current_score_apoptosis.begin();
                new_frame.current_score[num_detections] = max_current_score_apoptosis;
                new_frame.previous_id[num_detections] = best_previous_id;
                new_frame.gap_to_previous_id[num_detections] = 1;
                state_space[i-1].if_apoptosis[best_previous_id] = 1;
            }
            
            // set up entries for other detections
            // go through every detection in this frame
            for (int j=0; j<num_detections; ++j) {
                
                // compute the score for adding one cell in a detection
                int prev_cellcount = recorded_num_cells[i][j];
                double current_score_adding_cell = 0;
                if (prev_cellcount <= 2) { // can add one cell
                    current_score_adding_cell = all_morphology_stepscore[i][j][prev_cellcount];
                } else { // both previous and current are at least 3 cells per detection -> 0
                    current_score_adding_cell = 0;
                }
                
                // number of possible migration links for this detection
                int num_migration_links = all_stepscore_migration[i][j].size();
                
                // Possibility 1. Migration. Link from D to D
                Migration_State best_migration_state;
                for (int i_link=0; i_link<num_migration_links; ++i_link) {
                    // read relevant info
                    Migration_Link current_migration_link = all_stepscore_migration[i][j][i_link];
                    
                    // compute scores
                    double temp = current_migration_link.score * (!recorded_migration[i][j][i_link]) + current_score_adding_cell;
                    temp = adjust_stepscore(temp, track_para);
                    
                    // save the score if this is better than the globally max one
                    double temp_migration_score = state_space[i-current_migration_link.gap_to_previous].current_score[current_migration_link.previous_id] + temp;
                    if (temp_migration_score > best_migration_state.score) {
                        best_migration_state.score = temp_migration_score;
                        best_migration_state.gap_to_previous = current_migration_link.gap_to_previous;
                        best_migration_state.previous_id = current_migration_link.previous_id;
                        best_migration_state.migration_link_id = i_link;
                    }
                }
                
                // Preparation for Possibility 2 and 3. Find all possible tracks for swap/mitosis
                // a necessary condition is that there should be a possible migration link between the current detection to the previous detection of the candidate track
                std::vector<int> all_cand_tracks;
                for (int i_link=0; i_link<num_migration_links; ++i_link) {
                    Migration_Link& current_migration_link = all_stepscore_migration[i][j][i_link];
                    std::vector<int>& temp = recorded_state_to_track[i-current_migration_link.gap_to_previous][current_migration_link.previous_id];
                    all_cand_tracks.insert(all_cand_tracks.end(), temp.begin(), temp.end());
                }
                std::sort(all_cand_tracks.begin(), all_cand_tracks.end());
                all_cand_tracks.erase(std::unique(all_cand_tracks.begin(), all_cand_tracks.end()), all_cand_tracks.end());
                int num_cand_tracks = all_cand_tracks.size();
                
                // Possibility 2. Swap. Link from D to D. (not swap in the state space diagram. Do it after back-tracing and track creation)
                Swap_State best_swap_state;
                
                for (int i_link=0; i_link<num_migration_links; ++i_link) {
                    // read relevant info
                    Migration_Link current_migration_link = all_stepscore_migration[i][j][i_link];
                    
                    // iterate over all existing tracks, exame whether a swap can be created
                    for (int i_cand_track=0; i_cand_track<num_cand_tracks; ++i_cand_track) {
                        int i_track = all_cand_tracks[i_cand_track];
                        
                        // Requirements
                        // (1) has a detection in the current frame, other than j
                        // (2) has a detection in the previous frame. If that detection is in the same frame as j's ancestor, it should be a detection other than j's ancestor
                        // (3) the detection in the previous frame should nothave any special status, such as apoptosis or mitosis
                        
                        // get info of the current track
                        int track_current_id = all_tracks[i_track].current_id[i];
                        int track_gap_to_previous = all_tracks[i_track].gap_to_previous_id[i];
                        
                        // either that track has no detection at this frame, or it is duplicated with the current detection under consideration, or has no previous node
                        if (track_current_id == NaN_int || track_current_id == j || track_gap_to_previous == NaN_int) {
                            continue;
                        }
                        
                        // the previous id of the track should not have any special status
                        int track_previous_id = all_tracks[i_track].current_id[i-track_gap_to_previous];
                        if (recorded_if_mitosis[i-track_gap_to_previous][track_previous_id] || recorded_if_apoptosis[i-track_gap_to_previous][track_previous_id]) {
                            continue;
                        }
                        
                        // the previous id of the track should not have any duplicated status (other essentially not swap at all)
                        if (track_gap_to_previous == current_migration_link.gap_to_previous && track_previous_id == current_migration_link.previous_id) {
                            continue;
                        }
                        
                        // swapped links should be possible
                        int link_old_to_new = search_possible_link(all_stepscore_migration[i][track_current_id], current_migration_link.gap_to_previous, current_migration_link.previous_id);
                        int link_new_to_old = search_possible_link(all_stepscore_migration[i][j], track_gap_to_previous, track_previous_id);
                        int link_old_to_old = all_tracks[i_track].migration_link_id[i];
                        if (link_old_to_new == NaN_int || link_new_to_old == NaN_int) {
                            continue;
                        }
                        
                        // compute scores
                        double temp = all_stepscore_migration[i][track_current_id][link_old_to_new].score * (!recorded_migration[i][track_current_id][link_old_to_new]) /* add a migration link from Dt,i to Dt+t1,n */
                            - all_stepscore_migration[i][track_current_id][link_old_to_old].score * (recorded_migration[i][track_current_id][link_old_to_old] <= 1) /* remove a migration link from Dt+t1-t2,m to Dt+t1,n */
                            + all_stepscore_migration[i][j][link_new_to_old].score * (!recorded_migration[i][j][link_new_to_old]) /* add a migration link from Dt+t1-t2 to Dt+T1,j */
                            + current_score_adding_cell; /* score for adding a cell */
                        temp = adjust_stepscore(temp, track_para);
                        double temp_swap_score = state_space[i-current_migration_link.gap_to_previous].current_score[current_migration_link.previous_id] + temp;
                        
                        // update the info if this swap score is better than the globally max
                        if (temp_swap_score > best_swap_state.score) {
                            best_swap_state.score = temp_swap_score;
                            best_swap_state.gap_to_previous = current_migration_link.gap_to_previous;
                            best_swap_state.previous_id = current_migration_link.previous_id;
                            best_swap_state.track_id = i_track;
                            best_swap_state.track_current_id = track_current_id;
                            best_swap_state.track_gap_to_previous = track_gap_to_previous;
                            best_swap_state.old_to_new_id = link_old_to_new;
                            best_swap_state.new_to_old_id = link_new_to_old;
                            best_swap_state.migration_link_id = i_link;
                        }
                    }
                }
                
                // Possibility 3. cell in the previous frame undergoes mitosis. Link from Y to D
                // Go through existing tracks, see whether there exists a cell  in the previous frame that
                // (1) already link to a cell in this frame and
                // (2) current cell has a high probability to be a mitosis-exit cell
                Mitosis_State best_mitosis_state;
                for (int i_link=0; i_link<num_migration_links; ++i_link) {
                    // read relevant info
                    Migration_Link current_migration_link = all_stepscore_migration[i][j][i_link];
                    
                    // must have gap 1
                    if (current_migration_link.gap_to_previous != 1) {
                        continue;
                    }
                    
                    // iterate over all tracks
                    for (int i_cand_track=0; i_cand_track<num_cand_tracks; ++i_cand_track) {
                        int i_track = all_cand_tracks[i_cand_track];
                        
                        // requirements
                        // (1) has a detection in the previous frame, which is the migration link to look at
                        // (2) has a detection in the current frame, which is not j
                        // (3) all detections are recorded neither in mitosis nor i mitosis exit
                        int track_previous_id = all_tracks[i_track].current_id[i-1];
                        int track_current_id = all_tracks[i_track].current_id[i];
                        
                        // check the ids of current and previous detection in the track
                        if (track_current_id == NaN_int || track_current_id == j || track_previous_id != current_migration_link.previous_id) {
                            continue;
                        }
                        
                        // check the status of mitosis and mitosis exit
                        if (recorded_if_mitosis[i-1][track_previous_id] || recorded_if_mitosis[i][track_current_id] || recorded_if_mitosis[i][j] ||
                            recorded_if_mitosis_exit[i-1][track_previous_id] || recorded_if_mitosis_exit[i][track_current_id] || recorded_if_mitosis_exit[i][j]) {
                            continue;
                        }
                        
                        double temp = all_morphology_stepscore[i-1][track_previous_id][3]  /* mitosis score */
                            + all_morphology_stepscore[i][track_current_id][4] /* mitosis exit score */
                            + all_morphology_stepscore[i][j][4] /* mitosis exit score */
                            + current_migration_link.score * (!recorded_migration[i][j][i_link]) /* migration score */
                            + current_score_adding_cell; /* score for adding a cell in a detection */
                        temp = adjust_stepscore(temp, track_para);
                        double temp_mitosis_score = state_space[i-1].current_score[previous_frame_num_detections+1] + temp;
                                
                        // update mitosis information if a better mitosis score is found
                        if (temp_mitosis_score > best_mitosis_state.score) {
                            best_mitosis_state.score = temp_mitosis_score;
                            best_mitosis_state.track_id = i_track;
                            best_mitosis_state.track_previous_id = track_previous_id;
                            best_mitosis_state.migration_link_id = i_link;
                        }
                    }
                }
                
                // Possibility 4. Move into frame. Link from Y to D
                double temp = all_stepscore_inout_frame[i][j]*(!recorded_moving_in[i][j])  /* score for moving in */
                    + current_score_adding_cell; /* score for adding a cell */
                temp = adjust_stepscore(temp, track_para);
                double best_entering_frame_state = state_space[i-1].current_score[previous_frame_num_detections+1] + temp;
                
                // find the best scores
                // best decision is to get a migration link from D to D
                if (best_migration_state.score > best_swap_state.score && best_migration_state.score > best_mitosis_state.score && best_migration_state.score > best_entering_frame_state) {
                    new_frame.current_score[j] = best_migration_state.score;
                    new_frame.previous_id[j] = best_migration_state.previous_id;
                    new_frame.gap_to_previous_id[j] = best_migration_state.gap_to_previous;
                    new_frame.migration_link_id[j] = best_migration_state.migration_link_id;
                    
                } else if (best_swap_state.score > best_mitosis_state.score && best_swap_state.score > best_entering_frame_state) {
                    // best decision is to get a swap link from D to D
                    new_frame.current_score[j] = best_swap_state.score;
                    new_frame.previous_id[j] = best_swap_state.previous_id;
                    new_frame.gap_to_previous_id[j] = best_swap_state.gap_to_previous;
                    new_frame.swap_track_id[j] = best_swap_state.track_id;
                    new_frame.migration_link_id[j] = best_swap_state.migration_link_id;
                    new_frame.swap_old_to_new_id[j] = best_swap_state.old_to_new_id;
                    new_frame.swap_new_to_old_id[j] = best_swap_state.new_to_old_id;
                    
                } else if (best_mitosis_state.score > best_entering_frame_state) {
                    // best decision is to get a mitosis link from Y to D
                    new_frame.current_score[j] = best_mitosis_state.score;
                    new_frame.previous_id[j] = previous_frame_num_detections+1;
                    new_frame.gap_to_previous_id[j] = 1;
                    new_frame.mitosis_track_id[j] = best_mitosis_state.track_id;
                    new_frame.migration_link_id[j] = best_mitosis_state.migration_link_id;
                    
                } else {
                    // best decision is to get a moving in/out link from Y to D
                    new_frame.current_score[j] = best_entering_frame_state;
                    new_frame.previous_id[j] = previous_frame_num_detections+1;
                    new_frame.gap_to_previous_id[j] = 1;
                }
            }
            
            // save the current frame into the state space
            state_space.push_back(new_frame);
        }
        
        // BACKTRACK TO FIND THE BEST TRACK
        Track new_track(num_frames);
        Backtracking_Info mitosis_info; // store all the mitosis information along the new track
        std::vector<Backtracking_Info> swap_info; swap_info.reserve(num_frames); // store all the swap information along the new track
        
        // find the best detection in the last frame
        int current_frame_id = num_frames-1;
        double max_score = *std::max_element(state_space[current_frame_id].current_score.begin(), state_space[current_frame_id].current_score.end());
        if (max_score < track_para.min_track_score) { // can't improve the overall score any more. terminate tracking linking algorithm
            mexPrintf("Scoring function does not meet the minimal threshold. All tracks have been found. Algorithm terminates.\n");
            mexEvalString("drawnow;");
            break;
        }
        int current_detection_id = std::find(state_space[current_frame_id].current_score.begin(), state_space[current_frame_id].current_score.end(), max_score) - state_space[current_frame_id].current_score.begin();
        
        // loop until the first frame is analyzed
        while (1) {
            // put the values for the current frame into the optimal track
            // update the global recording matrix
            
            // adding a cell
            // put detection id to the current frame
            new_track.current_id[current_frame_id] = current_detection_id;
            // update the global recording matrix for cell counts, if it's not an X or Y
            if (current_detection_id < all_num_detections[current_frame_id]) {
                recorded_num_cells[current_frame_id][current_detection_id] ++;
            }
            
            // migration statistics, as well as moving in/out of frame
            int gap_to_previous_id = state_space[current_frame_id].gap_to_previous_id[current_detection_id];
            if (current_frame_id > 0) { // not the first frame. can back-trace
                // put the value of gap_to_previous_id as well as gap_to_next_id
                new_track.gap_to_previous_id[current_frame_id] = gap_to_previous_id;
                new_track.gap_to_next_id[current_frame_id-gap_to_previous_id] = gap_to_previous_id;
                
                // look at the previous detection and perform update
                int previous_detection_id = state_space[current_frame_id].previous_id[current_detection_id];
                if (current_detection_id < all_num_detections[current_frame_id]) {
                    // current is a valid detection
                    if (previous_detection_id < all_num_detections[current_frame_id-gap_to_previous_id]) {
                        // previous is also a valid detection
                        // only need to update migration
                        int migration_link_id = state_space[current_frame_id].migration_link_id[current_detection_id];
                        new_track.migration_link_id[current_frame_id] = migration_link_id;
                        recorded_migration[current_frame_id][current_detection_id][migration_link_id] ++;
                    
                    } else {
                        // previous is not a valid detection
                        if (state_space[current_frame_id].mitosis_track_id[current_detection_id] == NaN_int) {
                            // no mitosis -> move into the frame
                            recorded_moving_in[current_frame_id][current_detection_id] ++;
                        } else {
                            // mitosis event
                            if (mitosis_info.frame_id != NaN_int) {
                                mexErrMsgTxt("Multiple mitosis events occur in the same track!");
                            }
                            // record mitosis info
                            int track_to_mitosis = state_space[current_frame_id].mitosis_track_id[current_detection_id];
                            int track_current_detection_id = all_tracks[track_to_mitosis].current_id[current_frame_id];
                            int track_gap_to_previous_id = all_tracks[track_to_mitosis].gap_to_previous_id[current_frame_id];
                            int track_previous_frame_id = current_frame_id - track_gap_to_previous_id;
                            int track_previous_detection_id = all_tracks[track_to_mitosis].current_id[track_previous_frame_id];
                            recorded_if_mitosis[track_previous_frame_id][track_previous_detection_id] ++;
                            recorded_if_mitosis_exit[current_frame_id][track_current_detection_id] ++;
                            recorded_if_mitosis_exit[current_frame_id][current_detection_id] ++;
                            
                            mitosis_info.frame_id = current_frame_id;
                            mitosis_info.detection_id = current_detection_id;
                            mitosis_info.track_id = track_to_mitosis;
                            
                            // record migration info (from mother cell to itself)
                            // can't do it with general migration update because it starts from Y, not a D state.
                            int migration_link_id = state_space[current_frame_id].migration_link_id[current_detection_id];
                            recorded_migration[current_frame_id][current_detection_id][migration_link_id] ++;
                            
                        }
                    }
                } else { // current is not a valid detection
                    if (previous_detection_id < all_num_detections[current_frame_id - gap_to_previous_id]) {
                        // previous is a valid detection (apoptosis or moving out)
                        if (state_space[current_frame_id-gap_to_previous_id].if_apoptosis[previous_detection_id] != NaN_int) {
                            // apoptosis
                            new_track.if_apoptosis[current_frame_id - gap_to_previous_id] = 1;
                            recorded_if_apoptosis[current_frame_id-gap_to_previous_id][previous_detection_id]++;
                        } else {
                            // moving out of frame
                            recorded_moving_out[current_frame_id-gap_to_previous_id][previous_detection_id]++;
                        }
                    }
                }
            }
            
            // record swap info
            if (state_space[current_frame_id].swap_track_id[current_detection_id] != NaN_int) {
                Backtracking_Info new_swap_info;
                new_swap_info.frame_id = current_frame_id;
                new_swap_info.detection_id = current_detection_id;
                new_swap_info.track_id = state_space[current_frame_id].swap_track_id[current_detection_id];
                new_swap_info.migration_link_id = state_space[current_frame_id].migration_link_id[current_detection_id];
                new_swap_info.new_to_old_id = state_space[current_frame_id].swap_new_to_old_id[current_detection_id];
                new_swap_info.old_to_new_id = state_space[current_frame_id].swap_old_to_new_id[current_detection_id];
                swap_info.push_back(new_swap_info);
            }
            
            // backtrace to the previous value
            if (current_frame_id == 0) { // reach the starting point of the track
                break;
            } else {
                int temp1 = state_space[current_frame_id].gap_to_previous_id[current_detection_id];
                int temp2 = state_space[current_frame_id].previous_id[current_detection_id];
                current_frame_id = current_frame_id - temp1;
                current_detection_id = temp2;
            }
        }
        
        // refine the track such that hypothetical X and Y states are counted as NaN
        for (int i=0; i<num_frames; ++i) {
            int current_detection_id = new_track.current_id[i];
            if (current_detection_id == NaN_int) { // current frame is non-existent
                continue;
            }
            if (current_detection_id >= all_num_detections[i]) { // either an X or Y state
                int temp1 = new_track.gap_to_previous_id[i];
                int temp2 = new_track.gap_to_next_id[i];
                new_track.current_id[i] = NaN_int;
                new_track.gap_to_previous_id[i] = NaN_int;
                new_track.gap_to_next_id[i] = NaN_int;
                if (i>0 && temp1 != NaN_int) {
                    new_track.gap_to_next_id[i-temp1] = NaN_int;
                }
                if (i<num_frames-1 && temp2 != NaN_int) {
                    new_track.gap_to_previous_id[i+temp2] = NaN_int;
                }
            }
        }
        
        // ADJUSTING TRACKS BASED ON SPECIAL EVENTS
        // Part 1. Mitosis
        // Break the existing track into two: one for mother and one for daughter. The new track serves as the other daughter.
        // All mitosis comes from Y state and never returns to Y again. So at most 1 mitosis event
        if (mitosis_info.frame_id != NaN_int) {
            // separate the old track into two segments
            // first segment is mother track: still all_tracks{mitosis_info(3)}
            // second segment is the first daughter's track: first_daughter_track. track id is num_tracks
            // the second daughter is new_track, so no need to create anything. track id is num_tracks+1

            int current_frame_id = mitosis_info.frame_id;
            int current_track_id = mitosis_info.track_id;
            
            // construct daughter track and eliminate relevant information
            Track first_daughter_track = all_tracks[current_track_id];
            all_tracks[current_track_id].clear(current_frame_id, num_frames);
            first_daughter_track.clear(0, current_frame_id);
            
            // update the gap_to_previous_id and gap_to_next_id entries at the point of mitosis
            first_daughter_track.gap_to_previous_id[current_frame_id] = NaN_int; // Its mother's track is separated. So nothing should be recorded.
            first_daughter_track.migration_link_id[current_frame_id] = NaN_int;
            all_tracks[current_track_id].gap_to_next_id[current_frame_id-1] = NaN_int; // Its first daughter's track is separated. So nothing should be recorded.
            
            // update the daughter portion of recorded_state_to_track elements
            adjust_state_to_track(recorded_state_to_track, first_daughter_track, current_frame_id, num_frames, current_track_id, num_tracks);
            
            // save the daughter information for the mother track
            int temp[] = {num_tracks, num_tracks+1};
            all_tracks[current_track_id].daughters[current_frame_id-1] = std::vector<int>(temp, temp+2);
            
            // update swap information
            for (int i=0; i<swap_info.size(); ++i) {
                if (swap_info[i].track_id == current_track_id && swap_info[i].frame_id >= current_frame_id) {
                    swap_info[i].track_id = num_tracks;
                }
            }
            
            // save the first daughter track
            all_tracks.push_back(first_daughter_track);
            num_tracks++;
            mexPrintf("A mitosis event in Track No. %d. The daughter part of this track is now defined as Track No. %d\n", current_track_id+1, num_tracks);
            mexEvalString("drawnow;");
            
        }
        
        // add the new track to recorded_state_to_track
        adjust_state_to_track(recorded_state_to_track, new_track, 0, num_frames, NaN_int, num_tracks);
        
        // Part 2. Swap
        // Break an existing track and the new track into two segments. The second segment of the new track is appended into the first segment of the existing track. The second segment of the existing track is appended into the first segment of the new track.
        // If we do swapping from the end of the track to the beginning, we can avoid the labeling problem. This is also how swap_info is stored during back-tracing.
        for (int i=0; i<swap_info.size(); ++i) {
            // new track info
            int current_frame_id = swap_info[i].frame_id;
            int new_track_current_detection_id = swap_info[i].detection_id;
            int new_track_gap_to_previous_id = new_track.gap_to_previous_id[current_frame_id];
            int new_track_previous_frame_id = current_frame_id - new_track_gap_to_previous_id;
            int new_track_previous_detection_id = new_track.current_id[new_track_previous_frame_id];
            
            // old track info
            int old_track_id = swap_info[i].track_id;
            int old_track_current_detection_id = all_tracks[old_track_id].current_id[current_frame_id];
            int old_track_gap_to_previous_id = all_tracks[old_track_id].gap_to_previous_id[current_frame_id];
            int old_track_previous_frame_id = current_frame_id - old_track_gap_to_previous_id;
            int old_track_previous_detection_id = all_tracks[old_track_id].current_id[old_track_previous_frame_id];
            
            // swap track info
            int old_to_old_id = all_tracks[old_track_id].migration_link_id[current_frame_id];
            int old_to_new_id = swap_info[i].old_to_new_id;
            int new_to_old_id = swap_info[i].new_to_old_id;
            int new_to_new_id = swap_info[i].migration_link_id;
            
            // update recorded_state_to_track
            adjust_state_to_track(recorded_state_to_track, new_track, current_frame_id, num_frames, num_tracks, NaN_int);
            adjust_state_to_track(recorded_state_to_track, all_tracks[old_track_id], current_frame_id, num_frames, old_track_id, NaN_int);
            adjust_state_to_track(recorded_state_to_track, new_track, current_frame_id, num_frames, NaN_int, old_track_id);
            adjust_state_to_track(recorded_state_to_track, all_tracks[old_track_id], current_frame_id, num_frames, NaN_int, num_tracks);
            
            // swap
            Track temp = new_track;
            new_track.copy(all_tracks[old_track_id], current_frame_id, num_frames);
            all_tracks[old_track_id].copy(temp, current_frame_id, num_frames);
            
            // change the gap_to_previous_id and gap_to_next_id around the swap point
            // for new track
            int last_valid_frame_id = NaN_int;
            for (int j=current_frame_id-1; j>=0; --j) {
                if (new_track.current_id[j] != NaN_int){
                    last_valid_frame_id = j;
                    break;
                }
            }
            if (last_valid_frame_id >= 0) {
                new_track.gap_to_previous_id[current_frame_id] = current_frame_id - last_valid_frame_id;
                new_track.gap_to_next_id[last_valid_frame_id] = current_frame_id - last_valid_frame_id;
            }
            
            // for old track
            last_valid_frame_id = NaN_int;
            for (int j=current_frame_id-1; j>=0; --j) {
                if (all_tracks[old_track_id].current_id[j] != NaN_int) {
                    last_valid_frame_id = j;
                    break;
                }
            }
            if (last_valid_frame_id >= 0) {
                all_tracks[old_track_id].gap_to_previous_id[current_frame_id] = current_frame_id - last_valid_frame_id;
                all_tracks[old_track_id].gap_to_next_id[last_valid_frame_id] = current_frame_id - last_valid_frame_id;
            }
            
            // re-organize migration data
            // note that here the detection id of current_frame_id is switched!
            new_track.migration_link_id[current_frame_id] = old_to_new_id;
            all_tracks[old_track_id].migration_link_id[current_frame_id] = new_to_old_id;
            recorded_migration[current_frame_id][new_track_current_detection_id][new_to_new_id] --;
            recorded_migration[current_frame_id][new_track_current_detection_id][new_to_old_id] ++;
            recorded_migration[current_frame_id][old_track_current_detection_id][old_to_old_id] --;
            recorded_migration[current_frame_id][old_track_current_detection_id][old_to_new_id] ++;
        }
        
        // save the newly created track
        all_tracks.push_back(new_track);
        num_tracks++;
        mexPrintf("Track No. %d has been created.\n", num_tracks);
        mexEvalString("drawnow;");
        
    }
    
    return 0;
}

// wrapper function to pass variables to/from matlab
void mexFunction( int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[] ) {
    
    // check input number
    if (nrhs != 5) {
        mexErrMsgTxt("Number of inputs is invalid.");
    }
    
    // parse input
    // track_para
    Track_Para track_para;
    {
        double *val;
        val = mxGetPr(mxGetField(prhs[4], 0, "skip_penalty")); track_para.skip_penalty = *val;
        val = mxGetPr(mxGetField(prhs[4], 0, "multiple_cells_penalty")); track_para.multiple_cells_penalty = *val;
        val = mxGetPr(mxGetField(prhs[4], 0, "min_track_score")); track_para.min_track_score = *val;
        val = mxGetPr(mxGetField(prhs[4], 0, "min_track_score_per_step")); track_para.min_track_score_per_step = *val;        
    }
    
    // all_num_detections
    std::vector<int> all_num_detections;
    {
        double *pr; pr = (double *) mxGetPr(prhs[0]);
        const mwSize *dims; dims = mxGetDimensions(prhs[0]);
        for (mwIndex i=0; i<dims[0]; ++i) {
            all_num_detections.push_back((int) pr[i]);
        }
    }
    
    // all_morphology_stepscore
    std::vector<std::vector<std::vector<double> > > all_morphology_stepscore;
    {
        // outer loop: time frame
        const mwSize *frame_dims; frame_dims = mxGetDimensions(prhs[1]);
        for (mwIndex i_frame=0; i_frame<frame_dims[0]; ++i_frame) {
            const mxArray *detection_by_feature_pr; detection_by_feature_pr = mxGetCell(prhs[1], i_frame);
            double *detection_by_feature_matrix; detection_by_feature_matrix = (double *) mxGetPr(detection_by_feature_pr);
            const mwSize *detection_by_feature_dims; detection_by_feature_dims = mxGetDimensions(detection_by_feature_pr);
            std::vector<std::vector<double> > detection_by_feature_vector;
            
            // middle loop: detection
            for (mwIndex i_detection=0; i_detection<detection_by_feature_dims[0]; ++i_detection) {
                std::vector<double> feature_vector, all_prob;
                
                // obtain all the raw probabilities
                for (mwIndex i_feature = 0; i_feature < detection_by_feature_dims[1]; ++i_feature) {
                    mwIndex subs[2] = {i_detection, i_feature};
                    mwIndex ind = mxCalcSingleSubscript(detection_by_feature_pr, 2, subs);
                    all_prob.push_back(detection_by_feature_matrix[ind]);
                }
                
                // push into the data vector
                feature_vector.push_back(std::log(all_prob[1])-std::log(all_prob[0])); // 0->1
                feature_vector.push_back(std::log(all_prob[2])-std::log(all_prob[1])-track_para.multiple_cells_penalty); // 1->2
                feature_vector.push_back(std::log(0)-std::log(all_prob[2])+track_para.multiple_cells_penalty); // 2->3
                feature_vector.push_back(std::log(all_prob[3])-std::log(1-all_prob[3])); // mitosis
                feature_vector.push_back(std::log(all_prob[4])-std::log(1-all_prob[4])); // mitosis exit
                feature_vector.push_back(std::log(all_prob[5])-std::log(1-all_prob[5]));
                detection_by_feature_vector.push_back(feature_vector); // apoptosis
            }
            all_morphology_stepscore.push_back(detection_by_feature_vector);
        }
    }
    
    // all_stepscore_migration (now only save the best L links
    std::vector<std::vector<std::vector<Migration_Link> > > all_stepscore_migration;
    {
        const mwSize *frame_dims; frame_dims = mxGetDimensions(prhs[2]);
        
        // for every frame
        for (mwIndex i_frame=0; i_frame<frame_dims[0]; ++i_frame) {
            const mxArray *detection_by_gap_pr; detection_by_gap_pr = mxGetCell(prhs[2], i_frame);
            const mwSize *detection_by_gap_dims; detection_by_gap_dims = mxGetDimensions(detection_by_gap_pr);
            std::vector<std::vector<Migration_Link> > detection_vector;
            
            // for every detection
            for (mwIndex i_detection=0; i_detection<detection_by_gap_dims[0]; ++i_detection) {
                
                // first save every score
                std::vector<int> source_detection_id, source_gap;
                std::vector<double> source_score;
                std::vector<Migration_Link> migration_link_vector;
                
                // for every gap
                for (mwIndex i_gap=0; i_gap<detection_by_gap_dims[1]; ++i_gap) {
                    // get the element for previous_detection_id
                    mwIndex subs[2] = {i_detection, i_gap};
                    mwIndex ind = mxCalcSingleSubscript(detection_by_gap_pr, 2, subs);
                    const mxArray *previous_detection_pr; previous_detection_pr = mxGetCell(detection_by_gap_pr, ind);
                    if (previous_detection_pr == NULL) {
                        continue;
                    }
                    double *previous_detection_array; previous_detection_array = (double *) mxGetPr(previous_detection_pr);
                    const mwSize *previous_detection_dims; previous_detection_dims = mxGetDimensions(previous_detection_pr);
                    
                    // for every previous detection
                    for (mwIndex i_previous_detection=0; i_previous_detection<previous_detection_dims[0]; ++i_previous_detection) {
                        // save into scores
                        double temp = std::log(previous_detection_array[i_previous_detection]) - std::log(1-previous_detection_array[i_previous_detection]) - i_gap*track_para.skip_penalty;
                        source_detection_id.push_back(i_previous_detection);
                        source_gap.push_back(i_gap+1);
                        source_score.push_back(temp);
                    }
                }
                
                // find the best L scores
                int num_links_to_save = std::min((int)source_score.size(), max_recorded_link);
                std::vector<int> sorted_index = sort_indexes(source_score);
                for (int i=0; i<num_links_to_save; ++i) {
                    Migration_Link temp;
                    temp.score = source_score[sorted_index[i]];
                    temp.previous_id = source_detection_id[sorted_index[i]];
                    temp.gap_to_previous = source_gap[sorted_index[i]];
                    migration_link_vector.push_back(temp);
                }
                
                // save the result
                detection_vector.push_back(migration_link_vector);
            }
            all_stepscore_migration.push_back(detection_vector);
        }
    }
    
    // all_stepscore_inout_frame
    std::vector<std::vector<double> > all_stepscore_inout_frame;
    {
        const mwSize *frame_dims; frame_dims = mxGetDimensions(prhs[3]);
        // for every frame
        for (mwIndex i_frame=0; i_frame<frame_dims[0]; ++i_frame) {
            std::vector<double> detection_vector;
            const mxArray *detection_pr; detection_pr = mxGetCell(prhs[3], i_frame);
            const mwSize *detection_dims; detection_dims = mxGetDimensions(detection_pr);
            double *detection_array; detection_array = (double *) mxGetPr(detection_pr);
            // for every detection
            for (mwIndex i_detection=0; i_detection<detection_dims[0]; ++i_detection) {
                detection_vector.push_back(std::log(detection_array[i_detection]) - std::log(1-detection_array[i_detection]));
            }
            all_stepscore_inout_frame.push_back(detection_vector);
        }
    }
    
    // computation
    std::vector<Track> all_tracks; 
    all_tracks.reserve(1000);
    generate_tracks(all_num_detections, all_morphology_stepscore, all_stepscore_migration, all_stepscore_inout_frame, track_para, all_tracks);
    
    // parse output
    nlhs = 1;
    plhs[0] = mxCreateCellMatrix(all_tracks.size(), 1);
    const char* all_field_names[] = {"current_id", "gap_to_previous_id", "gap_to_next_id", "if_apoptosis", "daughters"};
    
    for (int i=0; i<all_tracks.size(); ++i) {
        // initialize the struct
        int num_detection = all_tracks[i].current_id.size();
        mxArray *curr_track; curr_track = mxCreateStructMatrix(1, 1, 5, all_field_names);
        
        // intialize entries
        mxArray *current_id_array; current_id_array = mxCreateDoubleMatrix(num_detection, 1, mxREAL);
        mxArray *gap_to_previous_id_array; gap_to_previous_id_array = mxCreateDoubleMatrix(num_detection, 1, mxREAL);
        mxArray *gap_to_next_id_array; gap_to_next_id_array = mxCreateDoubleMatrix(num_detection, 1, mxREAL);
        mxArray *if_apoptosis_array; if_apoptosis_array = mxCreateDoubleMatrix(num_detection, 1, mxREAL);
        mxArray *daughters_array; daughters_array = mxCreateCellMatrix(num_detection, 1);
        double *current_id; current_id = mxGetPr(current_id_array);
        double *gap_to_previous_id; gap_to_previous_id = mxGetPr(gap_to_previous_id_array);
        double *gap_to_next_id; gap_to_next_id = mxGetPr(gap_to_next_id_array);
        double *if_apoptosis; if_apoptosis = mxGetPr(if_apoptosis_array);
        
        // fill in the values
        for (int j=0; j<num_detection; ++j) {
            if (all_tracks[i].current_id[j] != NaN_int) {
                current_id[j] = all_tracks[i].current_id[j] + 1;
            } else {
                current_id[j] = mxGetNaN();
            }
            if (all_tracks[i].gap_to_previous_id[j] != NaN_int) {
                gap_to_previous_id[j] = all_tracks[i].gap_to_previous_id[j];
            } else {
                gap_to_previous_id[j] = mxGetNaN();
            }
            if (all_tracks[i].gap_to_next_id[j] != NaN_int) {
                gap_to_next_id[j] = all_tracks[i].gap_to_next_id[j];
            } else {
                gap_to_next_id[j] = mxGetNaN();
            }
            if (all_tracks[i].if_apoptosis[j] != NaN_int) {
                if_apoptosis[j] = all_tracks[i].if_apoptosis[j];
            } else {
                if_apoptosis[j] = 0;
            }
            
            // daughters
            mxArray *curr_daughters_array;
            if (all_tracks[i].daughters[j].empty()) { // no daughters, empty vector
                curr_daughters_array = mxCreateDoubleMatrix(0, 0, mxREAL);
            } else { // has daughters
                curr_daughters_array = mxCreateDoubleMatrix(1, 2, mxREAL);
                double *curr_daughters; curr_daughters = mxGetPr(curr_daughters_array);
                curr_daughters[0] = all_tracks[i].daughters[j][0] + 1;
                curr_daughters[1] = all_tracks[i].daughters[j][1] + 1;
            }
            mxSetCell(daughters_array, j, curr_daughters_array);
        }
        
        // save to the struct
        mxSetField(curr_track, 0, all_field_names[0], current_id_array);
        mxSetField(curr_track, 0, all_field_names[1], gap_to_previous_id_array);
        mxSetField(curr_track, 0, all_field_names[2], gap_to_next_id_array);
        mxSetField(curr_track, 0, all_field_names[3], if_apoptosis_array);
        mxSetField(curr_track, 0, all_field_names[4], daughters_array);
        
        // save to the cell array
        mxSetCell(plhs[0], i, curr_track);
    }

    return;
}
