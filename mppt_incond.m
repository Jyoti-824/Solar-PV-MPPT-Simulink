ainfunction Vref = mppt_incond(V, I)
%#codegen
% Incremental Conductance MPPT
% Paste this INSIDE the MATLAB Function block in your IncCond model copy
% (keep the block's V, I inputs and Vref output as-is)

persistent Vold Iold Vref_old
if isempty(Vold)
    Vold     = 0;
    Iold     = 0;
    Vref_old = 300;   % start near expected array Vmp (10 modules x 30.12V)
end

dV_step = 1.0;         % voltage step size (V) - keep same as P&O for fair comparison
epsilon = 1e-5;

deltaV = V - Vold;
deltaI = I - Iold;

if abs(deltaV) < epsilon
    % dV = 0: check dI to decide
    if abs(deltaI) < epsilon
        Vref = Vref_old;                 % at MPP, no change
    elseif deltaI > 0
        Vref = Vref_old + dV_step;
    else
        Vref = Vref_old - dV_step;
    end
else
    % Core incremental conductance test: dI/dV vs -I/V
    condTerm = deltaI/deltaV + I/V;
    if abs(condTerm) < epsilon
        Vref = Vref_old;                 % at MPP
    elseif condTerm > 0
        Vref = Vref_old + dV_step;       % left of MPP, increase V
    else
        Vref = Vref_old - dV_step;       % right of MPP, decrease V
    end
end

Vref = max(0, Vref);   % safety clamp

Vold     = V;
Iold     = I;
Vref_old = Vref;

end
