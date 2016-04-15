function fig = plot_vectors(X, y)

    % Plot
    fig = figure;
    hold on;
    for i = 1:max(max(y))
        hold on;
        Xc = X(y == i, :);
        errorbar(1:size(X,2), mean(Xc, 1), std(Xc, 1), 'linewidth', 2);
    end
    hold off;
    
    % Label
    title('Feature Vectors', 'fontsize', 16);
    xlabel('Feature Dimension', 'fontsize', 16);
    ylabel({'Average Value and', 'Standard Deviation'}, 'fontsize', 16);
    
end