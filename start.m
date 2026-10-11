clear; clc;
projectDir = fileparts(mfilename('fullpath'));
cd(projectDir);
fprintf('Лабораторная работа №1: модель магазина в SimEvents R2021a\n');
fprintf('Рабочая папка: %s\n\n', projectDir);
if ~exist('LabRab1_Magazin.slx','file')
    fprintf('Создание модели современными блоками SimEvents...\n');
    build_LabRab1_v2;
end
open_system('LabRab1_Magazin');
fprintf('\nМодель открыта. Для расчета введите: run_LabRab1\n');
