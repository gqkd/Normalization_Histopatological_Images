function [storage]=batchmode(file2)
d = uigetdir(pwd, 'Select a folder');
filesjpg = dir(fullfile(d, '*.jpg'));
filestif = dir(fullfile(d, '*.tif'));
%filesjpg = dir(fullfile(d, '*.jpeg'));
tmp=struct2cell(filesjpg); storagejpg=tmp(1:2,:)';
tmp=struct2cell(filestif); storagetif=tmp(1:2,:)';
prestorage=[storagejpg;storagetif];
for i=1:length(prestorage)
    prestorage{i,2}=horzcat(prestorage{i,2},'\');
    if strcmp(prestorage{i,1},file2)
        targetindex=i;
    end
end
storage=[prestorage(1:targetindex-1,:);prestorage(targetindex+1:end,:)];
% for i=1:size(storage,1)
% storage{i,3}=imread([storage{i,2},storage{i,1}]);
% end

