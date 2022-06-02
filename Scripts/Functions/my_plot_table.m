function [f_handle, graphs_handles, subplot_handles] = my_plot_table(X, varargin)
    labels = string(X.Properties.VariableNames)';
    plot_number = length(labels);
    
    f_handle = gcf; hold on;
    
    font_size = max(17 - floor(plot_number/3), 12);
    set(f_handle,'defaultAxesFontSize',font_size);
    set(f_handle,'defaultTextFontSize',font_size);
    
    is_cell_title = @(x) cellfun(@(y)(isstring(y)||ischar(y)) && contains(y, {'title', 'Title'}),x,'UniformOutput',1);
    if any(is_cell_title(varargin))
        title_index = find(is_cell_title(varargin)) + 1;
        title_label = varargin(title_index);
        sgtitle(title_label{1});
        varargin(title_index-1:title_index) = [];
    end
    
    pos_1_1 = [0.1300    0.8749    0.0501    0.0501];
    pos_n_n = [0.8549    0.1511    0.0501    0.0090];
    
    top_pos = pos_1_1(2) + pos_1_1(4);
    bot_pos = pos_n_n(2);
    left_pos = pos_1_1(1);
    right_pos = pos_n_n(1) + pos_n_n(3);
    ver_spacing = 0.015;
    hor_spacing = ver_spacing;
    single_height = (top_pos - bot_pos - (plot_number-1)*ver_spacing)/plot_number;
    single_width = (right_pos - left_pos - (plot_number-1)*hor_spacing)/plot_number;
    
    graphs_handles = [];
    subplot_handles = [];
    for i = 1:plot_number
        for j = 1:i
            subplot_handles(i,j) = subplot(plot_number, plot_number, (i-1)*plot_number+j); %#ok<AGROW>
            set(subplot_handles(i,j), 'Position',...
                [left_pos + (j-1)*single_width + (j-1)*hor_spacing,...
                top_pos - i*single_height - (i-1)*ver_spacing,...
                single_width, single_height]);
            graphs_handles(i,j) = scatter(X.(labels(j)),X.(labels(i)),varargin{:}); %#ok<AGROW>
            if i == plot_number
                xlabel(strrep(labels(j),'_','\_'), 'Rotation', 30, 'HorizontalAlignment', 'right');
            else
                set(subplot_handles(i,j), 'XTickLabel', []);
            end
            if j == 1
                ylabel(strrep(labels(i),'_','\_'), 'Rotation', 0, 'HorizontalAlignment', 'right');
            else
                set(subplot_handles(i,j), 'YTickLabel', []);
            end
            hold on; box on; grid on;
        end
    end
    
    colorbar('Position', [pos_n_n(1)+pos_n_n(3)+hor_spacing, pos_n_n(2), 0.015, pos_1_1(2)+pos_1_1(4)-pos_n_n(2)]);
end