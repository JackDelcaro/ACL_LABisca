

function coeffs = polynomial_fit(time,data,order,forgetting_factor)
    
    persistent is_first_iteration pinvR;
    if isempty(is_first_iteration)
        is_first_iteration = true;
    else
        is_first_iteration = false;
    end
    
    center_idx = floor(length(time)/2);
    time = time - time(center_idx);
    data = data - data(center_idx);
    N = length(time);
    R = nan(N, order);
    
    if is_first_iteration
        for j = 1:(order+1)
            R(:, j) = (time.^(order - j + 1)) .* (forgetting_factor.^((length(time)-1):-1:0)');
        end
        pinvR = pinv(R);
    end

    coeffs = pinvR*(data.*(forgetting_factor.^((length(time)-1):-1:0)'));

end