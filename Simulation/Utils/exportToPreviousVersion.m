function result = exportToPreviousVersion(file)
%exportToPreviousVersion - This example uses a Simulink Project custom task
% to attempt export all Simulink model files to a previous version of
% MathWorks tools. 
targetVersion = 'R2019b';
[modelFilepath, modelName, ext] = fileparts(file);
switch ext
    case {'.mdl', '.slx'}        
        % Close all models first -- this code can error if hierarchies of
        % model references are open with unsaved changes, for example. 
        load_system(file);
        info = Simulink.MDLInfo(file);
         
        newName = [modelName '_' targetVersion ext];
        newFile = fullfile(modelFilepath, newName);
        if exist(newFile, 'file')
            error('Remove existing file "%s" and rerun', newFile);
        end
        
        exportedFile = Simulink.exportToVersion(modelName,newFile,targetVersion);
        close_system(modelName, 0);
        
        pause(1); % Just to let the file system catch up
        movefile(file, [file '.' info.ReleaseName], 'f');
        % Could add the old back up file to the project here
        movefile(exportedFile, file, 'f');
        result = sprintf('Created "%s" for use in %s, back up file in "%s"', ...
            file, targetVersion, [file '.' info.ReleaseName]);
    otherwise
        result = [];
end
end

