% Please refrain from including this file in a commit if you've just changed the parameters!
% Parameters

% Simulation parameters
num_steps = 250;
simulation_size = 100;

% Replaces progress bar while benchmark is running with more information.
verbose = false;

% Plot after each step (dramatically increases runtime)
plot = false;

% If you're running this in MATLAB's Command Window, set this to false.
% If you're running this in a terminal, set this to true.
ansi_compatible = false;

% Setting up the simulation

disp("Starting wildfire benchmark with " + num_steps + " steps...");

sim = WildfireSimulation(CellState(2 * ones(simulation_size, simulation_size)));
sim.vegetation = -0.5 * ones(simulation_size, simulation_size);
sim.constant_ignition_probability = 0.75;
sim.continued_burn_probability = 0.5;

centre_index = ceil(simulation_size / 2);
elevation_matrix = zeros(simulation_size);
fprintf("Constructing elevation matrix... ");
for i = centre_index - 1:-1:0
    elevation_matrix(centre_index + (-i:i), centre_index + (-i:i)) = centre_index - i;
end
elevation_matrix = elevation_matrix ./ max(max(elevation_matrix));
elevation_matrix = exp(elevation_matrix .^ 2);
fprintf("done.\n");

fprintf("Setting simulation slope matrix... ");
sim = sim.set_slope_matrix(elevation_matrix);
fprintf("done.\n");

break_mask = false(simulation_size);

break_width = floor(3 * simulation_size / 4);
break_row_start = floor(3 * simulation_size / 8);
break_row_end = floor(5 * simulation_size / 8);

break_mask(break_row_start:break_row_end, 1:break_width) = true;

sim.state(break_mask) = CellState.NoFuel;

sim.state(1, 1) = CellState.Burning;
sim.plot();

% Benchmark
if ansi_compatible
    erase_line = " \x1b[2K\x1b[0G"; % ANSI escape sequence to erase the line then go to the zeroth column.
else
    erase_line = "\n";
end
step_time_stats = zeros(1, num_steps);
current_step_start = inf;
current_step_end = inf;
for i = 1:num_steps
    if verbose
        fprintf(erase_line + "Starting step %d/%d... ", i, num_steps);
    end

    current_step_start = posixtime(datetime());
    sim = sim.step();
    current_step_end = posixtime(datetime());
    step_time_stats(i) = current_step_end - current_step_start;

    if verbose
        fprintf("completed in %f seconds.", step_time_stats(i));
    else
        segments = 32;
        num_filled_segments = floor(segments * i / num_steps);
        filled_segments = repmat('■', 1, num_filled_segments);
        unfilled_segments = repmat('-', 1, segments - num_filled_segments);
        fprintf(erase_line + "[%s%s] (%d/%d)", filled_segments, unfilled_segments, i, num_steps);
    end

    if plot
        sim.plot();
        drawnow;
    end
end

if ~plot
    sim.plot();
    drawnow;
end

fprintf("\n");
disp("--------------------");
disp("Benchmark completed!");
disp("--------------------");

disp("For a benchmark of " + i + " steps on a " + simulation_size + "x" + simulation_size + " grid:")
disp("Total runtime: " + sum(step_time_stats) + "s");
disp("Mean step time: " + mean(step_time_stats) + "s");
disp("Median step time: " + median(step_time_stats) + "s");
disp("Step time range: " + min(step_time_stats) + "-" + max(step_time_stats) + "s");