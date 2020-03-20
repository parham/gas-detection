

lemanchot.utils.imds2png( ...
    '/home/phm/MEGA/working_datasets/reflection_reduction/exp02_sensefly_solar_panel_reflection',...
    '*.tif', ...
    '/home/phm/MEGA/working_datasets/reflection_reduction/exp02_sensefly_solar_panel_reflection_png',@prefunc);

function [] = initPrepc ()
    global props 
    configPath = sprintf('./algorithms/image_stitching_v2/image_stitching_%s_v2_exp2.json', ...
        phm.utils.phmSystemUtils.getOSUser);
    phmConfig = phm.core.phmJsonConfigBucket(configPath);
    props = msv2PreprocessingStep(phmConfig.getConfig('preprocessing'));
end

function [res] = prefunc (img)
    global props
    res = props.process(img);
end