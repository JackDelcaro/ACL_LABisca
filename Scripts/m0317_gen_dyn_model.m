% Define dof and their derivatives

syms th al real;
syms th_dot al_dot real;
syms th_ddot al_ddot real;
syms tau real;

q = [th; al];
q_dot = [th_dot; al_dot];
q_ddot = [th_ddot; al_ddot];

% Call dynamic model scripts

run([dyn_model_name '.m']);
run([cable_model_name '.m']);
run([friction_model_name '.m']);

%% Differentiate to find the EOM

lhs_th = simplify(B(1, :) * q_ddot + q_dot' * C(:, :, 1) * q_dot + R(1, :) * q_dot + G(1), 20);
lhs_al = simplify(B(2, :) * q_ddot + q_dot' * C(:, :, 2) * q_dot + R(2, :) * q_dot + G(2), 20);

eqn_th = lhs_th == tau;
eqn_al = lhs_al == 0;

[th_ddot, al_ddot] = solve([eqn_th eqn_al], [th_ddot al_ddot]);

th_ddot = simplify(th_ddot, 20);
al_ddot = simplify(al_ddot, 20);

MODEL_STRUCT.B.sym_expr = B;
MODEL_STRUCT.C.sym_expr = C;
MODEL_STRUCT.R.sym_expr = R;
MODEL_STRUCT.G.sym_expr = G;
MODEL_STRUCT.th_ddot_fun.sym_exp = th_ddot;
MODEL_STRUCT.al_ddot_fun.sym_exp = al_ddot;

B_fun = B;
C_fun = C;
R_fun = R;
G_fun = G;
th_ddot_fun = th_ddot;
al_ddot_fun = al_ddot;

fn = fieldnames(model_PARAMS);
for i=1:numel(fn)
    B_fun = simplify(subs(B_fun, model_PARAMS.(fn{i}), PARAMS.(fn{i})), 10);
    C_fun = simplify(subs(C_fun, model_PARAMS.(fn{i}), PARAMS.(fn{i})), 10);
    R_fun = simplify(subs(R_fun, model_PARAMS.(fn{i}), PARAMS.(fn{i})), 10);
    G_fun = simplify(subs(G_fun, model_PARAMS.(fn{i}), PARAMS.(fn{i})), 10);
    th_ddot_fun = simplify(subs(th_ddot_fun, model_PARAMS.(fn{i}), PARAMS.(fn{i})), 10);
    al_ddot_fun = simplify(subs(al_ddot_fun, model_PARAMS.(fn{i}), PARAMS.(fn{i})), 10);
end
matlabFunctionBlock([model_name '/Simulator Subsystem/dyn_model'], ...
                    th_ddot_fun, al_ddot_fun, ...
                    'vars', [th, th_dot, tau, al, al_dot], ...
                    'outputs', {'th_ddot', 'al_ddot'});
                
MODEL_STRUCT.B.num_expr = B_fun;
MODEL_STRUCT.C.num_expr = C_fun;
MODEL_STRUCT.R.num_expr = R_fun;
MODEL_STRUCT.G.num_expr = G_fun;
MODEL_STRUCT.th_ddot_fun.num_exp = th_ddot_fun;
MODEL_STRUCT.al_ddot_fun.num_exp = al_ddot_fun;
                
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