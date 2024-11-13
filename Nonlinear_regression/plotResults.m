function f = plotResults(simresults,data)

f = figure(Name="Sim vs Data",Color='w'); 
f.Position(3:4) = [930 379];

colors = colororder;
tl = tiledlayout(f, 1,2);
ax1 = nexttile(tl);
ax2 = nexttile(tl);

hold(ax1,"on"); grid(ax1,"on");
hold(ax2,"on"); grid(ax2,"on");

doses = unique(data.doseGroup,"rows","stable");

PKVarname = "plasmadrug_ugml";
PDVarname = "protein_mgl";

simresultsPD = selectbyname(simresults,PDVarname);
simresultsPK = selectbyname(simresults,PKVarname);

lines = gobjects(numel(simresults),1);

for jz = 1:numel(simresults)

    time_daysPK = simresultsPK(jz).Time;
    time_daysPD = simresultsPD(jz).Time;
    protein = simresultsPD(jz).Data;
    drug = simresultsPK(jz).Data;

    plot(ax2, time_daysPK, protein,...
        LineWidth=2, Color=colors(jz,:),...
        DisplayName=num2str(doses(jz)));

    plot(ax2, data.time_hr(data.doseGroup==doses(jz),:)/24,...
        data.(PDVarname)(data.doseGroup==doses(jz),:),...
        Marker='o', MarkerSize=6, Color=colors(jz,:),...
        LineStyle='none', DisplayName='');

    plot(ax1, time_daysPD, drug,...
        LineWidth=2, Color=colors(jz,:),...
        DisplayName=num2str(doses(jz)));

    lines(jz) = plot(ax1, data.time_hr(data.doseGroup==doses(jz),:)/24,...
        data.(PKVarname)(data.doseGroup==doses(jz),:),...
        Marker='o', MarkerSize=6, Color=colors(jz,:),...
        LineStyle='none', DisplayName=num2str(doses(jz)));

end

% annotations
xlim(ax1,[-0.1, 1.1]);
xlabel(tl,'time (days)'); 
ylabel(ax2,'Protein (relative to baseline)');
ylabel(ax1,'Plasma drug conc (\mug/mL)');
lgd = legend(ax2,lines);
lgd.Title.String = 'Dose in mg';
lgd.Location = "layout";
lgd.Layout.Tile = "east"; 
lgd.Box = "off";

% apply figure properties
set([ax1,ax2],'linewidth',1.5,'box','on',...
    'XLimitMethod','padded','YLimitMethod','padded') % apply properties to all axes objects
