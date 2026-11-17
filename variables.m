%% RFPS-AI Dataset - Configuration
% MATLAB R2023b
% Keysight ADS 2023 Update 2
%
% Configuration parameters for automated generation
% and electromagnetic simulation of pixelated RF structures.
%
% Update the local paths before running the scripts.

%% 1. Directory configuration

% Windows directory separator
aux_slash='\';

% ADS workspace directory
% Replace this path with your local ADS workspace.
wrk_name_path = sprintf('C:%sADS%sAEL_layout_wrk%s', ...
    aux_slash, aux_slash, aux_slash);

% ADS library and layout cell names
lib_name  = 'AEL_layout_lib';
cell_name = 'square_layout';

%% 2. Geometry configuration

% Number of structures generated per batch
number_layouts = 10000;

% Binary matrix dimensions (without port connections)
array_size = 16;

% Nominal pixel width in micrometers
ancho = 950;

%% 3. Frequency sweep configuration

% Frequency range in GHz
start_freq = 0.1;
end_freq   = 3;

% Number of frequency points
steps_number = 100;

% Frequency step in GHz
step_freq = (end_freq - start_freq) / (steps_number - 1);

%% 4. ADS environment configuration

% ADS installation directory
ruta_program = sprintf('C:%sProgram Files%sKeysight%sADS2023_Update2', ...
    aux_slash, aux_slash, aux_slash);

% ADS license configuration
% Replace with your local license file path or server.
ruta_license = 'YOUR_ADS_LICENSE_CONFIGURATION';

% Windows environment PATH
ruta_path = 'PATH=%HPEESOF_DIR%\bin;%PATH%';

%% 5. Simulation directories and output files

% ADS electromagnetic simulation directories
em_setup    = '\em%Setup';
emSetup_MoM = 'emSetup_MoM';

% Intermediate simulation results
data_file = 'ParametrosS_matrices.txt';

%% 6. Simulation template parameters

% Original frequency settings in the ADS template
old_freq     = 6;
old_step     = 0.1;
old_end_freq = 15.9;

% Frequency parameter used in the simulation setup
half_freq = (end_freq - start_freq) / 2;
