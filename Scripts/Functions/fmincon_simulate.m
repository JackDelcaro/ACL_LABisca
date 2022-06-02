function loss = fmincon_simulate(x, tun_pars_labels, PARAMS, fmincon_cost_handle, model_name)

if ~istable(x)
    for i = 1:length(tun_pars_labels)
        PARAMS.(tun_pars_labels(i)) = x(i);
    end
else
    for i = 1:length(tun_pars_labels)
        PARAMS.(tun_pars_labels(i)) = x.(tun_pars_labels(i));
    end
end
assignin('base', 'PARAMS', PARAMS);

sim_res = sim(model_name);

loss = fmincon_cost_handle(sim_res);

end