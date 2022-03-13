% Define dof and their derivatives

syms th al real;
syms th_dot al_dot real;
syms th_ddot al_ddot real;
syms tau real;

% Call dynamic model scripts

run([dyn_model_name '.m']);
run([cable_model_name '.m']);
run([friction_model_name '.m']);

%% Differentiate to find the EOM

dL_dq = simplify(gradient(L, [th al]), 20);
dL_dqdot = simplify(gradient(L, [th_dot al_dot]), 20);
dLdqdot_dt(1, :) = simplify(gradient(dL_dqdot(1), [th al th_dot al_dot])' * ...
                                                  [th_dot; al_dot; th_ddot; al_ddot], 20);
dLdqdot_dt(2, :) = simplify(gradient(dL_dqdot(2), [th al th_dot al_dot])' * ...
                                                  [th_dot; al_dot; th_ddot; al_ddot], 20);
                                           
dD_dqdot = simplify(gradient(D, [th_dot al_dot]), 20);
                                      
lhs_th = dLdqdot_dt(1) - dL_dq(1) + dD_dqdot(1);
lhs_al = dLdqdot_dt(2) - dL_dq(2) + dD_dqdot(2);

eqn_th = lhs_th == tau;
eqn_al = lhs_al == 0;

[th_ddot, al_ddot] = solve([eqn_th eqn_al], [th_ddot al_ddot]);

th_ddot = simplify(th_ddot, 20);
al_ddot = simplify(al_ddot, 20);

th_ddot_fun = th_ddot;
al_ddot_fun = al_ddot;

fn = fieldnames(model_PARAMS);
for i=1:numel(fn)
    th_ddot_fun = simplify(subs(th_ddot_fun, model_PARAMS.(fn{i}), PARAMS.(fn{i})), 10);
    al_ddot_fun = simplify(subs(al_ddot_fun, model_PARAMS.(fn{i}), PARAMS.(fn{i})), 10);
end
matlabFunctionBlock([model_name '/Simulator Subsystem/dyn_model'], ...
                    th_ddot_fun, al_ddot_fun, ...
                    'vars', [th, th_dot, tau, al, al_dot], ...
                    'outputs', {'th_ddot', 'al_ddot'});
                
fn = fieldnames(cable_model_PARAMS);
for i=1:numel(fn)
    tau_cable = simplify(subs(tau_cable, cable_model_PARAMS.(fn{i}), PARAMS.(fn{i})), 10);
end
matlabFunctionBlock([model_name '/Simulator Subsystem/cable_model'], ...
                    tau_cable, 'vars', [th, th_dot]);
                
fn = fieldnames(friction_model_PARAMS);
for i=1:numel(fn)
    tau_friction = simplify(subs(tau_friction, friction_model_PARAMS.(fn{i}), PARAMS.(fn{i})), 10);
end
matlabFunctionBlock([model_name '/Simulator Subsystem/friction_model'], ...
                    tau_friction, 'vars', [th_dot, tau_res]);