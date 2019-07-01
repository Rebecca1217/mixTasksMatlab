% һ���Ը���һ��ʱ��ε�TableData_main_v2ʱ����ʱ�������ATR�۸�ȡ�ò��Ե���ATR������������⣬������checkһ���������

load('E:\futureDataBasic\priceData\Dly\TableData_main_v2.mat')

% �˶�14��trABS������û�д���
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
        iClose = NaN; % ÿ��Ʒ�ֵĵ�һ�죬�������϶���ǰ���������Ƕ��������ݵģ�������Ҳ�ᶼ������NaN ���õ���
    else
        iClose = cursorB.Data{3};
    end
    replaceClose.ReplaceClose(iRow) = iClose;
end

TableData.ReplaceClose(logical(replaceLabel)) = replaceClose.ReplaceClose;
replaceRes = splitapply(@(x1,x2,x3){max([abs(x1 - x2), abs(x2 - x3), abs(x1 - x3)], [], 2)}, TableData.high, TableData.low, TableData.ReplaceClose, group);
replaceTR = vertcat(replaceRes{:});

TR(logical(replaceLabel)) = replaceTR(logical(replaceLabel));


%% ����ÿ��Ʒ�ֿ�ʼ�ĵ�һ����һ��NaN����
initIdx = [0; diff(group)]; % ��ʵӦ����[1; diff(group)];������ѩTableData��һ��Ʒ��trABS�������Ǿ��ȱ���������Ҳ��checkǰ�漸��
TR(logical(initIdx)) = NaN;
% ��һ�����б�Ҫ�ģ���Ϊ�е�Ʒ�ֱȽ���J����һ����ֵ�Ʒ�����������ڿ��ܻ��ܶ������ݣ�����һ��Ҫ�ֶ�����һ��NaN

%% �˶�
% ����ط�ֻ��2015���Ժ�Ľ�����к˶ԣ���ΪCZCͳһ��ȥ��һλ����ǰ�治��ȥ�Ĳ�����Ȼ�ǶԲ��ϵġ���֤������µ�����û���⼴��
checkData = TableData;
checkData.NewTRABS = TR;
checkData = checkData(checkData.date >= 20190101, :); % ֻ���2019���Ժ���µ�
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







