function [enhancementFactor]= process_data(files_return,num_avg,handles)
path = 'D:\code\SavedExperiments\';

for j=1:size(files_return,1)
    disp(['... Processing file ' num2str(j)]);
    dnp_2=make_fn(files_return{j},path);
    [summed_efactor(j), enhancementFactor_1(j), enhancementFactor_2(j),...
    therm_spec_scaled, dnp_spec_scaled, ...
    fwhm_dnp_0, fwhm_phased_dnp,fwhm_dnp_baselined, width, ...
    signal_bs, signal_raw, signal_phase0, signal_phase1,...
    area_summed_dnp,area_summed_dnp_1,area_summed_dnp_2,area_trapz_dnp,area_trapz_dnp2,muller_area(j), area_fwhm_dnp,area_fixed_fwhm_dnp,ph0_val(j)] = process_enhancement_expedite(dnp_2,num_avg);
end
ratios = summed_efactor./muller_area;
enhancementFactor = median(ratios)*muller_area.*sign(ph0_val);  

end
