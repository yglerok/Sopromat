clc;
clear;
close all;

%% Добавить проверку того, задана ли начальная длина балки

%% 

% переменные
global endCoord ticks ticksSize; % координата конца балки
endCoord = 0; 
ticks = 0;
ticksSize = 1;



% Создание интерфейса
fig = uifigure('Name', 'Расчет статически определимой балки', 'Position', [350 250 1000 600]);

% Оси для построения схемы нагружения
ax = uiaxes('Parent', fig, 'Position', [250 20 (fig.Position(3)-280) (fig.Position(4)-40)],...
    'XLimitMethod', 'padded','YLim', [-1 1], 'YTick', [], 'XTick', [], 'Box','on');
hold(ax, 'on');

pnl = uipanel(fig, 'Position', [20 20 220 (fig.Position(4)-40)]);

btn1 = uibutton(pnl, 'Text', 'Длина балки', 'Position', [50 420 120 30],...
                'ButtonPushedFcn', @(btn1, event) lengthEntering(btn1, ax));
btn2 = uibutton(pnl, 'Text', 'Опора', 'Position', [50 370 120 30],...
                'ButtonPushedFcn', @(btn2, event) supportEntering(btn2, ax));
btn3 = uibutton(pnl, 'Text', 'Сила', 'Position', [50 320 120 30],...
                'ButtonPushedFcn', @(btn3, event) forceEntering(btn3, ax));
btn4 = uibutton(pnl, 'Text', 'Момент', 'Position', [50 270 120 30],...
                'ButtonPushedFcn', @(btn4, event) momentEntering(btn4, ax));
btn5 = uibutton(pnl, 'Text', 'Распределенная нагрузка', 'Position', [50 200 120 50],...
                'WordWrap','on',...
                'ButtonPushedFcn', @(btn5, event) distrLoadEntering(btn5, ax));
btn6 = uibutton(pnl, 'Text', 'Выполнить расчет', 'Position', [50 150 120 30]);
btn7 = uibutton(pnl, 'Text', 'Очистить', 'Position', [50 100 120 30],...
                'ButtonPushedFcn', @(btn7, event) cla(ax));







% Функция для добавления в массив новых координат
function newTick(x)
    global ticksSize ticks;
    t = 0;
    for i = 1:ticksSize
        if x == ticks(ticksSize)
            t = 1;
        end
    end
    if t == 0
        ticksSize = ticksSize + 1;
        ticks(ticksSize) = x;
    end
    ticks = sort(ticks);
end


% Ввод длины балки
function lengthEntering(btn, ax)
    global endCoord ticks ticksSize;
    x = 0;
    y = 0;
    fig1 = uifigure('Name', 'Ввод длины балки', 'Position', [400 400 300 200]);
    lbl1 = uilabel(fig1, 'Text', 'Длина балки, м:', 'Position', [20 100 100 30]);
    ef1 = uieditfield(fig1, 'Position', [115 100 100 30]);
    
    % Функция для отрисовки балки
    function ef1Changed(ef1, x, y, ax, fig)
        endCoord = str2double(ef1.Value);
        x = linspace(0, endCoord);
        y = x*0;
        plot(ax, x, y, 'black');
        ticksSize = ticksSize + 1;
        ticks(ticksSize) = endCoord;
        ax.XTick = ticks; 
        close(fig);
    end
    
    button1 = uibutton(fig1, 'Text', 'Ввод', 'Position', [20 20 100 30],...
        'ButtonPushedFcn', @(button1, event) ef1Changed(ef1, x, y, ax, fig1));
    button2 = uibutton(fig1, 'Text', 'Отмена', 'Position', [140 20 100 30],...
        'ButtonPushedFcn', @(button2, event) close(fig1));
end

% Ввод опор
function supportEntering(btn, ax)
    global ticks endCoord;

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


    x = 0;
    % В зависимости от типа опоры пользователю предоставляется разные 
    % способы задания координаты.
    % Для жесткой заделки - левый или правый конец балки.
    % Для шарнирных опор - расстояние от левого конца балки.
    function selection(dd1)
        val = dd1.Value;
        switch val
            case 'Жесткая заделка'
                set([bg rb1 rb2], 'Visible', 'on');
                set([lbl2 ef1], 'Visible', 'off');
            otherwise
                set([bg rb1 rb2], 'Visible', 'off');
                set([lbl2 ef1], 'Visible', 'on');
        end
    end
 

    function supDrawing(ef1, ax, rb1, rb2, dd1, fig)
        val = dd1.Value;
        switch val
            case 'Жесткая заделка'
                if rb1.Value == true
                    plot(ax, 0, 0, '|k', 'LineWidth', 2, 'MarkerSize', 24);
                end
                if rb2.Value == true
                    plot(ax, endCoord, 0, '|k', 'LineWidth', 2, 'MarkerSize', 24); 
                end
            case 'Шарнирно-подвижная'
                x = str2double(ef1.Value);
                plot(ax, x, 0, 'ok', 'LineWidth', 2, 'MarkerSize', 7, 'MarkerFaceColor', 'k');
                newTick(x);
                ax.XTick = ticks;
            case 'Шарнирно-неподвижная'
                x = str2double(ef1.Value);
                plot(ax, x, 0, 'sk', 'LineWidth', 2, 'MarkerSize', 8, 'MarkerFaceColor', 'k');
                newTick(x);
                ax.XTick = ticks;
        end
        close(fig);
    end

    button1 = uibutton(fig1, 'Text', 'Ввод', 'Position', [20 20 100 30],...
        'ButtonPushedFcn', @(button1, event) supDrawing(ef1, ax, rb1, rb2, dd1, fig1));
    button2 = uibutton(fig1, 'Text', 'Отмена', 'Position', [140 20 100 30],...
        'ButtonPushedFcn', @(button2, event) close(fig1));
end

% Ввод сосредоточенной силы
function forceEntering(btn, ax)
    global ticks;
    
    fig1 = uifigure('Name', 'Ввод сосредоточенной силы', 'Position', [400 400 400 250]);
    lbl1 = uilabel(fig1, 'Text', 'Расстояние от левого конца, м:',...
                    'Position', [20 (fig1.Position(4)-40) 200 30]);
    ef1 = uieditfield(fig1, 'Position', [20 (fig1.Position(4)-70) 80 30]);
    lbl2 = uilabel(fig1, 'Text', 'Величина, кН:',...
                    'Position', [20 (fig1.Position(4)-120) 100 30]);
    ef2 = uieditfield(fig1, 'Position', [20 (fig1.Position(4)-150) 80 30]);



    function forsDrawing(ef1, ef2, ax, fig)
        val = str2double(ef2.Value);
        x = str2double(ef1.Value);
        if val > 0
            plot(ax, x, 0, '|', 'MarkerEdgeColor','b', 'MarkerSize', 13);
            plot(ax, x, 0, '^', 'MarkerEdgeColor', 'b', 'MarkerFaceColor','b', 'MarkerSize', 8);
            newTick(x);
            ax.XTick = ticks;
        end
        if val < 0
            plot(ax, x, 0, '|', 'MarkerEdgeColor','b', 'MarkerSize', 13);
            plot(ax, x, 0, 'v', 'MarkerEdgeColor', 'b', 'MarkerFaceColor','b', 'MarkerSize', 8);
            newTick(x);
            ax.XTick = ticks;
        end
        close(fig);
    end

    button1 = uibutton(fig1, 'Text', 'Ввод', 'Position', [20 20 100 30],...
        'ButtonPushedFcn', @(button1, event) forsDrawing(ef1, ef2, ax, fig1));
    button2 = uibutton(fig1, 'Text', 'Отмена', 'Position', [140 20 100 30],...
        'ButtonPushedFcn', @(button2, event) close(fig1));
end

% Ввод сосредоточенного момента
function momentEntering(btn, ax)
    global ticks;

    fig1 = uifigure('Name', 'Ввод сосредоточенного момента', 'Position', [400 400 400 250]);
    lbl1 = uilabel(fig1, 'Text', 'Расстояние от левого конца, м:',...
                    'Position', [20 (fig1.Position(4)-40) 200 30]);
    ef1 = uieditfield(fig1, 'Position', [20 (fig1.Position(4)-70) 80 30]);
    lbl2 = uilabel(fig1, 'Text', 'Величина, кН*м:',...
                    'Position', [20 (fig1.Position(4)-120) 100 30]);
    ef2 = uieditfield(fig1, 'Position', [20 (fig1.Position(4)-150) 80 30]);


    function momentDrawing(ef1, ef2, ax, fig)
        val = str2double(ef2.Value);
        x = str2double(ef1.Value);
        disp(val);
        if val > 0
            plot(ax, x, 0, 'o', 'MarkerEdgeColor','r', 'MarkerSize', 13);
            plot(ax, x, 0, '<', 'MarkerEdgeColor', 'r', 'MarkerFaceColor','r', 'MarkerSize', 8);
            newTick(x);
            ax.XTick = ticks;
        end
        if val < 0
            plot(ax, x, 0, 'o', 'MarkerEdgeColor','r', 'MarkerSize', 13);
            plot(ax, x, 0, '>', 'MarkerEdgeColor', 'r', 'MarkerFaceColor','r', 'MarkerSize', 8);
            newTick(x);
            ax.XTick = ticks;
        end
        close(fig);
    end


    button1 = uibutton(fig1, 'Text', 'Ввод', 'Position', [20 20 100 30],...
        'ButtonPushedFcn', @(button1, event) momentDrawing(ef1, ef2, ax, fig1));
    button2 = uibutton(fig1, 'Text', 'Отмена', 'Position', [140 20 100 30],...
        'ButtonPushedFcn', @(button2, event) close(fig1));
end

% Ввод распределенной нагрузки
function distrLoadEntering(btn, ax)
    global ticks;
    
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
    ef3 = uieditfield(pnl1, 'Position', [110 (pnl1.Position(4)-100) 80 30]);


    function distrLoadDrawing(ef1, ef2, ef3, ax, fig)
        val = str2double(ef1.Value);
        x1 = str2double(ef2.Value);
        x2 = str2double(ef3.Value);
        x = (x1:0.1:x2)';
        if val > 0
            plot(ax, x, 0, '|', 'MarkerEdgeColor','b', 'MarkerSize', 8);
            plot(ax, x, 0, '^', 'MarkerEdgeColor', 'b', 'MarkerFaceColor','b', 'MarkerSize', 6);
            newTick(x1);
            newTick(x2);
            ax.XTick = ticks;
        end
        if val < 0
            plot(ax, x, 0, '|', 'MarkerEdgeColor','b', 'MarkerSize', 13);
            plot(ax, x, 0, 'v', 'MarkerEdgeColor', 'b', 'MarkerFaceColor','b', 'MarkerSize', 8);
            newTick(x1);
            newTick(x2);
            ax.XTick = ticks;
        end
        close(fig);
    end


    button1 = uibutton(fig1, 'Text', 'Ввод', 'Position', [20 20 100 30],...
        'ButtonPushedFcn', @(button1, event) distrLoadDrawing(ef1, ef2, ef3, ax, fig1));
    button2 = uibutton(fig1, 'Text', 'Отмена', 'Position', [140 20 100 30],...
        'ButtonPushedFcn', @(button2, event) close(fig1));
end