function Results = run_LabRab1
projectDir=fileparts(mfilename('fullpath')); cd(projectDir);
model='LabRab1_Magazin';
if ~exist([model '.slx'],'file'), build_LabRab1_v2; end
load_system(model); rng(2026,'twister');
fprintf('Моделирование 480 минут...\n');
out=sim(model,'StopTime','480','ReturnWorkspaceOutputs','on');
q1n=getData(out,'q1_n'); q1l=getData(out,'q1_l');
q2n=getData(out,'q2_n'); q2l=getData(out,'q2_l');
cw=getData(out,'cashier_w'); cu=getData(out,'cashier_util');
sw=getData(out,'seller_w'); su=getData(out,'seller_util');

Parameter={'Загрузка кассира';'Загрузка продавца';'Макс. очередь к кассе'; ...
 'Средняя очередь к кассе';'Текущая очередь к кассе';'Макс. очередь к продавцу'; ...
 'Средняя очередь к продавцу';'Текущая очередь к продавцу'; ...
 'Среднее обслуживание кассиром';'Среднее обслуживание продавцом'};
Value=[last(cu.Data)*100;last(su.Data)*100;max(q1n.Data);last(q1l.Data);last(q1n.Data); ...
 max(q2n.Data);last(q2l.Data);last(q2n.Data);last(cw.Data);last(sw.Data)];
Unit={'%';'%';'чел.';'чел.';'чел.';'чел.';'чел.';'чел.';'мин';'мин'};
Results=table(Parameter,Value,Unit); disp(Results);
writetable(Results,'LabRab1_results.csv');

f=figure('Color','w','Position',[100 100 1100 700]);
subplot(2,2,1); stairs(q1n.Time,q1n.Data,'LineWidth',1.2); grid on; title('Очередь к кассе'); xlabel('Минуты'); ylabel('Человек');
subplot(2,2,2); stairs(q2n.Time,q2n.Data,'LineWidth',1.2); grid on; title('Очередь к продавцу'); xlabel('Минуты'); ylabel('Человек');
subplot(2,2,3); stairs(cu.Time,cu.Data*100,'LineWidth',1.2); grid on; title('Загрузка кассира'); xlabel('Минуты'); ylabel('%'); ylim([0 105]);
subplot(2,2,4); stairs(su.Time,su.Data*100,'LineWidth',1.2); grid on; title('Загрузка продавца'); xlabel('Минуты'); ylabel('%'); ylim([0 105]);
saveas(f,'LabRab1_graphs.png');
fprintf('Готово: LabRab1_results.csv и LabRab1_graphs.png\n');
open_system(model);
end

function x=getData(out,name)
try x=out.get(name); catch, x=evalin('base',name); end
if ~isa(x,'timeseries'), error('%s не является timeseries.',name); end
end
function x=last(v)
v=v(:); i=find(~isnan(v),1,'last'); if isempty(i), x=NaN; else, x=v(i); end
end
