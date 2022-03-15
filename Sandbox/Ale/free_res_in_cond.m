function [out_vec] = free_res_in_cond(tf, time, x0)
    [num,den] = tfdata(tf,'v');    
    [A,~,~,~] = tf2ss(num, den);
    out_vec=NaN(2, length(time));
    for i=1:length(time)
        out_vec(:,i) = x0*expm(A*time(i));
    end
end