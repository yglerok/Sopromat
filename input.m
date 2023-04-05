clc;
clear;
close all;

%% 

% Создание интерфейса
fig = uifigure('Name', 'Расчет статически определимой балки', 'Position', [350 250 1000 600]);

pnl = uipanel(fig, 'Position', [20 20 220 (fig.Position(4)-40)]);

btn1 = uibutton(pnl, 'Text', 'Длина балки', 'Position', [50 420 120 30],...
                'ButtonPushedFcn', @(btn1, event) lengthEntering(btn1));
btn2 = uibutton(pnl, 'Text', 'Опора', 'Position', [50 370 120 30],...
                'ButtonPushedFcn', @(btn2, event) supportEntering(btn2));
btn3 = uibutton(pnl, 'Text', 'Сила', 'Position', [50 320 120 30],...
                'ButtonPushedFcn', @(btn3, event) forceEntering(btn3));
btn4 = uibutton(pnl, 'Text', 'Момент', 'Position', [50 270 120 30],...
                'ButtonPushedFcn', @(btn4, event) momentEntering(btn4));
btn5 = uibutton(pnl, 'Text', 'Распределенная нагрузка', 'Position', [50 200 120 50],...
                'WordWrap','on',...
                'ButtonPushedFcn', @(btn5, event) distrLoadEntering(btn5));
btn6 = uibutton(pnl, 'Text', 'Выполнить расчет', 'Position', [50 150 120 30]);

% Оси для построения схемы нагружения
ax = uiaxes('Parent', fig, 'Position', [250 20 (fig.Position(3)-280) (fig.Position(4)-40)]);

% Ввод длины балки
function lengthEntering(btn)
    fig1 = uifigure('Name', 'Ввод длины балки', 'Position', [400 400 300 200]);
    lbl1 = uilabel(fig1, 'Text', 'Длина балки, м:', 'Position', [20 100 100 30]);
    ef1 = uieditfield(fig1, 'Position', [115 100 100 30]);

    button1 = uibutton(fig1, 'Text', 'Ввод', 'Position', [20 20 100 30]);
    button2 = uibutton(fig1, 'Text', 'Отмена', 'Position', [140 20 100 30]);
end

% Ввод опор
function supportEntering(btn)
    fig1 = uifigure('Name', 'Ввод опор', 'Position', [400 400 400 250]);
    lbl1 = uilabel(fig1, 'Text', 'Тип опоры', 'Position', [20 (fig1.Position(4)-40) 100 30]);
    dd1 = uidropdown(fig1, 'Position', [20 (fig1.Position(4)-80) 180 30],...
        'Items', {'', 'Шарнирно-подвижная', 'Шарнирно-неподвижная', 'Жесткая заделка'},...
        'Value', '',...
        'Placeholder', 'Выберите тип',...
        'ValueChangedFcn', @(dd1, event) selection(dd1));


    lbl2 = uilabel(fig1, 'Text', 'Расстояние от левого конца, м:',...
                   'Position', [20 (fig1.Position(4)-150) 200 30],...
                   'Visible','off');
    ef1 = uieditfield(fig1, 'Position', [200 (fig1.Position(4)-150) 100 30],...
                   'Visible','off');
    bg = uibuttongroup(fig1, 'Position', [20 (fig1.Position(4)-170) 180 70],...
                   'Visible','off');
    rb1 = uiradiobutton(bg, 'Text', 'Слева', 'Visible','off',...
                        'Position', [20 40 200 20]);
    rb2 = uiradiobutton(bg, 'Text', 'Справа', 'Visible','off',...
                        'Position', [20 15 200 20]);

    % В зависимости от типа опоры пользователю предоставляется разные 
    % способы задания координаты.
    % Для жесткой заделки - левый или правый конец балки.
    % Для шарнирных опор - расстояние от левого конца балки.
    function selection(dd)
        val = dd.Value;
        switch val
            case 'Жесткая заделка'
                set([bg rb1 rb2], 'Visible', 'on');
                set([lbl2 ef1], 'Visible', 'off');
            otherwise
                set([bg rb1 rb2], 'Visible', 'off');
                set([lbl2 ef1], 'Visible', 'on');
        end

    end
 

    button1 = uibutton(fig1, 'Text', 'Ввод', 'Position', [20 20 100 30]);
    button2 = uibutton(fig1, 'Text', 'Отмена', 'Position', [140 20 100 30]);
end

% Ввод сосредоточенной силы
function forceEntering(btn)
    fig1 = uifigure('Name', 'Ввод сосредоточенной силы', 'Position', [400 400 400 250]);
    lbl1 = uilabel(fig1, 'Text', 'Расстояние от левого конца, м:',...
                    'Position', [20 (fig1.Position(4)-40) 200 30]);
    ef1 = uieditfield(fig1, 'Position', [20 (fig1.Position(4)-70) 80 30]);
    lbl2 = uilabel(fig1, 'Text', 'Величина, кН:',...
                    'Position', [20 (fig1.Position(4)-120) 100 30]);
    ef2 = uieditfield(fig1, 'Position', [20 (fig1.Position(4)-150) 80 30]);


    button1 = uibutton(fig1, 'Text', 'Ввод', 'Position', [20 20 100 30]);
    button2 = uibutton(fig1, 'Text', 'Отмена', 'Position', [140 20 100 30]);
end

% Ввод сосредоточенного момента
function momentEntering(btn)
    fig1 = uifigure('Name', 'Ввод сосредоточенного момента', 'Position', [400 400 400 250]);
    lbl1 = uilabel(fig1, 'Text', 'Расстояние от левого конца, м:',...
                    'Position', [20 (fig1.Position(4)-40) 200 30]);
    ef1 = uieditfield(fig1, 'Position', [20 (fig1.Position(4)-70) 80 30]);
    lbl2 = uilabel(fig1, 'Text', 'Величина, кН*м:',...
                    'Position', [20 (fig1.Position(4)-120) 100 30]);
    ef2 = uieditfield(fig1, 'Position', [20 (fig1.Position(4)-150) 80 30]);


    button1 = uibutton(fig1, 'Text', 'Ввод', 'Position', [20 20 100 30]);
    button2 = uibutton(fig1, 'Text', 'Отмена', 'Position', [140 20 100 30]);
end

% Ввод распределенной нагрузки
function distrLoadEntering(btn)
    % Интенсивность
    % Смещение начала и конца нагрузки
    fig1 = uifigure('Name', 'Ввод распределенной нагрузки', 'Position', [400 400 400 250]);
    lbl1 = uilabel(fig1, 'Text', 'Интенсивность, кН/м:',...
                    'Position', [20 (fig1.Position(4)-40) 200 30]);
    ef1 = uieditfield(fig1, 'Position', [20 (fig1.Position(4)-70) 80 30]);
    pnl1 = uipanel(fig1, 'Position', [20 (fig1.Position(4)-190) 300 110]);
    lbl2 = uilabel(pnl1, 'Text', 'Расстояние от левого конца балки, м:',...
                    'Position', [10 (pnl1.Position(4)-30) 300 30]);
    lbl3 = uilabel(pnl1, 'Text', 'Начало участка:',...
                    'Position', [10 (pnl1.Position(4)-60) 300 30]);
    ef2 = uieditfield(pnl1, 'Position', [110 (pnl1.Position(4)-60) 80 30]);
    lbl3 = uilabel(pnl1, 'Text', 'Конец участка:',...
                    'Position', [10 (pnl1.Position(4)-100) 300 30]);
    ef2 = uieditfield(pnl1, 'Position', [110 (pnl1.Position(4)-100) 80 30]);


    button1 = uibutton(fig1, 'Text', 'Ввод', 'Position', [20 20 100 30]);
    button2 = uibutton(fig1, 'Text', 'Отмена', 'Position', [140 20 100 30]);
end