num_steps = 100;

disp("Starting wildfire benchmark with " + num_steps + " steps...");

sim = WildfireSimulation(CellState(2 * ones(100, 100)), -0.5 * ones(100, 100));
sim.constant_ignition_probability = 0.75;
sim.continued_burn_probability = 0.5;

sim.state(40:60, 40:60) = CellState.NoFuel;
sim.state(1, 1) = CellState.Burning;
sim.plot();

step_time_stats = zeros(1, num_steps);
current_step_start = inf;
current_step_end = inf;
for i = 1:num_steps
    disp("Starting step " + i + "...");
    current_step_start = posixtime(datetime());
    sim = sim.step();
    current_step_end = posixtime(datetime());
    step_time_stats(i) = current_step_end - current_step_start;
    disp("Completed step " + i + " in " + step_time_stats(i) + " seconds!");
    sim.plot();
    drawnow;
end

disp("Benchmark completed!");
disp("--------------------");

disp("Mean step time: " + mean(step_time_stats) + "s");
disp("Median step time: " + median(step_time_stats) + "s");
disp("Step time range: " + min(step_time_stats) + "-" + max(step_time_stats) + "s");