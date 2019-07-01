% 一次性更新一个时间段的TableData_main_v2时，有时候会遇到ATR价格取得不对导致ATR计算有误的问题，不定期check一下这个问题

load('E:\futureDataBasic\priceData\Dly\TableData_main_v2.mat')

% 核对14列trABS计算有没有错误
TableData.Variety = regexp(TableData.mainCont, '\D+', 'match');
TableData.Variety = cellfun(@char, TableData.Variety, 'UniformOutput', false);
TableData = sortrows(TableData, {'Variety', 'date'});
group = findgroups(TableData.Variety);

% TR = max{|high - low|, |high - close(1)|, |low - close(1)|}
res = splitapply(@(x1,x2,x3){calTR(x1,x2,x3)}, TableData.high, TableData.low, TableData.close, group);
TR = vertcat(res{:});

replaceLabel = findgroups(TableData.mainCont);
replaceLabel = [0; diff(replaceLabel)];
replaceCloseLabel = find(replaceLabel) - 1;
replaceClose = table(TableData.date(replaceCloseLabel), TableData.mainCont(logical(replaceLabel)), ...
    'VariableNames', {'Date', 'ContName'});
replaceClose.Variety = regexp(replaceClose.ContName, '\D+', 'match');
replaceClose.Month = regexp(replaceClose.ContName, '\d+', 'match');
replaceClose.Variety = cellfun(@char, replaceClose.Variety, 'UniformOutput', false);
replaceClose.Month = cellfun(@char, replaceClose.Month, 'UniformOutput', false);

codeName = getVarietyCode();
replaceClose = outerjoin(replaceClose, codeName, 'type', 'left', 'MergeKeys', true,...
    'LeftKeys', 'Variety', 'RightKeys', 'ContName');
replaceClose.NewContName = arrayfun(@(x, y, z) ifelse(strcmp(x, 'CZC'), y{:}(2:end), y{:}), ...
    replaceClose.Suffix, replaceClose.Month, replaceClose.Month, 'UniformOutput', false);

replaceClose.WindCode = strcat(replaceClose.Variety_ContName, ...
    replaceClose.NewContName, '.', replaceClose.Suffix);

conn = database('wind_fsync','query','query','com.microsoft.sqlserver.jdbc.SQLServerDriver',...
    'jdbc:sqlserver://10.201.4.164:1433;databaseName=wind_fsync');

for iRow = 1:height(replaceClose)
    iDate = replaceClose.Date(iRow);
    iWindCode = replaceClose.WindCode(iRow);
    sql = ['select S_INFO_WINDCODE, TRADE_DT, S_DQ_CLOSE from CCOMMODITYFUTURESEODPRICES where',...
    ' TRADE_DT = ',num2str(iDate),' and S_INFO_WINDCODE = ''', iWindCode{:}, ''' and FS_INFO_TYPE = 2'];
    cursorA = exec(conn,sql);
    cursorB = fetch(cursorA);
    if strcmp(cursorB.Data{1}, 'No Data')
        iClose = NaN; % 每个品种的第一天，让它往上读当前最新日期是读不到数据的，这个最后也会都调整成NaN 不用担心
    else
        iClose = cursorB.Data{3};
    end
    replaceClose.ReplaceClose(iRow) = iClose;
end

TableData.ReplaceClose(logical(replaceLabel)) = replaceClose.ReplaceClose;
replaceRes = splitapply(@(x1,x2,x3){max([abs(x1 - x2), abs(x2 - x3), abs(x1 - x3)], [], 2)}, TableData.high, TableData.low, TableData.ReplaceClose, group);
replaceTR = vertcat(replaceRes{:});

TR(logical(replaceLabel)) = replaceTR(logical(replaceLabel));


%% 最后对每个品种开始的第一天做一个NaN处理
initIdx = [0; diff(group)]; % 其实应该是[1; diff(group)];但是漫雪TableData第一个品种trABS有数，那就先保留，反正也不check前面几年
TR(logical(initIdx)) = NaN;
% 这一步是有必要的，因为有的品种比较新J，第一天出现的品种在最新日期可能还能读到数据，所以一定要手动调第一天NaN

%% 核对
% 这个地方只对2015年以后的结果进行核对，因为CZC统一都去掉一位所以前面不该去的部分自然是对不上的。保证后面更新的数据没问题即可
checkData = TableData;
checkData.NewTRABS = TR;
checkData = checkData(checkData.date >= 20190101, :); % 只检查2019年以后更新的
checkData.CheckLabel = checkData.trABS == checkData.NewTRABS | ...
        (isnan(checkData.trABS) & isnan(checkData.NewTRABS));

if any(checkData.CheckLabel)
    diffRows = checkData(~checkData.CheckLabel, :);
    disp('Different trABS, check diffRows')
else
    disp('All trABS Right!')
end



function trABS = calTR(high, low, close)

shiftClose = [NaN; close(1:end-1)];

TR1 = abs(high - low);
TR2 = abs(high - shiftClose);
TR3 = abs(low - shiftClose);
trABS = max([TR1, TR2, TR3], [], 2);

end







