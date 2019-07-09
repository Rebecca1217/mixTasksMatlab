
% 不定期检查当前更新的现货和注册仓单数据对不对
latestDate = 20190708;

%% 现货数据
str = sprintf('load(''E:\\outSampleV3\\dataUpdate\\dataSpotV4\\aggDataSpotV4-%s.mat'')', num2str(latestDate));
eval(str)

codeName = getVarietyCode();
aggDataSpotV4 = outerjoin(aggDataSpotV4, codeName, 'type', 'left', 'MergeKeys', true, 'Keys', 'ContCode');
dataSpotV4 = unstack(aggDataSpotV4(:, {'Date', 'ContName', 'SpotPrice'}), 'SpotPrice', 'ContName');

% 现货代码
load('E:\outSampleV3\dataUpdate\getDataPara\spotCode.mat')
% 去Wind EDB中现货数据读取核对模板中读取现货数据，与dataSpotV4进行核对
% @2019.07.08检查是对的

%% 注册仓单数据
clearvars -except latestDate codeName
str = sprintf('load(''E:\\outSampleV3\\dataUpdate\\dataWarrant\\aggDataWarrant-%s.mat'')', num2str(latestDate));
eval(str)

aggDataWarrant = outerjoin(aggDataWarrant, codeName, 'type', 'left', 'MergeKeys', true, 'Keys', 'ContCode');
dataWarrant = unstack(aggDataWarrant(:, {'Date', 'ContName', 'Warrant'}), 'Warrant', 'ContName');
% 核对最新日期的warrant数据
% 大商所仓单日报
% http://www.dce.com.cn/dalianshangpin/xqsj/tjsj26/rtj/cdrb/index.html
% 大商所只有注册仓单 没有有效预报
dataWarrant.A(end) 
dataWarrant.C(end)
dataWarrant.CS(end)
dataWarrant.EG(end) % 乙二醇
dataWarrant.FB(end) % 纤维板
dataWarrant.J(end)
dataWarrant.L(end) % 聚乙烯 塑料
dataWarrant.M(end) % 豆粕
dataWarrant.P(end) % 棕榈油
dataWarrant.PP(end) % 聚丙烯
dataWarrant.V(end) % 聚氯乙烯 PVC
dataWarrant.Y(end) % 豆油

% 郑商所仓单日报
% http://www.czce.com.cn/cn/jysj/cdrb/H770310index_1.htm
% 郑商所同时公布注册仓单和有效预报
dataWarrant.CF(end)
dataWarrant.SR(end)
dataWarrant.TA(end)
dataWarrant.OI(end) % 菜油 有效预报远大于仓单数量
dataWarrant.RI(end) % 早籼稻
dataWarrant.WH(end) % 强麦
dataWarrant.FG(end) % 玻璃
dataWarrant.PM(end) % 普麦
dataWarrant.RS(end) % 油菜籽
dataWarrant.RM(end) % 菜粕
dataWarrant.ZC(end) % 动力煤
dataWarrant.JR(end) % 粳稻
dataWarrant.MA(end)
dataWarrant.LR(end) % 晚籼稻
dataWarrant.SF(end) % 硅铁
dataWarrant.SM(end) % 硅锰
dataWarrant.AP(end) 

% 上期所仓单日报
% http://www.shfe.com.cn/statements/dataview.html?paramid=kx
% 没有有效预报数据
dataWarrant.CU(end)
dataWarrant.AL(end)
dataWarrant.ZN(end)
dataWarrant.SC(end)
dataWarrant.PB(end)
dataWarrant.NI(end)
dataWarrant.SN(end)
dataWarrant.RU(end)
dataWarrant.SP(end)
dataWarrant.FU(end)
dataWarrant.BU(end)
dataWarrant.AU(end)
dataWarrant.AG(end)
dataWarrant.RB(end)
dataWarrant.WR(end) % 线材
dataWarrant.HC(end) 




