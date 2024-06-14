function plot_swarm

dfs = '../cMyoSim/progress/progress.xlsx';
no_of_params = 17;
no_of_particles = 34;

d = readtable(dfs);

figure(1);
clf;

keep_going = 1;

counter = 1;
while (keep_going)

    vi = []
    for i = 1 : no_of_particles
        for j = 1 : no_of_params
            x(i,j) = d.(sprintf('p_%i', j))(counter);
        end
        counter = counter + 1;
    end
    if (counter == (no_of_particles + 1))
        x_last = NaN * x;
    end

    vi = 1 : no_of_particles;
    for r = 1 : no_of_params
        for c = 1 : r
            subplot(no_of_params, no_of_params, (r-1)*no_of_params + c);
            cla
            hold on;
            plot(x_last(vi, r), x_last(vi, c), 'ro')
            plot(x(vi, r), x(vi, c), 'bo');

            % plot([x_last(vi, r) x(vi,r)]',[x_last(vi,c) x(vi, c)]', 'b-')
            xlim([0 1])
            ylim([0 1])
        end
    end

    x_last = x;

    drawnow;
    pause(0.5)

    if (counter == size(d,1))
        keep_going = 0;
    end
end

% 
% counter = 1;
% 
% for r = 1 : no_of_params
%     for c = 1 : r
%         subplot(r,r,(r-1)*no_of_params + c)
%         for i = 1 : no_of_particles
%             x_str = sprintf('p_%i', r);
%             y_str = sprintf('p_%i', c);
%             x(i,r) = d.(x_str)(counter);
%             y(i,r) = d.(y_str)(counter);
% 
% 


