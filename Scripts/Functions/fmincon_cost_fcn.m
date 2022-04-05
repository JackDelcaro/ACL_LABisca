function loss = fmincon_cost_fcn(sim_res, dataset, weights)

time = sim_res.theta.Time;

theta_meas = interp1(dataset.time, dataset.theta, time, 'linear', 'extrap')*180/pi;
alpha_meas = interp1(dataset.time, dataset.alpha, time, 'linear', 'extrap')*180/pi;
theta_dot_meas = interp1(dataset.time, dataset.theta_dot, time, 'linear', 'extrap')*180/pi;
alpha_dot_meas = interp1(dataset.time, dataset.alpha_dot, time, 'linear', 'extrap')*180/pi;

rms_theta = sqrt(mean((theta_meas - sim_res.theta.Data*180/pi).^2));
rms_alpha = sqrt(mean((alpha_meas - sim_res.alpha.Data*180/pi).^2));
rms_theta_dot = sqrt(mean((theta_dot_meas - sim_res.theta_dot.Data*180/pi).^2));
rms_alpha_dot = sqrt(mean((alpha_dot_meas - sim_res.alpha_dot.Data*180/pi).^2));

loss = weights.theta*rms_theta + weights.alpha*rms_alpha + ...
       weights.theta_dot*rms_theta_dot + weights.alpha_dot*rms_alpha_dot;
end