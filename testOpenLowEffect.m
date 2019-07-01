% A股市场由于T+1交易及散户主导，存在显著低开效应，测试商品有没有这个特点：

% DR = ln(close1 / close0) = ln(open1 / close0) + ln(close1 / open1) 

load('\\CJ-LMXUE-DT\futureData_fromWind\priceData\Dly\TableData_main_v2.mat')
basicData = TableData(:, {'date', 'open', 'close', 'high', 'low', 'settle', 'adjfactor', 'multifactor', 'mainCont'});
basicData.AdjClose = basicData.close .* basicData.adjfactor;
basicData.AdjOpen = basicData.open .* basicData.adjfactor;
basicData.Variety = regexp(basicData.mainCont, '[A-Z]+', 'match');
basicData.Variety = cellfun(@char, basicData.Variety, 'UniformOutput', false);

basicData = sortrows(basicData, {'Variety', 'date'});
basicData.Group = findgroups(basicData.Variety);

basicData.ShiftLabel = [1;diff(basicData.Group) ~= 0];
basicData.LastAdjClose = [NaN; basicData.AdjClose(1:end-1)];
basicData.LastAdjClose(basicData.ShiftLabel == 1) = NaN;

% 计算收益率
basicData.DR1 = log(basicData.AdjOpen ./ basicData.LastAdjClose); % 今开盘相对于前收盘
basicData.DR2 = log(basicData.AdjClose ./ basicData.AdjOpen); % 今收盘相对于今开盘
basicData.DR = basicData.DR1 + basicData.DR2;
% basicData.DRCheck = log(basicData.AdjClose ./ basicData.LastAdjClose);
% basicData.DRCheckLabel = (round(basicData.DR, 4) == round(basicData.DRCheck, 4)) | (isnan(basicData.DR));


meanDR = splitapply(@(x) mean(x, 'omitnan'), basicData.DR, basicData.Group);
meanDR1 = splitapply(@(x) mean(x, 'omitnan'), basicData.DR1, basicData.Group);
meanDR2 = splitapply(@(x) mean(x, 'omitnan'), basicData.DR2, basicData.Group);

meanDR = table(unique(basicData.Variety), meanDR, 'VariableNames', {'Variety', 'MeanDR'});
meanDR.MeanDR1 = meanDR1;
meanDR.MeanDR2 = meanDR2; % 这里meanDR1 + meanDR2 ≈ meanDR 因为换品种的第一个meanDR1和meanDR都是NaN但meanDR2有数

meanDR.AnnualR = meanDR.MeanDR * 244;
meanDR.AnnualR1 = meanDR.MeanDR1 * 244;
meanDR.AnnualR2 = meanDR.MeanDR2 * 244;

% 筛选上市时间在2017年以前的商品及全部的股指和国债期货
load('E:\futureDataBasic\infoData\basicInfo.mat')
varSelec = basicInfo(basicInfo.listDate <= 20170101 |(ismember(basicInfo.wiindType, {'stkF', 'bondF'})) , :);
basicData = basicData(ismember(basicData.Variety, varSelec.future), :);

% 看每年是否表现明显，画累积收益曲线
% 用splitapply必须保证Group是连续的正整数
basicData.Group = findgroups(basicData.Variety);
basicData.DR1 = arrayfun(@(x, y, z) ifelse(isnan(x), 0, x), basicData.DR1);
DR1Cell = splitapply(@(x){cumprod(x + 1) - 1}, basicData.DR1, basicData.Group); 
basicData.Cum1 = vertcat(cell2mat(DR1Cell));

basicData.DR2 = arrayfun(@(x, y, z) ifelse(isnan(x), 0, x), basicData.DR2);
DR2Cell = splitapply(@(x){cumprod(x + 1) - 1}, basicData.DR2, basicData.Group);
basicData.Cum2 = vertcat(cell2mat(DR2Cell));

cum1 = unstack(basicData(:, {'date', 'Variety', 'Cum1'}), 'Cum1', 'Variety');
cum2 = unstack(basicData(:, {'date', 'Variety', 'Cum2'}), 'Cum2', 'Variety');

%% 画图


% 先画股指期货，确认每年确实有高开效应
cum1Stock = cum1(:, {'date', 'IF', 'IC', 'IH'});
cum2Stock = cum2(:, {'date', 'IF', 'IC', 'IH'});
dn = datenum(num2str(cum1.date), 'yyyymmdd');
for iCol = 1:width(cum1Stock) - 1
    plot(dn, table2array(cum1Stock(:, iCol + 1)))
    datetick('x', 'yyyymm', 'keepticks', 'keeplimits')
    hold on
end
for iCol = 1:width(cum2Stock) - 1
    plot(dn, table2array(cum2Stock(:, iCol + 1)))
    datetick('x', 'yyyymm', 'keepticks', 'keeplimits')
    hold on
end

% 再画商品期货
varCommodity = setdiff(cum1.Properties.VariableNames, {'IF', 'IC', 'IH', 'T', 'TF', 'TS'});
cum1Commodity = cum1(:, varCommodity);
cum2Commodity = cum2(:, varCommodity);
dn = datenum(num2str(cum1.date), 'yyyymmdd');
for iCol = 1:width(cum1Commodity) - 1
    plot(dn, table2array(cum1Commodity(:, iCol)))
    datetick('x', 'yyyymm', 'keepticks', 'keeplimits')
    hold on
end
close
for iCol = 1:width(cum2Commodity) - 1
    plot(dn, table2array(cum2Commodity(:, iCol)))
    datetick('x', 'yyyymm', 'keepticks', 'keeplimits')
    hold on
end















