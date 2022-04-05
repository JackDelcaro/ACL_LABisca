function loss = fmincon_simulate(x, tun_pars_labels, PARAMS, fmincon_cost_handle)

for i = 1:length(tun_pars_labels)
    PARAMS.(tun_pars_labels(i)) = x(i);
end
assignin('base', 'PARAMS', PARAMS);

sim_res = sim('s0405_fmincon');

loss = fmincon_cost_handle(sim_res);

end