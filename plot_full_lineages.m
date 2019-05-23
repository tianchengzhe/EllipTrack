function plot_full_lineages( all_signals, start_frame, end_frame, signal_nominator, signal_denominator, signal_range )
%PLOT_FULL_LINEAGES Plot lineage trees with signals in the format of
%heatmaps
%
%   Input
%       all_signals: Signal Extraction results
%       start_frame: Start Frame ID of interest
%       end_frame: End Frame ID of interest
%       signal_nominator: Nominator of the signal of interest
%       signal_denominator: Denominator of the signal of interest. Can be
%       empty
%       signal_range: Range of signals for coloring

% extract data
num_tracks = length(all_signals); num_frames = end_frame - start_frame + 1;
all_signal_data = nan(num_tracks, num_frames);
all_daughters_id = nan(num_tracks, 2);
all_mother_id = nan(num_tracks, 1);
if_consider = ones(num_tracks, 1);
all_first_valid_id = nan(num_tracks, 1);
all_last_valid_id = nan(num_tracks, 1);
signal_nominator = matlab.lang.makeValidName(signal_nominator);
if (~isempty(signal_denominator))
    signal_denominator = matlab.lang.makeValidName(signal_denominator);
end
for i=1:num_tracks
    if (all(isnan(all_signals{i}.ellipse_id(start_frame:end_frame)))) % not considering tracks without ellipses within the range of interest
        if_consider(i) = 0;
        continue;
    end
    all_first_valid_id(i) = find(~isnan(all_signals{i}.ellipse_id(start_frame:end_frame)), 1, 'first');
    all_last_valid_id(i) = find(~isnan(all_signals{i}.ellipse_id(start_frame:end_frame)), 1, 'last');
    if (isempty(signal_denominator))
        all_signal_data(i, :) = all_signals{i}.(signal_nominator)(start_frame:end_frame);
    else
        all_signal_data(i, :) = all_signals{i}.(signal_nominator)(start_frame:end_frame) ./ all_signals{i}.(signal_denominator)(start_frame:end_frame);
    end
    temp = find(cellfun(@length, all_signals{i}.daughters) > 0);
    if (~isempty(temp) && temp >= all_first_valid_id(i) && temp <= all_last_valid_id(i))
        all_daughters_id(i, :) = all_signals{i}.daughters{temp};
        all_mother_id(all_signals{i}.daughters{temp}) = i;
    end
end

% smooth signal of interest
for i=1:num_tracks
    if (~if_consider(i))
        continue;
    end
    id = all_first_valid_id(i):all_last_valid_id(i);
    all_signal_data(i,id) = smooth(all_signal_data(i,id), 'lowess')';
end

% compute the weight of every trace
all_cell_weights = compute_weight( all_first_valid_id, all_last_valid_id, all_mother_id, all_daughters_id, start_frame, end_frame, if_consider );

% plot the phylogenetic tree
base_filename = 'lineages_fig_';
plot_cell_lineages( base_filename, all_first_valid_id, all_last_valid_id, all_daughters_id, all_cell_weights, all_signal_data, start_frame, end_frame, signal_range );

end

function [ all_cell_weights ] = compute_weight ( all_first_valid_id, all_last_valid_id, all_mother_id, all_daughters_id, start_frame, end_frame, if_consider )

num_cells = length(all_first_valid_id);
num_frames = end_frame - start_frame + 1;
all_cell_weights = zeros(num_cells, 1);

% start from all cells present at frame 1
id_startat_frame1 = intersect(find(all_first_valid_id == 1), find(if_consider));
for i = 1:length(id_startat_frame1)
    [~, all_cell_weights] = handle_one_node( all_cell_weights, all_first_valid_id, all_last_valid_id, all_mother_id, all_daughters_id, num_frames, id_startat_frame1(i));
end
end

function [ status_to_return, all_cell_weights ] = handle_one_node ( all_cell_weights, all_first_valid_id, all_last_valid_id, all_mother_id, all_daughters_id, num_frames, curr_id )

% this node is non-existing, return and ask the mother to remove weights by
% half
if (isnan(curr_id))
    status_to_return = -0.5;
    return;
end

% if the node reaches the end of the movie, return 0.
if (all_last_valid_id(curr_id) == num_frames)
    all_cell_weights(curr_id) = 1;
    status_to_return = 0;
    return;
end

if (sum(isnan(all_daughters_id(curr_id,:))) == 2) % if both daughters are absent
    all_cell_weights(curr_id) = 0;
    status_to_return = -0.5;
    return;
end

all_cell_weights(curr_id) = 1;
[status_1, all_cell_weights] = handle_one_node(all_cell_weights, all_first_valid_id, all_last_valid_id, all_mother_id, all_daughters_id, num_frames, all_daughters_id(curr_id, 1));
[status_2, all_cell_weights] = handle_one_node(all_cell_weights, all_first_valid_id, all_last_valid_id, all_mother_id, all_daughters_id, num_frames, all_daughters_id(curr_id, 2));
all_cell_weights(curr_id) = all_cell_weights(curr_id) + status_1 + status_2;
status_to_return = (status_1 + status_2)/2;

end

function plot_cell_lineages( base_filename, all_first_valid_id, all_last_valid_id, all_daughters_id, all_cell_weights, tracedata, start_frame, end_frame, signal_range )

% iterate over all starting cells
starting_cell_id = find(all_first_valid_id == 1 & all_cell_weights ~= 0);
num_cells_per_figure = 8;
num_figures = ceil(length(starting_cell_id)/num_cells_per_figure);

for i=1:num_figures
    try
        % fill all the children-parent relationship
        cand_starting_cell_id = starting_cell_id(num_cells_per_figure*(i-1)+1 : min(num_cells_per_figure*i, length(starting_cell_id)));
        all_max_depth = nan(size(cand_starting_cell_id));    
        for j=1:length(cand_starting_cell_id)
            all_max_depth(j) = add_nodes_to_lineages(1, cand_starting_cell_id(j), all_daughters_id);
        end
        id = find(all_max_depth <= 10);
        cand_starting_cell_id = cand_starting_cell_id(id);
        all_max_depth = all_max_depth(id);

        % determine the width of the graph
        min_gap = 3;
        depth_to_width = [1, 5, 11]';
        offset = [1, 0, 0; 3, -2, 2; 6, -3, 3];
        for j=4:max(all_max_depth)
            depth_to_width = cat(1, depth_to_width, depth_to_width(end)*2+1);
            offset = cat(1, offset, offset(end,:)*2);
        end

        all_width = depth_to_width(all_max_depth);

        % fill in the graph figure
        num_frames = end_frame - start_frame + 1;
        figure_data = nan(num_frames, max(depth_to_width(3)*num_cells_per_figure, sum(all_width)+(num_cells_per_figure+1)*min_gap));
        curr_x = min_gap;
        text_to_plot = nan(0, 3);
        for j=1:length(cand_starting_cell_id)
            begin_id = curr_x;
            [figure_data, text_to_plot] = fillin_data(figure_data, text_to_plot, cand_starting_cell_id(j), begin_id, offset, all_max_depth(j), all_first_valid_id, all_last_valid_id, all_daughters_id, tracedata );
            curr_x = begin_id + all_width(j) + min_gap;
        end

        % remove redundant gaps
        all_col_with_data = [0, find(~isnan(max(figure_data)) & ~isinf(max(figure_data))), size(figure_data,2)];
        id = find(diff(all_col_with_data) > min_gap + 1);
        col_to_remove = [];
        for j=1:length(id)
            col_to_remove = cat(2, col_to_remove, all_col_with_data(id(j))+min_gap+1:all_col_with_data(id(j)+1)-1);
        end
        for j=1:size(text_to_plot,1)
            text_to_plot(j,2) = text_to_plot(j,2) - length(find(col_to_remove <= text_to_plot(j,2)));
        end
        figure_data = figure_data(:, setdiff(1:size(figure_data,2), col_to_remove));
        curr_x = min(find(~isnan(max(figure_data)), 1, 'last') + min_gap, size(figure_data,2));
        figure_data = figure_data(:, 1:curr_x);
        figure_data(isinf(figure_data(:))) = 1;
        
        % plot the figure
        h = figure(1);
        imagesc(1:curr_x, start_frame:end_frame, figure_data, signal_range); hold on;
        ylabel('Frames'); xlabel('Single Cells');
        xlim([1, curr_x]); ylim([start_frame, end_frame]); 
        colormap hot

        for j=1:size(text_to_plot, 1)
            text('units', 'data', 'position', [text_to_plot(j,2), text_to_plot(j,1)+4+start_frame], 'string', num2str(text_to_plot(j,3)), 'Color', [1,1,1], 'FontSize', 3);
        end

        h.PaperUnits = 'inches';
        h.PaperPosition = [0 0 4 1.75];
        set(gca,'xtick',[]);
        set(gca,'xticklabel',[]);
        set(gca,'Ytick',0:100:num_frames)
        set(gca,'ydir','reverse')
        box off;
        print(h, [base_filename, num2str(i)], '-dpng', '-r600');
        close(h);
    catch
    end
end

end

function [ max_depth ] = add_nodes_to_lineages ( curr_depth, mother_id, all_daughters_id )
    
all_max_depth = nan(2, 1);
for j=1:2
    daughter_id = all_daughters_id(mother_id, j);
    if (isnan(daughter_id))
        all_max_depth(j) = curr_depth;
        continue;
    end
    all_max_depth(j) = add_nodes_to_lineages( curr_depth+1, daughter_id, all_daughters_id);
end
max_depth = max(all_max_depth);

end

function [ figure_data, text_to_plot ] = fillin_data( figure_data, text_to_plot, mother_id, begin_id, offset, curr_depth, all_first_valid_id, all_last_valid_id, all_daughters_id, tracedata )

% fill in mother
figure_data(all_first_valid_id(mother_id):all_last_valid_id(mother_id), begin_id+offset(curr_depth, 1)-1) = tracedata(mother_id, all_first_valid_id(mother_id):all_last_valid_id(mother_id));
text_to_plot = [text_to_plot; [all_first_valid_id(mother_id), begin_id+offset(curr_depth, 1)-1, mother_id]];

% check daughters. If no daughters, don't draw anything and return
if (isempty(find(~isnan(all_daughters_id(mother_id,:)), 1)))
    return;
end

% draw lineage tree
figure_data(all_last_valid_id(mother_id), begin_id+offset(curr_depth,1)+offset(curr_depth,2)-1:begin_id+offset(curr_depth,1)+offset(curr_depth,3)-1) = -Inf;

% draw daughter cells
if (~isnan(all_daughters_id(mother_id, 1)))
    [ figure_data, text_to_plot ] = fillin_data( figure_data, text_to_plot, all_daughters_id(mother_id,1), begin_id, offset, curr_depth-1, all_first_valid_id, all_last_valid_id, all_daughters_id, tracedata);
end
if (~isnan(all_daughters_id(mother_id, 2)))
    if (curr_depth > 2)
        [ figure_data, text_to_plot ] = fillin_data( figure_data, text_to_plot, all_daughters_id(mother_id,2), begin_id+offset(curr_depth,1), offset, curr_depth-1, all_first_valid_id, all_last_valid_id, all_daughters_id, tracedata);
    else 
        [ figure_data, text_to_plot ] = fillin_data( figure_data, text_to_plot, all_daughters_id(mother_id,2), begin_id+offset(curr_depth,1)+1, offset, curr_depth-1, all_first_valid_id, all_last_valid_id, all_daughters_id, tracedata);
    end
end

end
