% 整理所有品种的交易时间

futs = getVarietyCode();

futs.WindCode = [futs.ContName, futs.Suffix];


w = windmatlab;
[w_wss_data,~,~,~,w_wss_errorid,~]=w.wss(futs.WindCode,'trade_status,thours','tradeDate=20190507');

futs.TradeTime = w_wss_data(:, 2);