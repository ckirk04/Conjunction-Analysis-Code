%% Courtney Text File Writing
clear; clc; clf; close all;

for iter = 1:1:3 % will eventually go to maybe 50
clearvars -except iter
scriptlistfile = 'scriptlist.txt';

    for numSats = 50:50:150
        listfile = fopen(scriptlistfile, 'w');
        fprintf(listfile, 'LunarOrbits_%d_%d.script\n', numSats,iter);
        fclose(listfile);

        repFileName1 = sprintf("//home//gridsan//ckirkpatrick//LunarOrbits_%d_%d.script", numSats,iter);
        delete(repFileName1)

        listfile = fopen(scriptlistfile,'r');
        name = fscanf(listfile,'%s',[1 inf]);
        fclose(listfile);
         
        textFileHand = name;
        fileID = fopen(textFileHand, 'w');


for ii = 1:1:numSats
    fprintf(fileID,'Create Spacecraft Sat%d;\n', ii);
    fprintf(fileID, 'GMAT Sat%d.DateFormat = UTCGregorian;\n', ii);
    fprintf(fileID, 'GMAT Sat%d.Epoch = ''01 Jan 2023 11:59:28.000'';\n', ii);
    fprintf(fileID, 'GMAT Sat%d.CoordinateSystem = LunaEcliptic;\n', ii);
    fprintf(fileID, 'GMAT Sat%d.DisplayStateType = Keplerian;\n', ii);

    SMA = 1750 + (90)*rand(1); %Random number between 1750 and 1840 (min alt is about 10 km)
    fprintf(fileID, 'GMAT Sat%d.SMA = %d\n', ii, SMA);

    ECC = 0.000001*rand(1); 
    fprintf(fileID, 'GMAT Sat%d.ECC = %d\n', ii, ECC);

    froz = rand(1);
    if froz>0.80
        INC = 86;
    elseif froz>0.65
        INC = 76;
    elseif froz>0.50
        INC = 50;
    elseif froz>0.35
        INC = 27;
    else
         INC = 90*rand(1);
    end
    % INC = 90*rand(1);
    fprintf(fileID, 'GMAT Sat%d.INC = %d\n', ii, INC);

    RAAN = 360*rand(1);
    fprintf(fileID, 'GMAT Sat%d.RAAN = %d\n', ii, RAAN);

    AOP = 360*rand(1);
    fprintf(fileID, 'GMAT Sat%d.AOP = %d\n', ii, AOP);

    TA = 360*rand(1);
    fprintf(fileID, 'GMAT Sat%d.TA = %d\n', ii, TA);

    fprintf(fileID, 'GMAT Sat%d.AttitudeCoordinateSystem = LunaEcliptic;\n\n', ii);
end

fprintf(fileID, 'Create Formation form;\n');
fprintf(fileID, 'GMAT form.Add = {Sat1');
for k = 2:1:numSats
    fprintf(fileID, ', Sat%d', k);
end
fprintf(fileID, '};\n\n');

fprintf(fileID, '%----------------------------------------\n');
fprintf(fileID, '%---------- ForceModels');
fprintf(fileID, '%----------------------------------------\n\n\n\n\n\n');

fprintf(fileID, 'Create ForceModel Luna_ForceModel;\n');
fprintf(fileID, 'GMAT Luna_ForceModel.CentralBody = Luna;\n');
fprintf(fileID, 'GMAT Luna_ForceModel.PrimaryBodies = {Luna};\n');
fprintf(fileID, 'GMAT Luna_ForceModel.PointMasses = {Earth, Mars, Sun, Jupiter};\n');
fprintf(fileID, 'GMAT Luna_ForceModel.Drag = None;\n');
fprintf(fileID, 'GMAT Luna_ForceModel.SRP = On;\n');
fprintf(fileID, 'GMAT Luna_ForceModel.RelativisticCorrection = Off;\n');
fprintf(fileID, 'GMAT Luna_ForceModel.ErrorControl = RSSStep;\n');
fprintf(fileID, 'GMAT Luna_ForceModel.GravityField.Luna.Degree = 70;\n');
fprintf(fileID, 'GMAT Luna_ForceModel.GravityField.Luna.Order = 70;\n');
fprintf(fileID, 'GMAT Luna_ForceModel.GravityField.Luna.StmLimit = 100;\n');
fprintf(fileID, 'GMAT Luna_ForceModel.GravityField.Luna.PotentialFile = ''//home//gridsan//ckirkpatrick//GMAT_2020//GMAT//R2020a//data//gravity//luna//grgm900c.cof'';\n');
fprintf(fileID, 'GMAT Luna_ForceModel.GravityField.Luna.TideFile = ''//home//gridsan//ckirkpatrick//GMAT_2020//GMAT//R2020a//data//gravity//luna//grgm900c.tide'';\n');
fprintf(fileID, 'GMAT Luna_ForceModel.GravityField.Luna.TideModel = ''None'';\n');
fprintf(fileID, 'GMAT Luna_ForceModel.SRP.Flux = 1367;\n');
fprintf(fileID, 'GMAT Luna_ForceModel.SRP.SRPModel = Spherical;\n');
fprintf(fileID, 'GMAT Luna_ForceModel.SRP.Nominal_Sun = 149597870.691;\n\n');

fprintf(fileID, '%----------------------------------------\n');
fprintf(fileID, '%---------- Propagators\n');
fprintf(fileID, '%----------------------------------------\n\n');

fprintf(fileID, 'Create Propagator LunaProp;\n');
fprintf(fileID, 'GMAT LunaProp.FM = Luna_ForceModel;\n');
fprintf(fileID, 'GMAT LunaProp.Type = PrinceDormand78;\n');
fprintf(fileID, 'GMAT LunaProp.InitialStepSize = 60;\n');
fprintf(fileID, 'GMAT LunaProp.Accuracy = 9.999999999999999e-10;\n');
fprintf(fileID, 'GMAT LunaProp.MinStep = 0;\n');
fprintf(fileID, 'GMAT LunaProp.MaxStep = 1800;\n');
fprintf(fileID, 'GMAT LunaProp.MaxStepAttempts = 100;\n');
fprintf(fileID, 'GMAT LunaProp.StopIfAccuracyIsViolated = true;\n\n');

fprintf(fileID, '%----------------------------------------\n');
fprintf(fileID, '%---------- Burns\n');
fprintf(fileID, '%----------------------------------------\n\n');

fprintf(fileID, 'Create ImpulsiveBurn ImpulsiveBurnDIE;\n');
fprintf(fileID, 'GMAT ImpulsiveBurnDIE.CoordinateSystem = Local;\n');
fprintf(fileID, 'GMAT ImpulsiveBurnDIE.Origin = Luna;\n');
fprintf(fileID, 'GMAT ImpulsiveBurnDIE.Element1 = 0;\n');
fprintf(fileID, 'GMAT ImpulsiveBurnDIE.Element2 = 0;\n');
fprintf(fileID, 'GMAT ImpulsiveBurnDIE.Element3 = 10;\n');
fprintf(fileID, 'GMAT ImpulsiveBurnDIE.DecrementMass = false;\n');
fprintf(fileID, 'GMAT ImpulsiveBurnDIE.Isp = 300;\n');
fprintf(fileID, 'GMAT ImpulsiveBurnDIE.GravitationalAccel = 9.81;\n\n');

fprintf(fileID, '%----------------------------------------\n');
fprintf(fileID, '%---------- Coordinate Systems\n');
fprintf(fileID, '%----------------------------------------\n\n');

fprintf(fileID, 'Create CoordinateSystem LunaEcliptic;\n');
fprintf(fileID, 'GMAT LunaEcliptic.Origin = Luna;\n');
fprintf(fileID, 'GMAT LunaEcliptic.Axes = BodyInertial;\n\n');

fprintf(fileID, '%----------------------------------------\n');
fprintf(fileID, '%---------- Outputs\n');
fprintf(fileID, '%----------------------------------------\n\n');

% fprintf(fileID, 'Create OrbitView LunaView;\n');
% fprintf(fileID, 'GMAT LunaView.SolverIterations = Current;\n');
% fprintf(fileID, 'GMAT LunaView.UpperLeft = [ 0.03930131004366812 0 ];\n');
% fprintf(fileID, 'GMAT LunaView.Size = [ 0.8150655021834061 0.9076850984067479 ];\n');
% fprintf(fileID, 'GMAT LunaView.RelativeZOrder = 179;\n');
% fprintf(fileID, 'GMAT LunaView.Maximized = false;\n');
% fprintf(fileID, 'GMAT LunaView.Add = {');
% for q = 1:1:numSats
%     fprintf(fileID, 'Sat%d, ', q);
% end
% fprintf(fileID, 'Earth, Luna};\n');
% fprintf(fileID, 'GMAT LunaView.CoordinateSystem = LunaEcliptic;\n');
% fprintf(fileID, 'GMAT LunaView.DrawObject = [ true true true true ];\n');
% fprintf(fileID, 'GMAT LunaView.DataCollectFrequency = 1;\n');
% fprintf(fileID, 'GMAT LunaView.UpdatePlotFrequency = 50;\n');
% fprintf(fileID, 'GMAT LunaView.NumPointsToRedraw = 0;\n');
% fprintf(fileID, 'GMAT LunaView.ShowPlot = true;\n');
% fprintf(fileID, 'GMAT LunaView.MaxPlotPoints = 50000;\n');
% fprintf(fileID, 'GMAT LunaView.ShowLabels = true;\n');
% fprintf(fileID, 'GMAT LunaView.ViewPointReference = Luna;\n');
% fprintf(fileID, 'GMAT LunaView.ViewPointVector = [ 30000 10000 0 ];\n');
% fprintf(fileID, 'GMAT LunaView.ViewDirection = Luna;\n');
% fprintf(fileID, 'GMAT LunaView.ViewScaleFactor = 1;\n');
% fprintf(fileID, 'GMAT LunaView.ViewUpCoordinateSystem = LunaEcliptic;\n');
% fprintf(fileID, 'GMAT LunaView.ViewUpAxis = Z;\n\n');

foldername = sprintf('%dsats%d', numSats, iter);
system(['mkdir ' foldername])
 
for j = 1:1:numSats
    repFileName = sprintf("//home//gridsan//ckirkpatrick//%dsats%d//Sat%dR.txt", numSats, iter,j);
    delete(repFileName)

    fprintf(fileID,'Create ReportFile ReportFile%d;\n', j);
    fprintf(fileID,'GMAT ReportFile%d.SolverIterations = Current;\n', j);
    fprintf(fileID,'GMAT ReportFile%d.UpperLeft = [ 0.02352941176470588 0.2275 ];\n', j);
    fprintf(fileID,'GMAT ReportFile%d.Size = [ 0.9 0.78875 ];\n', j);
    fprintf(fileID,'GMAT ReportFile%d.RelativeZOrder = 33;\n', j);
    fprintf(fileID,'GMAT ReportFile%d.Maximized = false;\n', j);
    fprintf(fileID,'GMAT ReportFile%d.Filename = ''//home//gridsan//ckirkpatrick//%dsats%d//Sat%dR.txt'';\n', j, numSats, iter,j);
    fprintf(fileID,'GMAT ReportFile%d.Precision = 16;\n', j);
    fprintf(fileID,'GMAT ReportFile%d.Add = {Sat%d.LunaEcliptic.X, Sat%d.LunaEcliptic.Y, Sat%d.LunaEcliptic.Z};\n', j, j, j, j);
    fprintf(fileID,'GMAT ReportFile%d.WriteHeaders = false;\n', j);
    fprintf(fileID,'GMAT ReportFile%d.LeftJustify = On;\n', j);
    fprintf(fileID,'GMAT ReportFile%d.ZeroFill = Off;\n', j);
    fprintf(fileID,'GMAT ReportFile%d.FixedWidth = true;\n', j);
    fprintf(fileID,'GMAT ReportFile%d.Delimiter = '' '';\n', j);
    fprintf(fileID,'GMAT ReportFile%d.ColumnWidth = 23;\n', j);
    fprintf(fileID,'GMAT ReportFile%d.WriteReport = true;\n\n', j);
end

fprintf(fileID, 'BeginMissionSequence;\n');
fprintf(fileID, 'While Sat1.ElapsedDays <= 29.53\n');
fprintf(fileID,	'   Propagate LunaProp(form) {Sat1.ElapsedDays = 0.007};\n');

for m = 1:1:numSats
    fprintf(fileID, '   If Sat%d.Luna.RMAG < 1738\n', m);
	fprintf(fileID, '       Maneuver ImpulsiveBurnDIE(Sat%d);\n', m);
    fprintf(fileID, '   EndIf;\n');
end

fprintf(fileID, 'EndWhile;');

fclose(fileID);
%system('cd ..');
command = sprintf('%d %d', numSats, iter);
system(['sbatch iter_rungmat.sh ' command])
    end
end