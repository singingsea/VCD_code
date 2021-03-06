function [scd,scd_err] = calc_scds_o3(dscd_S, daily_rcd)
% scd,scd_err] = calc_scds_o3(dscd_S, daily_rcd)
% Written by: Cristen Adams, Dec 2010
% modified by: Xiaoyi Zhao, Nov 2017
%
% INPUT
%       dscd_S: structure containing dscds
%       daily_rcd: structure containing rcds
%
% OUTPUT:
%       scd: vector containing SCDs for corresponding with the indices
%       of the dscd_S structure
%       scd_err: the total error error on the scd
% 
% Xiaoyi --- an uncertainty calculation log will be saved

% create a txt log to save who the uncertainty was calculated
fid = fopen('uncertainty_calculation_log.txt','a+');

fprintf(fid, '\r\n%s \r\n', 'Detailed uncertainty calculation for scds can be found in "calc_scds_o3"');
t = datestr(datetime('now'));
fprintf(fid, '%s : \r\n', t);

L = length(dscd_S.day);
scd = NaN * ones(L,1);
rcd_err = NaN * ones(L,1);
for i = 1:length(daily_rcd.mean.day)
    ind = find(dscd_S.day == daily_rcd.mean.day(i));
    scd(ind) = dscd_S.mol_dscd(ind) + (daily_rcd.mean.rcd(i));
    rcd_err(ind) = sqrt( 1e18 .^2 + (daily_rcd.mean.diff(i)*0.5)^2);
end
A = isfield(dscd_S,'x');
if (A == 1) 
    %scd_sys_err =sqrt( (0.02).^2 + (3*dscd_S.err ./ scd).^2 + ((dscd_S.x *
    %1e17)./dscd_S.mol_dscd).^2 ).*scd; % this 0.02 value was first found
    %in Cristen's original code. Cristen's thesis used value of 0.034, and
    %she confirmed we should use this one. Data generated for NDACC in 2017
    %start use 0.034 (before that, data, such as the ones for ACE archive was 0.02)
    if ~isempty(dscd_S.x)
        scd_sys_err =sqrt( (0.034).^2 + (3*dscd_S.err ./ scd).^2 + ((dscd_S.x * 1e17)./dscd_S.mol_dscd).^2 ).*scd;        
        loginfo = 'SCD sys err was calculated with err from x xs';
        disp(loginfo);
        fprintf(fid, '%s \r\n', loginfo);
    else
        loginfo = 'Warning: We found dscd_S.x in dscd_S structure, but it is empty!!!';
        disp(loginfo);
        fprintf(fid, '%s \r\n', loginfo);
        
        scd_sys_err =sqrt( (0.034).^2 + (3*dscd_S.err ./ scd).^2).*scd;
        loginfo = 'SCD sys err was calculated without err from x xs';
        disp(loginfo);
        fprintf(fid, '%s \r\n', loginfo);
    end
elseif A == 0
    %scd_sys_err =sqrt( (0.02).^2 + (3*dscd_S.err ./ scd).^2).*scd;
    scd_sys_err =sqrt( (0.034).^2 + (3*dscd_S.err ./ scd).^2).*scd;
    loginfo = 'SCD sys err was calculated without err from x xs'
    disp(loginfo);
    fprintf(fid, '%s \r\n', loginfo);
end
if ~isempty(scd_sys_err)
    scd_err = sqrt(rcd_err.^2 + scd_sys_err.^2);
    loginfo = 'SCD err was calculated with rcd_err and scd_sys_err';
    disp(loginfo);
    fprintf(fid, '%s \r\n', loginfo);
else
    scd_err = rcd_err;
    loginfo = 'SCD err was calculated with only rcd_err (no scd_sys_err)';
    disp(loginfo);
    fprintf(fid, '%s \r\n', loginfo);
end

fclose(fid);
