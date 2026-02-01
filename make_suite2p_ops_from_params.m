function [ops, written] = make_suite2p_ops_from_params(p)
% make_suite2p_ops_from_params
% Build Suite2p ops struct from an input parameter struct and write to disk.
%
% Usage:
%   p = struct();
%   p.outDir = "C:\data\session1\suite2p_cfg";
%   p.data_path = {"C:\data\session1\tiffs"};   % or p.tiff_list = {...}
%   p.fs = 30; p.nplanes = 1; p.nchannels = 1; p.functional_chan = 1;
%   [ops, written] = make_suite2p_ops_from_params(p);
%
% Inputs:
%   p (struct) - parameter struct; see defaults below. You can supply any subset.
%
% Outputs:
%   ops (struct) - Suite2p ops struct (MATLAB representation)
%   written (struct) - paths actually written:
%       written.npy (string or "")
%       written.mat (string or "")
%       written.json (string or "")
%       written.py_converter (string or "")
%
% Notes:
%   Suite2p expects ops.npy to contain a length-1 numpy object array whose element is a dict.
%   This function writes ops.npy if MATLAB Python is available; else it writes ops.mat + converter.

    arguments
        p (1,1) struct
    end

    written = struct('npy',"", 'mat',"", 'json',"", 'py_converter',"");

    % ---- Defaults (override by fields present in p) ----
    d = defaultParams();

    % Merge: p overrides d
    p = mergeStructs(d, p);

    % Basic validation
    if ~isfield(p, 'outDir') || isempty(p.outDir)
        error("Parameter struct must include p.outDir (output directory).");
    end
    outDir = char(string(p.outDir));
    if ~isfolder(outDir)
        mkdir(outDir);
    end

    % Data input validation: data_path or tiff_list
    hasDataPath = isfield(p,'data_path') && ~isempty(p.data_path);
    hasTiffList = isfield(p,'tiff_list') && ~isempty(p.tiff_list);

    if ~(hasDataPath || hasTiffList)
        error("Provide either p.data_path (cellstr) or p.tiff_list (cellstr).");
    end

    % ---- Build ops struct ----
    ops = struct();

    % Input/output paths
    ops.save_path0 = outDir;
    if hasDataPath
        ops.data_path = ensureCellStr(p.data_path);
        ops.tiff_list = {};
    else
        ops.data_path = {};
        ops.tiff_list = ensureCellStr(p.tiff_list);
    end

    % Acquisition
    ops.nplanes         = p.nplanes;
    ops.nchannels       = p.nchannels;
    ops.functional_chan = p.functional_chan;
    ops.fs              = p.fs;

    ops.do_bidiphase    = logical(p.do_bidiphase);
    ops.bidiphase       = p.bidiphase;

    ops.nimg_init       = p.nimg_init;
    ops.batch_size      = p.batch_size;

    % Registration
    ops.do_registration   = logical(p.do_registration);
    ops.nonrigid          = logical(p.nonrigid);
    ops.smooth_sigma      = p.smooth_sigma;
    ops.smooth_sigma_time = p.smooth_sigma_time;
    ops.maxregshift       = p.maxregshift;
    ops.align_by_chan     = p.align_by_chan;
    ops.th_badframes      = p.th_badframes;

    if ops.nonrigid
        ops.block_size      = p.block_size;
        ops.snr_thresh      = p.snr_thresh;
        ops.maxregshiftNR   = p.maxregshiftNR;
    else
        ops.block_size      = p.block_size;     % keep default even if unused
        ops.snr_thresh      = p.snr_thresh;
        ops.maxregshiftNR   = p.maxregshiftNR;
    end

    % ROI detection
    ops.do_detection      = logical(p.do_detection);
    ops.sparse_mode       = logical(p.sparse_mode);
    ops.diameter          = p.diameter;
    ops.spatial_scale     = p.spatial_scale;
    ops.threshold_scaling = p.threshold_scaling;
    ops.max_overlap       = p.max_overlap;
    ops.high_pass         = p.high_pass;

    % Neuropil/deconv
    ops.neuropil_extract        = logical(p.neuropil_extract);
    ops.inner_neuropil_radius   = p.inner_neuropil_radius;
    ops.min_neuropil_pixels     = p.min_neuropil_pixels;

    ops.baseline     = char(string(p.baseline));
    ops.win_baseline = p.win_baseline;
    ops.sig_baseline = p.sig_baseline;

    ops.spikedetect  = logical(p.spikedetect);
    ops.neucoeff     = p.neucoeff;

    % Output options
    ops.save_mat       = logical(p.save_mat);
    ops.delete_bin     = logical(p.delete_bin);
    ops.keep_movie_raw = logical(p.keep_movie_raw);

    % Common/compat fields (harmless if unused)
    ops.chan2_thres   = p.chan2_thres;
    ops.roidetect     = ops.do_detection;
    ops.reg_tif       = logical(p.reg_tif);
    ops.allow_overlap = logical(p.allow_overlap);

    % ---- Write outputs ----
    % 1) ops.npy if possible, else fallback
    npyPath = fullfile(outDir, "ops.npy");
    [didWriteNPY, msg] = tryWriteOpsNPY(npyPath, ops);

    if didWriteNPY
        written.npy = string(npyPath);
    else
        % fallback: ops.mat + converter
        matPath = fullfile(outDir, "ops.mat");
        save(matPath, "ops", "-v7.3");
        written.mat = string(matPath);

        pyPath = fullfile(outDir, "convert_ops_mat_to_npy.py");
        writeConverterPython(pyPath);
        written.py_converter = string(pyPath);

        warning("Could not write ops.npy directly. Reason: %s\nWrote ops.mat + converter script instead:\n  %s\n  %s", ...
            msg, matPath, pyPath);
    end

    % 2) optional JSON
    if p.write_json
        jsonPath = fullfile(outDir, "ops.json");
        fid = fopen(jsonPath, "w");
        if fid < 0
            error("Could not open file for writing: %s", jsonPath);
        end
        fprintf(fid, "%s", jsonencode(ops, "PrettyPrint", true));
        fclose(fid);
        written.json = string(jsonPath);
    end
end

% ========================= Defaults =========================

function d = defaultParams()
    d = struct();

    % Required-ish
    d.outDir = "";          % user must set
    d.data_path = {};       % user must set OR provide tiff_list
    d.tiff_list = {};

    % Acquisition
    d.nplanes = 1;
    d.nchannels = 1;
    d.functional_chan = 1;
    d.fs = 30;

    d.do_bidiphase = true;
    d.bidiphase = 0;

    d.nimg_init = 300;
    d.batch_size = 200;

    % Registration
    d.do_registration = true;
    d.nonrigid = true;
    d.smooth_sigma = 1.15;
    d.smooth_sigma_time = 0;
    d.maxregshift = 0.1;
    d.align_by_chan = 1;
    d.th_badframes = 1.0;

    d.block_size = [128 128];   % [X Y]
    d.snr_thresh = 1.2;
    d.maxregshiftNR = 5;

    % ROI detection
    d.do_detection = true;
    d.sparse_mode = false;
    d.diameter = 12;
    d.spatial_scale = 0;
    d.threshold_scaling = 1.0;
    d.max_overlap = 0.75;
    d.high_pass = 100;

    % Neuropil/deconv
    d.neuropil_extract = true;
    d.inner_neuropil_radius = 2;
    d.min_neuropil_pixels = 350;

    d.baseline = "maximin";
    d.win_baseline = 60;
    d.sig_baseline = 10;

    d.spikedetect = true;
    d.neucoeff = 0.7;

    % Outputs
    d.save_mat = true;
    d.delete_bin = false;
    d.keep_movie_raw = false;

    d.write_json = true;

    % Compatibility extras
    d.chan2_thres = 0.65;
    d.reg_tif = false;
    d.allow_overlap = true;
end

% ========================= Utilities =========================

function s = mergeStructs(a, b)
% mergeStructs: fields in b override fields in a
    s = a;
    fb = fieldnames(b);
    for i = 1:numel(fb)
        s.(fb{i}) = b.(fb{i});
    end
end

function c = ensureCellStr(x)
    if isstring(x)
        x = cellstr(x);
    elseif ischar(x)
        x = {x};
    elseif iscell(x)
        % ok
    else
        error("Expected cellstr/string/char for paths.");
    end
    c = x;
end

function [ok, msg] = tryWriteOpsNPY(npyPath, ops)
% Try to write ops.npy using MATLAB's Python interface (pyenv + numpy).
% Returns ok=false with msg on failure.

    ok = false;
    msg = "";

    try
        pe = pyenv;
        if pe.Status ~= "Loaded"
            msg = "MATLAB Python (pyenv) not loaded.";
            return;
        end
    catch ME
        msg = "pyenv unavailable: " + string(ME.message);
        return;
    end

    try
        opsPy = matlabStructToPyDict(ops);

        np = py.importlib.import_module('numpy');

        % Avoid np.empty(...) because MATLAB may choke on empty py objects.
        lst = py.list();
        lst.append(opsPy);

        arr = np.array(lst, pyargs('dtype', 'object'));   % shape (1,), dtype=object

        np.save(char(npyPath), arr, pyargs('allow_pickle', true));
        ok = true;

    catch ME
        msg = string(ME.message);
        ok = false;
    end
end

function d = matlabStructToPyDict(s)
    keys = fieldnames(s);
    d = py.dict();
    for i = 1:numel(keys)
        k = keys{i};
        v = s.(k);
        d{k} = matlabValueToPy(v);
    end
end

function pv = matlabValueToPy(v)
    if ischar(v) || (isstring(v) && isscalar(v))
        pv = py.str(char(string(v)));
    elseif islogical(v) && isscalar(v)
        pv = py.bool(v);
    elseif isnumeric(v) && isscalar(v)
        pv = py.float(double(v)); % Suite2p fine with floats
    elseif isnumeric(v)
        np = py.importlib.import_module('numpy');
        pv = np.array(v);
    elseif iscell(v)
        L = py.list();
        for i = 1:numel(v)
            L.append(matlabValueToPy(v{i}));
        end
        pv = L;
    elseif isstruct(v) && isscalar(v)
        pv = matlabStructToPyDict(v);
    else
        pv = py.str(char(string(v)));
    end
end
function writeConverterPython(pyPath)

    lines = { ...
        'import argparse'
        'import numpy as np'
        'import scipy.io'
        ''
        'def main():'
        '    ap = argparse.ArgumentParser()'
        '    ap.add_argument("--mat", required=True)'
        '    ap.add_argument("--out", required=True)'
        '    args = ap.parse_args()'
        ''
        '    mat = scipy.io.loadmat(args.mat, squeeze_me=True, struct_as_record=False)'
        '    ops = mat["ops"]'
        ''
        '    d = {}'
        '    for name in ops._fieldnames:'
        '        val = getattr(ops, name)'
        '        if isinstance(val, np.ndarray) and val.shape == ():'
        '            val = val.item()'
        '        d[name] = val'
        ''
        '    arr = np.empty(1, dtype=object)'
        '    arr[0] = d'
        '    np.save(args.out, arr, allow_pickle=True)'
        '    print(f"Wrote {args.out}")'
        ''
        'if __name__ == "__main__":'
        '    main()'
    };

    fid = fopen(pyPath, "w");
    if fid < 0
        error("Could not open file for writing: %s", pyPath);
    end

    for i = 1:numel(lines)
        fprintf(fid, "%s\n", lines{i});
    end

    fclose(fid);
end
