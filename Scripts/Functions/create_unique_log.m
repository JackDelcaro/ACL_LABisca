function create_unique_log(path, date_string)

filenames = dir(path);
filenames = string({filenames.name})';
filenames = filenames(contains(filenames, [date_string, 'log']));
filenames = natsort(filenames);

if length(filenames) > 1 && ~any(filenames == string([date_string, 'log.txt']))
    fileout = [date_string, 'log.txt'];
    fileout = fullfile(path, fileout);
    fout = fopen(fileout,'w');

    for cntfiles = 1:length(filenames)
      fin = fopen(filenames(cntfiles));
      worker_id = strsplit(filenames(cntfiles), 'log');
      worker_id = strsplit(worker_id(2), '.txt');
      worker_id = worker_id(1);
      fprintf(fout,'\n\n');
      fprintf(fout,'----------------------------------------\n');
      fprintf(fout,'----------- WORKER NUMBER %s ------------\n', worker_id);
      fprintf(fout,'----------------------------------------\n');
      fprintf(fout,'\n\n');
      while ~feof(fin)
        fprintf(fout,'%s\n',fgetl(fin));
      end
      fclose(fin);
      delete(fullfile(path, filenames(cntfiles)));
    end
    fclose(fout);
end

end