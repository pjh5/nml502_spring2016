function fig = plot_vectors(X, y)

    % Line colors
%     clrs = 'rgbcmyk';
      lns = {'-', '--', ':', '-.'};
%     dots = '+o*.sd^v><p';

    % Plot
    fig = figure;
    hold on;
    for i = 1:max(max(y))
        hold on;
        Xc = X(y == i, :);
        errorbar(1:size(X,2), mean(Xc, 1), std(Xc, 1), ...
            'linestyle', lns{mod(i,4) + 1}, 'linewidth', 2);
%             'linestyle', lns{mod(i,4)}, 'color', ...
%             lns(mod(i,7)), 'lineshape', dots(mod(i,11)), ...
    end
    hold off;
    
    % Label
    title('Feature Vectors', 'fontsize', 16);
    xlabel('Feature Dimension', 'fontsize', 16);
    ylabel({'Average Value and', 'Standard Deviation'}, 'fontsize', 16);
    
end