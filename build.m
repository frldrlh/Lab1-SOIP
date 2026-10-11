function build_LabRab1_v2
% MATLAB R2021a / SimEvents 5.10. Не использует legacy-библиотеку simeventslib.
model = 'LabRab1_Magazin';
projectDir = fileparts(mfilename('fullpath'));
cd(projectDir);

if bdIsLoaded(model), close_system(model,0); end
if exist([model '.slx'],'file'), delete([model '.slx']); end
load_system('simulink');
new_system(model);
open_system(model);
set_param(model,'StopTime','480');
try set_param(model,'SolverType','Variable-step'); catch, end
try set_param(model,'Solver','VariableStepDiscrete'); catch, end
try set_param(model,'ReturnWorkspaceOutputs','on'); catch, end

addOne({'built-in/EntityGenerator'}, [model '/Customers'], [35 240 145 300]);
addOne({'built-in/Queue','built-in/EntityQueue'}, [model '/Queue_Cashier'], [205 240 320 300]);
addOne({'built-in/EntityServer'}, [model '/Cashier'], [380 240 490 300]);
addOne({'built-in/Queue','built-in/EntityQueue'}, [model '/Queue_Seller'], [550 240 665 300]);
addOne({'built-in/EntityServer'}, [model '/Seller'], [725 240 835 300]);
addOne({'built-in/Terminator (SimEvents)','built-in/EntityTerminator'}, [model '/Exit'], [895 240 1005 300]);

connectEntity(model,[model '/Customers'],[model '/Queue_Cashier']);
connectEntity(model,[model '/Queue_Cashier'],[model '/Cashier']);
connectEntity(model,[model '/Cashier'],[model '/Queue_Seller']);
connectEntity(model,[model '/Queue_Seller'],[model '/Seller']);
connectEntity(model,[model '/Seller'],[model '/Exit']);

set_param([model '/Customers'], ...
    'GenerationMethod','Time-based', ...
    'TimeSource','MATLAB action', ...
    'IntergenerationTimeAction','dt = 8.7 + 1.6*rand(1,1);', ...
    'GenerateEntityAtSimulationStart','off');

setupQueue([model '/Queue_Cashier']);
setupQueue([model '/Queue_Seller']);
setupServer([model '/Cashier'],'dt = 1.6 + 1.4*rand(1,1);');
setupServer([model '/Seller'],'dt = 8.6 + 2.8*rand(1,1);');

% Порядок статистических сигнальных выходов при включенных ниже параметрах:
% Queue: n, l. Entity Server: w, util.
addWorkspace(model,[model '/Queue_Cashier'],1,'q1_n',[180 45 300 75]);
addWorkspace(model,[model '/Queue_Cashier'],2,'q1_l',[180 100 300 130]);
addWorkspace(model,[model '/Cashier'],1,'cashier_w',[385 100 505 130]);
addWorkspace(model,[model '/Cashier'],2,'cashier_util',[385 45 505 75]);
addWorkspace(model,[model '/Queue_Seller'],1,'q2_n',[590 405 710 435]);
addWorkspace(model,[model '/Queue_Seller'],2,'q2_l',[590 460 710 490]);
addWorkspace(model,[model '/Seller'],1,'seller_w',[795 460 915 490]);
addWorkspace(model,[model '/Seller'],2,'seller_util',[795 405 915 435]);

try
    a = Simulink.Annotation(model, sprintf(['Лабораторная работа №1 — модель магазина\n' ...
       'Приход U(8.7;10.3) → кассир U(1.6;3.0) → продавец U(8.6;11.4)\n' ...
       'Моделирование: 480 минут']));
    a.Position = [270 155 800 215];
catch
end

save_system(model,fullfile(projectDir,[model '.slx']));
set_param(model,'ZoomFactor','FitSystem');
fprintf('Создана модель: %s\n',fullfile(projectDir,[model '.slx']));
end

function setupQueue(block)
setIfExists(block,'QueueOverwriting','off');
set_param(block,'Capacity','Inf','QueueType','FIFO');
set_param(block,'NumberEntitiesInBlock','on','AverageQueueLength','on');
end

function setupServer(block,code)
set_param(block,'Capacity','1','ServiceTimeSource','MATLAB action');
set_param(block,'ServiceTimeAction',code,'AverageWait','on','Utilization','on');
end

function addOne(candidates,dest,pos)
last = '';
for i=1:numel(candidates)
    try
        add_block(candidates{i},dest,'Position',pos);
        return
    catch ME
        last = ME.message;
    end
end
error('Не удалось добавить блок %s. %s',dest,last);
end

function connectEntity(model,src,dst)
ps = get_param(src,'PortHandles');
pd = get_param(dst,'PortHandles');
if isfield(ps,'RConn') && ~isempty(ps.RConn), a=ps.RConn(1); else, a=ps.Outport(1); end
if isfield(pd,'LConn') && ~isempty(pd.LConn), b=pd.LConn(1); else, b=pd.Inport(1); end
add_line(model,a,b,'autorouting','on');
end

function addWorkspace(model,src,index,name,pos)
dst=[model '/WS_' name];
add_block('simulink/Sinks/To Workspace',dst,'Position',pos);
set_param(dst,'VariableName',name,'SaveFormat','Timeseries','MaxDataPoints','inf');
ph1=get_param(src,'PortHandles'); ph2=get_param(dst,'PortHandles');
if numel(ph1.Outport)<index
    error('У %s отсутствует статистический выход %d.',src,index);
end
add_line(model,ph1.Outport(index),ph2.Inport(1),'autorouting','on');
end

function setIfExists(block,param,value)
p=get_param(block,'DialogParameters');
if isstruct(p) && isfield(p,param), set_param(block,param,value); end
end
