classdef ecoli_plot_program_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                       matlab.ui.Figure
        GridLayout                     matlab.ui.container.GridLayout
        LeftPanel                      matlab.ui.container.Panel
        CompareButton                  matlab.ui.control.Button
        ClearButton                    matlab.ui.control.Button
        RunButton                      matlab.ui.control.Button
        GrowthMediumEditField          matlab.ui.control.EditField
        GrowthMediumEditFieldLabel     matlab.ui.control.Label
        TemperatureEditField           matlab.ui.control.NumericEditField
        TemperatureEditFieldLabel      matlab.ui.control.Label
        TotalSimulationTimeminEditField  matlab.ui.control.NumericEditField
        TotalSimulationTimeminEditFieldLabel  matlab.ui.control.Label
        DilutionFactorEditField        matlab.ui.control.NumericEditField
        DilutionFactorEditFieldLabel   matlab.ui.control.Label
        InoculumSize108CFUmlEditField  matlab.ui.control.NumericEditField
        InoculumSize108CFUmlEditFieldLabel  matlab.ui.control.Label
        CenterPanel                    matlab.ui.container.Panel
        UIAxes                         matlab.ui.control.UIAxes
        RightPanel                     matlab.ui.container.Panel
    end

    % Properties that correspond to apps with auto-reflow
    properties (Access = private)
        onePanelWidth = 576;
        twoPanelWidth = 768;
    end

    % Callbacks that handle component events
    methods (Access = private)

        % Button pushed function: RunButton
        function RunButtonPushed(app, event)
            % taken from Krce et al., 2019
            B0 = app.InoculumSize108CFUmlEditField.Value*(10.^8);
            x = app.DilutionFactorEditField.Value;
            time = app.TotalSimulationTimeminEditField.Value;
            N0 = 2.1*(10.^(9))*x; %the theoretical maximum given the initial nutrient concentration
            km = 1.94*(10.^(-2)); kbb = 1.96*(10.^(-4)); %experimental data
            xhalf = 0.093;
            qx = x/(x+xhalf);
            c = 0.72; 
            Nmin = (1-1./(10.^6))*B0; 
            t = [0 time];
            function dgdt = dgdtf(t,g,qx,km,kbb,Nmin,c,N0)
                b = g(1); n = g(2);
                Braw = max(1,b*N0);
                lag_factor = max(0,1-Nmin/Braw).^c;
                dgdt(1) = qx*(km*b*n-kbb*(b.^2))*lag_factor;
                dgdt(2,1) = -qx*km*b*n*lag_factor;
            end

            hold(app.UIAxes, 'on')
            fg = @(t,g) dgdtf(t,g,qx,km,kbb,Nmin,c,N0);
            [t3,g] = ode45(fg,t,[B0/N0 1]);
            C = g(:,1)*N0;
            plot(app.UIAxes,t3,C,'y','LineWidth', 1.5, 'DisplayName', 'Project Model')
            hold(app.UIAxes, 'off')
            legend(app.UIAxes, 'show', 'Location', 'best')
            
        end

        % Value changed function: TemperatureEditField
        function TemperatureEditFieldValueChanged(app, event)
            app.TemperatureEditField.Value = 37;
        end

        % Value changed function: GrowthMediumEditField
        function GrowthMediumEditFieldValueChanged(app, event)
            app.GrowthMediumEditField.Value = 'LB medium';
        end

        % Callback function
        function umaxEditFieldValueChanged(app, event)
            app.umaxEditField.Value = 0; %change to real umax
        end

        % Callback function
        function KsEditFieldValueChanged(app, event)
            app.KsEditField.Value = 0; %change to real Ks
        end

        % Button down function: UIAxes
        function UIAxesButtonDown(app, event)
            
        end

        % Button pushed function: ClearButton
        function ClearButtonPushed(app, event)
            cla(app.UIAxes);
        end

        % Button pushed function: CompareButton
        function CompareButtonPushed(app, event)
            B0 = app.InoculumSize108CFUmlEditField.Value*(10.^8);
            x = app.DilutionFactorEditField.Value;
            time = app.TotalSimulationTimeminEditField.Value;
            N0 = 2.1*(10.^(9))*x; %the theoretical maximum given the initial nutrient concentration
            km = 1.94*(10.^(-2)); kbb = 1.96*(10.^(-4)); 
            xhalf = 0.093;
            qx = x/(x+xhalf);
     
            function dydt = dydtf(t,y,qx,km,kbb)
                b = y(1); n = y(2);
                dydt(1) = qx*(km*b*n-kbb*(b.^2));
                dydt(2,1) = -qx*km*b*n;
            end
            
            hold(app.UIAxes, 'on')
            f = @(t,y) dydtf(t,y,qx,km,kbb);
            t = [0 time];
            [t1,y] = ode45(f,t,[B0/N0 1]);
            B = y(:,1)*N0;
            plot(app.UIAxes,t1,B,'Color', [0 0.4470 0.7410],'LineWidth', 1.5, 'DisplayName', 'Krce Model')

            hold(app.UIAxes, 'on')
            r = exp(21-6230./(37+273))/60;
            c = 0.72; 
            Nmin = (1-1./(10.^6))*B0;

            function dzdt = dzdtf(t,z,r,c,Nmin)
                lag_factor = max(0,1-Nmin/z).^c;
                dzdt = r*z*(1-z/N0)*lag_factor;
            end

            fz = @(t,z) dzdtf(t,z,r,c,Nmin);
            [t2,z] = ode45(fz,t,B0);
            plot(app.UIAxes,t2,z,'Color', [1 0.5 0],'LineWidth', 1.5, 'DisplayName', 'Fujikawa Model')
            hold(app.UIAxes, 'off')
            legend(app.UIAxes, 'show', 'Location', 'best')
            
        end

        % Changes arrangement of the app based on UIFigure width
        function updateAppLayout(app, event)
            currentFigureWidth = app.UIFigure.Position(3);
            if(currentFigureWidth <= app.onePanelWidth)
                % Change to a 3x1 grid
                app.GridLayout.RowHeight = {480, 480, 480};
                app.GridLayout.ColumnWidth = {'1x'};
                app.CenterPanel.Layout.Row = 1;
                app.CenterPanel.Layout.Column = 1;
                app.LeftPanel.Layout.Row = 2;
                app.LeftPanel.Layout.Column = 1;
                app.RightPanel.Layout.Row = 3;
                app.RightPanel.Layout.Column = 1;
            elseif (currentFigureWidth > app.onePanelWidth && currentFigureWidth <= app.twoPanelWidth)
                % Change to a 2x2 grid
                app.GridLayout.RowHeight = {480, 480};
                app.GridLayout.ColumnWidth = {'1x', '1x'};
                app.CenterPanel.Layout.Row = 1;
                app.CenterPanel.Layout.Column = [1,2];
                app.LeftPanel.Layout.Row = 2;
                app.LeftPanel.Layout.Column = 1;
                app.RightPanel.Layout.Row = 2;
                app.RightPanel.Layout.Column = 2;
            else
                % Change to a 1x3 grid
                app.GridLayout.RowHeight = {'1x'};
                app.GridLayout.ColumnWidth = {220, '1x', 12};
                app.LeftPanel.Layout.Row = 1;
                app.LeftPanel.Layout.Column = 1;
                app.CenterPanel.Layout.Row = 1;
                app.CenterPanel.Layout.Column = 2;
                app.RightPanel.Layout.Row = 1;
                app.RightPanel.Layout.Column = 3;
            end
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.AutoResizeChildren = 'off';
            app.UIFigure.Position = [100 100 860 480];
            app.UIFigure.Name = 'MATLAB App';
            app.UIFigure.SizeChangedFcn = createCallbackFcn(app, @updateAppLayout, true);

            % Create GridLayout
            app.GridLayout = uigridlayout(app.UIFigure);
            app.GridLayout.ColumnWidth = {220, '1x', 12};
            app.GridLayout.RowHeight = {'1x'};
            app.GridLayout.ColumnSpacing = 0;
            app.GridLayout.RowSpacing = 0;
            app.GridLayout.Padding = [0 0 0 0];
            app.GridLayout.Scrollable = 'on';

            % Create LeftPanel
            app.LeftPanel = uipanel(app.GridLayout);
            app.LeftPanel.Layout.Row = 1;
            app.LeftPanel.Layout.Column = 1;

            % Create InoculumSize108CFUmlEditFieldLabel
            app.InoculumSize108CFUmlEditFieldLabel = uilabel(app.LeftPanel);
            app.InoculumSize108CFUmlEditFieldLabel.HorizontalAlignment = 'right';
            app.InoculumSize108CFUmlEditFieldLabel.Position = [28 437 161 22];
            app.InoculumSize108CFUmlEditFieldLabel.Text = 'Inoculum Size (10^8 CFU/ml)';

            % Create InoculumSize108CFUmlEditField
            app.InoculumSize108CFUmlEditField = uieditfield(app.LeftPanel, 'numeric');
            app.InoculumSize108CFUmlEditField.Position = [102 406 100 22];

            % Create DilutionFactorEditFieldLabel
            app.DilutionFactorEditFieldLabel = uilabel(app.LeftPanel);
            app.DilutionFactorEditFieldLabel.HorizontalAlignment = 'right';
            app.DilutionFactorEditFieldLabel.Position = [34 373 82 22];
            app.DilutionFactorEditFieldLabel.Text = 'Dilution Factor';

            % Create DilutionFactorEditField
            app.DilutionFactorEditField = uieditfield(app.LeftPanel, 'numeric');
            app.DilutionFactorEditField.Limits = [0 1];
            app.DilutionFactorEditField.Position = [98 342 100 22];
            app.DilutionFactorEditField.Value = 1;

            % Create TotalSimulationTimeminEditFieldLabel
            app.TotalSimulationTimeminEditFieldLabel = uilabel(app.LeftPanel);
            app.TotalSimulationTimeminEditFieldLabel.HorizontalAlignment = 'right';
            app.TotalSimulationTimeminEditFieldLabel.Position = [33 301 154 22];
            app.TotalSimulationTimeminEditFieldLabel.Text = 'Total Simulation Time (min))';

            % Create TotalSimulationTimeminEditField
            app.TotalSimulationTimeminEditField = uieditfield(app.LeftPanel, 'numeric');
            app.TotalSimulationTimeminEditField.Position = [98 270 100 22];
            app.TotalSimulationTimeminEditField.Value = 1500;

            % Create TemperatureEditFieldLabel
            app.TemperatureEditFieldLabel = uilabel(app.LeftPanel);
            app.TemperatureEditFieldLabel.HorizontalAlignment = 'right';
            app.TemperatureEditFieldLabel.Position = [30 141 72 22];
            app.TemperatureEditFieldLabel.Text = 'Temperature';

            % Create TemperatureEditField
            app.TemperatureEditField = uieditfield(app.LeftPanel, 'numeric');
            app.TemperatureEditField.ValueChangedFcn = createCallbackFcn(app, @TemperatureEditFieldValueChanged, true);
            app.TemperatureEditField.Editable = 'off';
            app.TemperatureEditField.Position = [115 141 85 22];
            app.TemperatureEditField.Value = 37;

            % Create GrowthMediumEditFieldLabel
            app.GrowthMediumEditFieldLabel = uilabel(app.LeftPanel);
            app.GrowthMediumEditFieldLabel.HorizontalAlignment = 'right';
            app.GrowthMediumEditFieldLabel.Position = [16 98 88 22];
            app.GrowthMediumEditFieldLabel.Text = 'Growth Medium';

            % Create GrowthMediumEditField
            app.GrowthMediumEditField = uieditfield(app.LeftPanel, 'text');
            app.GrowthMediumEditField.ValueChangedFcn = createCallbackFcn(app, @GrowthMediumEditFieldValueChanged, true);
            app.GrowthMediumEditField.Editable = 'off';
            app.GrowthMediumEditField.HorizontalAlignment = 'right';
            app.GrowthMediumEditField.Position = [115 98 83 22];
            app.GrowthMediumEditField.Value = 'LB medium';

            % Create RunButton
            app.RunButton = uibutton(app.LeftPanel, 'push');
            app.RunButton.ButtonPushedFcn = createCallbackFcn(app, @RunButtonPushed, true);
            app.RunButton.Position = [63 235 100 23];
            app.RunButton.Text = 'Run';

            % Create ClearButton
            app.ClearButton = uibutton(app.LeftPanel, 'push');
            app.ClearButton.ButtonPushedFcn = createCallbackFcn(app, @ClearButtonPushed, true);
            app.ClearButton.Position = [63 172 100 23];
            app.ClearButton.Text = 'Clear';

            % Create CompareButton
            app.CompareButton = uibutton(app.LeftPanel, 'push');
            app.CompareButton.ButtonPushedFcn = createCallbackFcn(app, @CompareButtonPushed, true);
            app.CompareButton.Position = [63 204 100 23];
            app.CompareButton.Text = 'Compare';

            % Create CenterPanel
            app.CenterPanel = uipanel(app.GridLayout);
            app.CenterPanel.Layout.Row = 1;
            app.CenterPanel.Layout.Column = 2;

            % Create UIAxes
            app.UIAxes = uiaxes(app.CenterPanel);
            title(app.UIAxes, 'E.Coli Concentration vs Time')
            xlabel(app.UIAxes, 'Time (min)')
            ylabel(app.UIAxes, ' E.Coli Concentration (10^9/ml)')
            zlabel(app.UIAxes, 'Z')
            app.UIAxes.ButtonDownFcn = createCallbackFcn(app, @UIAxesButtonDown, true);
            app.UIAxes.Position = [38 85 465 322];

            % Create RightPanel
            app.RightPanel = uipanel(app.GridLayout);
            app.RightPanel.Layout.Row = 1;
            app.RightPanel.Layout.Column = 3;

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = ecoli_plot_program_exported

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end