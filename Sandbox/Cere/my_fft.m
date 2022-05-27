function [magnitude, phase, frequency] = my_fft(vector, time)
    df = 1/(time(end)-time(1));
    N = length(vector);
    if rem(N, 2) == 1
    N = N - 1;
    end
    fmax = (N/2-1)*df;
    frequency = (0:df:fmax)';
    tmp = fft(vector);
    magnitude = zeros(N/2, 1);
    magnitude(1) = abs(tmp(1))/N;
    magnitude(2:end) = abs(tmp(2:N/2))*2/N;
    phase = angle(tmp(1:N/2));
end