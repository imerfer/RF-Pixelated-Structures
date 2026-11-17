
%% RFPS-AI Dataset - Automated Layout Generation
% MATLAB R2023b
% Keysight ADS 2023 Update 2
%
% Generates random pixelated RF geometries, creates an AEL script
% for ADS layout generation, and prepares EM simulation files.
%
% Required files:
%   variables.m
%   emSetup/emStateFile.xml and associated setup files

%% 1. Load configuration

clear;
variables;

rowArray = array_size + 2;
colArray = array_size + 2;

% Store the original binary matrices
array = cell(number_layouts, 1);

% Output AEL file
ael_file = fullfile(wrk_name_path, ...
    sprintf('AEL_%d_layouts.ael', number_layouts));

fid = fopen(ael_file, 'w');

if fid == -1
    error('Unable to create AEL file: %s', ael_file);
end

fprintf(fid, '// RFPS-AI - Automated Layout Generation\r\n');
fprintf(fid, 'decl lib = "%s";\r\n', lib_name);

%% 2. Generate geometries and layouts

for i = 1:number_layouts

    %% 2.1 Generate random binary geometry

    % Original 16 x 16 binary matrix
    random_array = round(rand(array_size));

    % Random positions of the four ports
    pos1 = randi([1, array_size]);
    pos2 = randi([1, array_size]);
    pos3 = randi([2, array_size + 1]);
    pos4 = randi([2, array_size + 1]);

    % Add left and right boundary columns
    random_array = [zeros(array_size, 1), random_array];
    random_array(pos1, 1) = 1;

    random_array = [random_array, zeros(array_size, 1)];
    random_array(pos2, end) = 1;

    % Add top and bottom boundary rows
    random_array = [zeros(1, colArray); random_array];
    random_array(1, pos3) = 1;

    random_array = [random_array; zeros(1, colArray)];
    random_array(end, pos4) = 1;

    % Store the complete 18 x 18 binary matrix
    array{i} = random_array;

    %% 2.2 Define layout name

    number = sprintf('%04d', i);
    layout_name = sprintf('%s%s', cell_name, number);

    %% 2.3 Create ADS layout

    fprintf(fid, '\r\n// Layout: %s\r\n', layout_name);

    fprintf(fid, 'decl cell = "%s";\r\n', layout_name);

    fprintf(fid, ...
        'decl context = db_oa_create_empty_design(lib, cell, "layout", 2);\r\n');

    fprintf(fid, 'de_show_context_in_new_window(context);\r\n');

    % Select conductive drawing layer
    fprintf(fid, ...
        'decl cond_layerId = db_find_layerid_by_name(context, "cond:drawing");\r\n');

    fprintf(fid, ...
        'db_select_all_on_layerid(context, cond_layerId, TRUE);\r\n');

    %% 2.4 Draw metallic pixels

    % Each metallic pixel is extended by 12.5% on every side,
    % producing a 25% overlap between adjacent pixels.

    for j = 1:rowArray
        for k = 1:colArray

            if random_array(j, k) == 1

                posicionx_i = ancho * (k - 1) - 0.125 * ancho;
                posicionx_f = ancho * k + 0.125 * ancho;

                posiciony_i = -ancho * (j - 1) + 0.125 * ancho;
                posiciony_f = -ancho * j - 0.125 * ancho;

                fprintf(fid, ...
                    'db_add_rectangle(context, cond_layerId, %d, %d, %d, %d);\r\n', ...
                    posicionx_i, posiciony_i, posicionx_f, posiciony_f);

            end
        end
    end

    %% 2.5 Define electrical ports

    % Port 1: left boundary (180 degrees)
    % Port 2: right boundary (0 degrees)

    for j = 2:(rowArray - 1)

        if random_array(j, 1) == 1

            posicionx = -0.125 * ancho;
            posiciony = -ancho * (j - 1) ...
                + 0.125 * ancho - ancho * 1.25 / 2;

            fprintf(fid, ...
                'db_create_pin(context, %d, %d, 180, cond_layerId, 1);\r\n', ...
                posicionx, posiciony);
        end

        if random_array(j, colArray) == 1

            posicionx = ancho * colArray + 0.125 * ancho;
            posiciony = -ancho * (j - 1) ...
                + 0.125 * ancho - ancho * 1.25 / 2;

            fprintf(fid, ...
                'db_create_pin(context, %d, %d, 0, cond_layerId, 2);\r\n', ...
                posicionx, posiciony);
        end
    end

    % Port 3: top boundary (90 degrees)
    % Port 4: bottom boundary (270 degrees)

    for k = 2:(colArray - 1)

        if random_array(1, k) == 1

            posicionx = ancho * (k - 1) ...
                - 0.125 * ancho + ancho * 1.25 / 2;

            posiciony = 0.125 * ancho;

            fprintf(fid, ...
                'db_create_pin(context, %d, %d, 90, cond_layerId, 3);\r\n', ...
                posicionx, posiciony);
        end

        if random_array(rowArray, k) == 1

            posicionx = ancho * (k - 1) ...
                - 0.125 * ancho + ancho * 1.25 / 2;

            posiciony = -ancho * colArray - 0.125 * ancho;

            fprintf(fid, ...
                'db_create_pin(context, %d, %d, 270, cond_layerId, 4);\r\n', ...
                posicionx, posiciony);
        end
    end

    %% 3. Prepare electromagnetic simulation setup

    % Create layout-specific EM setup directory
    layout_folder = fullfile(wrk_name_path, ...
        [lib_name aux_slash layout_name]);

    em_setup_folder = [layout_folder em_setup];

    if ~exist(em_setup_folder, 'dir')
        mkdir(em_setup_folder);
    end

    % Copy predefined ADS simulation configuration
    copyfile(fullfile('emSetup', '*.*'), em_setup_folder);

    %% 3.1 Update simulation configuration

    xml_file = fullfile(em_setup_folder, 'emStateFile.xml');

    fid2 = fopen(xml_file, 'r');

    if fid2 == -1
        error('Unable to open simulation setup: %s', xml_file);
    end

    file_content = fread(fid2, '*char')';
    fclose(fid2);

    % Replace template layout name
    file_content = strrep(file_content, ...
        'square_layout0001', layout_name);

    %% 3.2 Update frequency sweep

    next_new_freq = start_freq;

    for l = old_freq:old_step:old_end_freq

        new2 = sprintf('<startFreq>%.3f</s', next_new_freq);

        if abs(l - round(l)) < eps
            old2 = sprintf('<startFreq>%d</s', l);
        else
            old2 = sprintf('<startFreq>%.1f</s', l);
        end

        file_content = strrep(file_content, old2, new2);

        next_new_freq = next_new_freq + step_freq;
    end

    % Update refinement frequency settings
    file_content = strrep(file_content, ...
        '<MaxRefineFrequency>4.950000e+00 GHz', ...
        sprintf('<MaxRefineFrequency>%d GHz', half_freq));

    file_content = strrep(file_content, ...
        '<MaxRefineFrequency>15.9 GHz', ...
        sprintf('<MaxRefineFrequency>%d GHz', end_freq));

    % Update frequency range description
    file_content = strrep(file_content, ...
        '6 GHz to 15.9 GHz', ...
        sprintf('%d GHz to %d GHz', start_freq, end_freq));

    % Save updated XML file
    fid2 = fopen(xml_file, 'w');

    if fid2 == -1
        error('Unable to write simulation setup: %s', xml_file);
    end

    fprintf(fid2, '%s', file_content);
    fclose(fid2);

    %% 4. Generate ADS Momentum simulation files

    simulation_folder = fullfile(wrk_name_path, ...
        'simulation', lib_name, layout_name, 'layout');

    emSetup_MoM_folder = ...
        [simulation_folder aux_slash emSetup_MoM];

    if ~exist(emSetup_MoM_folder, 'dir')
        mkdir(emSetup_MoM_folder);
    end

    fprintf(fid, ...
        'dex_em_writeSimulationFiles(context, "%s");\r\n', ...
        emSetup_MoM_folder);

    %% 5. Save and close layout

    fprintf(fid, '\r\n// Save and close layout\r\n');

    fprintf(fid, 'context = NULL;\r\n');

    fprintf(fid, ...
        'de_save_oa_design(strcat(lib, ":", cell, ":layout"));\r\n');

    fprintf(fid, 'api_set_current_window_by_seq_num(1);\r\n');
    fprintf(fid, 'de_close_window();\r\n');

end

%% 6. Save generated geometry matrices

save('array.mat', 'array');

% Close AEL file
fclose(fid);

fprintf('Generated %d pixelated RF layouts.\n', number_layouts);
fprintf('AEL script saved to: %s\n', ael_file);
fprintf('Geometry matrices saved to array.mat\n');
