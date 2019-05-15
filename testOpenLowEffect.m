% A���г�����T+1���׼�ɢ�����������������Ϳ�ЧӦ��������Ʒ��û������ص㣺

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

% ����������
basicData.DR1 = log(basicData.AdjOpen ./ basicData.LastAdjClose); % ���������ǰ����
basicData.DR2 = log(basicData.AdjClose ./ basicData.AdjOpen); % ����������ڽ���
basicData.DR = basicData.DR1 + basicData.DR2;
% basicData.DRCheck = log(basicData.AdjClose ./ basicData.LastAdjClose);
% basicData.DRCheckLabel = (round(basicData.DR, 4) == round(basicData.DRCheck, 4)) | (isnan(basicData.DR));


meanDR = splitapply(@(x) mean(x, 'omitnan'), basicData.DR, basicData.Group);
meanDR1 = splitapply(@(x) mean(x, 'omitnan'), basicData.DR1, basicData.Group);
meanDR2 = splitapply(@(x) mean(x, 'omitnan'), basicData.DR2, basicData.Group);

meanDR = table(unique(basicData.Variety), meanDR, 'VariableNames', {'Variety', 'MeanDR'});
meanDR.MeanDR1 = meanDR1;
meanDR.MeanDR2 = meanDR2; % ����meanDR1 + meanDR2 �� meanDR ��Ϊ��Ʒ�ֵĵ�һ��meanDR1��meanDR����NaN��meanDR2����

meanDR.AnnualR = meanDR.MeanDR * 244;
meanDR.AnnualR1 = meanDR.MeanDR1 * 244;
meanDR.AnnualR2 = meanDR.MeanDR2 * 244;






