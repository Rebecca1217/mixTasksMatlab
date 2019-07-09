
% �����ڼ�鵱ǰ���µ��ֻ���ע��ֵ����ݶԲ���
latestDate = 20190708;

%% �ֻ�����
str = sprintf('load(''E:\\outSampleV3\\dataUpdate\\dataSpotV4\\aggDataSpotV4-%s.mat'')', num2str(latestDate));
eval(str)

codeName = getVarietyCode();
aggDataSpotV4 = outerjoin(aggDataSpotV4, codeName, 'type', 'left', 'MergeKeys', true, 'Keys', 'ContCode');
dataSpotV4 = unstack(aggDataSpotV4(:, {'Date', 'ContName', 'SpotPrice'}), 'SpotPrice', 'ContName');

% �ֻ�����
load('E:\outSampleV3\dataUpdate\getDataPara\spotCode.mat')
% ȥWind EDB���ֻ����ݶ�ȡ�˶�ģ���ж�ȡ�ֻ����ݣ���dataSpotV4���к˶�
% @2019.07.08����ǶԵ�

%% ע��ֵ�����
clearvars -except latestDate codeName
str = sprintf('load(''E:\\outSampleV3\\dataUpdate\\dataWarrant\\aggDataWarrant-%s.mat'')', num2str(latestDate));
eval(str)

aggDataWarrant = outerjoin(aggDataWarrant, codeName, 'type', 'left', 'MergeKeys', true, 'Keys', 'ContCode');
dataWarrant = unstack(aggDataWarrant(:, {'Date', 'ContName', 'Warrant'}), 'Warrant', 'ContName');
% �˶��������ڵ�warrant����
% �������ֵ��ձ�
% http://www.dce.com.cn/dalianshangpin/xqsj/tjsj26/rtj/cdrb/index.html
% ������ֻ��ע��ֵ� û����ЧԤ��
dataWarrant.A(end) 
dataWarrant.C(end)
dataWarrant.CS(end)
dataWarrant.EG(end) % �Ҷ���
dataWarrant.FB(end) % ��ά��
dataWarrant.J(end)
dataWarrant.L(end) % ����ϩ ����
dataWarrant.M(end) % ����
dataWarrant.P(end) % �����
dataWarrant.PP(end) % �۱�ϩ
dataWarrant.V(end) % ������ϩ PVC
dataWarrant.Y(end) % ����

% ֣�����ֵ��ձ�
% http://www.czce.com.cn/cn/jysj/cdrb/H770310index_1.htm
% ֣����ͬʱ����ע��ֵ�����ЧԤ��
dataWarrant.CF(end)
dataWarrant.SR(end)
dataWarrant.TA(end)
dataWarrant.OI(end) % ���� ��ЧԤ��Զ���ڲֵ�����
dataWarrant.RI(end) % ���̵�
dataWarrant.WH(end) % ǿ��
dataWarrant.FG(end) % ����
dataWarrant.PM(end) % ����
dataWarrant.RS(end) % �Ͳ���
dataWarrant.RM(end) % ����
dataWarrant.ZC(end) % ����ú
dataWarrant.JR(end) % ����
dataWarrant.MA(end)
dataWarrant.LR(end) % ���̵�
dataWarrant.SF(end) % ����
dataWarrant.SM(end) % ����
dataWarrant.AP(end) 

% �������ֵ��ձ�
% http://www.shfe.com.cn/statements/dataview.html?paramid=kx
% û����ЧԤ������
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
dataWarrant.WR(end) % �߲�
dataWarrant.HC(end) 




