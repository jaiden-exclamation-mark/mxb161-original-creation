num_steps = 250;
simulation_size = 100;
verbose = true;
plot = true;

disp("Starting wildfire benchmark with " + num_steps + " steps...");

sim = WildfireSimulation(CellState(2 * ones(simulation_size, simulation_size)), -0.5 * ones(simulation_size, simulation_size));
sim.constant_ignition_probability = 0.75;
sim.continued_burn_probability = 0.5;

break_start = floor(simulation_size / 4);
break_end = floor(3 * simulation_size / 4);

sim.state(break_start:break_end, break_start:break_end) = CellState.NoFuel;
sim.state(1, 1) = CellState.Burning;
sim.plot();

erase_line = " \x1b[2K\x1b[0G";
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
    end

    if plot
        sim.plot();
        drawnow;
    end
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