profilearray = [];
for frame=11:length(cellList) % cycle through all frames
    for cell=1:length(cellList{frame}) % cycle through all cells on this frame
        if ~isempty(cellList{frame}{cell}) % only consider the cells that exist
            if ~isempty(cellList{frame}{cell}.divisions) && cellList{frame}{cell}.divisions(end)==frame ... % only consider the cells that just divided
                    && ~isempty(cellList{frame}{cell}.descendants) ... % that are not newborn
                    && cellList{frame-1}{cell}.polarity % and that the orientation was known before the division
                profile = zeros(1,51); % create empty array for the intensity profile
                for frame2=frame-10:frame-1 % cycle through 10 previous frames
                    lng = cellList{frame2}{cell}.length; % get cell length on this frame
                    xvector = cellList{frame2}{cell}.lengthvector; % get the coordinates of the segment centers
                    signal = cellList{frame2}{cell}.signal1; % get the current signal profile
                    width = cellList{frame2}{cell}.steparea; % get the current cell width profile
                    cprofile = interp1(xvector,signal./width,0:lng/50:lng,'linear','extrap'); % convert the profile predefined array length
                    profile = profile+cprofile; % add the profile to the sum
                end
                profile = profile/10; % now the profile is the average profile for all frames in the range
                for i=1:3 % smooth the profile with a near-gaussian kernel
                    profile = 0.5*profile+0.25*(profile([1 1:end-1])+profile([2:end end]));
                end
                profilearray = [profilearray;profile]; % add the profile to a list
            end
        end
    end
end