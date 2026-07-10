%% analyze_results.m  (v2 - uses Vout only, Pout computed via R_load)
% Run this AFTER both simulations (P&O and IncCond) have completed and
% their To Workspace signals are sitting in your base workspace as
% timeseries objects:
%
%   Required variable names (edit if yours differ):
%   Vpv_po, Ipv_po, Vout_po   <- from PV_MPPT_PandO_Final.slx run
%   Vpv_ic, Ipv_ic, Vout_ic   <- from PV_MPPT_IncCond_Final.slx run
%
% Workflow:
%   Run PO model, then:
%     save('po_results.mat','Vpv_po','Ipv_po','Vout_po')
%   Run IncCond model, then:
%     save('ic_results.mat','Vpv_ic','Ipv_ic','Vout_ic')
%   Then: load('po_results.mat'); load('ic_results.mat'); analyze_results

clear results
R_load = 4;                    % ohms - your load resistor
irr_change_times = [3 5 6 9];  % matches your irradiance+temp step times
band = 0.02;                    % +/-2% settling band

algos = {'po','ic'};
names = {'P&O','Incremental Conductance'};

for a = 1:2
    tag = algos{a};
    V  = eval(sprintf('Vpv_%s', tag));
    I  = eval(sprintf('Ipv_%s', tag));
    Vo = eval(sprintf('Vout_%s', tag));

    t   = V.Time;
    Vv  = V.Data;
    Ii  = I.Data;
    Pin = Vv .* Ii;

    Vov  = Vo.Data;
    Pout = (Vov.^2) / R_load;   % derived via Ohm's law, no current sensor needed

    % --- Overall average efficiency (steady portions only, skip first 0.5s) ---
    mask_steady = t > 0.5;
    eta_avg = 100 * mean(Pout(mask_steady)) / mean(Pin(mask_steady));

    % --- Settling time & overshoot after each irradiance/temp step ---
    settle_times = zeros(size(irr_change_times));
    overshoots   = zeros(size(irr_change_times));

    for k = 1:length(irr_change_times)
        t0 = irr_change_times(k);
        if k < length(irr_change_times)
            t1 = irr_change_times(k+1);
        else
            t1 = t0 + 1.5;
        end
        idx = t >= t0 & t <= t1;
        tt = t(idx); pp = Pin(idx);
        if isempty(pp), continue; end

        P_final = mean(pp(max(1,end-50):end)); % settled value estimate
        band_lo = P_final * (1 - band);
        band_hi = P_final * (1 + band);

        inside = pp >= band_lo & pp <= band_hi;
        idx_settle = find(inside, 1, 'first');
        if ~isempty(idx_settle)
            settle_times(k) = tt(idx_settle) - t0;
        else
            settle_times(k) = NaN;
        end

        overshoots(k) = 100 * (max(pp) - P_final) / P_final;
    end

    results.(tag).eta_avg      = eta_avg;
    results.(tag).settle_times = settle_times;
    results.(tag).overshoots   = overshoots;
    results.(tag).t            = t;
    results.(tag).Pin          = Pin;
    results.(tag).Pout         = Pout;
end

%% --- Print comparison table ---
fprintf('\n================ MPPT ALGORITHM COMPARISON ================\n');
fprintf('%-28s %10s %10s\n', 'Metric', 'P&O', 'IncCond');
fprintf('%-28s %9.2f%% %9.2f%%\n', 'Avg tracking efficiency', ...
    results.po.eta_avg, results.ic.eta_avg);
fprintf('%-28s %9.3fs %9.3fs\n', 'Avg settling time', ...
    mean(results.po.settle_times,'omitnan'), mean(results.ic.settle_times,'omitnan'));
fprintf('%-28s %9.2f%% %9.2f%%\n', 'Avg overshoot', ...
    mean(results.po.overshoots,'omitnan'), mean(results.ic.overshoots,'omitnan'));
fprintf('==============================================================\n\n');

%% --- Plot comparison ---
figure('Name','MPPT Comparison','Color','w');

subplot(2,1,1);
plot(results.po.t, results.po.Pin, 'b', 'LineWidth', 1.2); hold on;
plot(results.ic.t, results.ic.Pin, 'r', 'LineWidth', 1.2);
xlabel('Time (s)'); ylabel('P_{PV} (W)');
title('PV Power Tracking: P&O vs Incremental Conductance');
legend('P&O','Incremental Conductance','Location','southeast');
grid on;

subplot(2,1,2);
plot(results.po.t, 100*results.po.Pout./results.po.Pin, 'b', 'LineWidth', 1.2); hold on;
plot(results.ic.t, 100*results.ic.Pout./results.ic.Pin, 'r', 'LineWidth', 1.2);
xlabel('Time (s)'); ylabel('Efficiency (%)');
title('Instantaneous Conversion Efficiency');
legend('P&O','Incremental Conductance','Location','southeast');
ylim([0 105]);
grid on;

saveas(gcf, 'mppt_comparison.png');
fprintf('Plot saved as mppt_comparison.png\n');
