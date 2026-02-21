function generate_suite2p_ops_matlab(varargin)
%GENERATE_SUITE2P_OPS_MATLAB  Create Suite2p ops.npy (and ops.json) from MATLAB.
%
% This function uses MATLAB's Python interface to call suite2p.default_ops(),
% updates a few acquisition/path fields, then saves:
%   - ops.npy  (Suite2p-consumable)
%   - ops.json (human-readable)
%
% REQUIREMENTS
% 1) MATLAB must be configured to use a Python environment where suite2p is installed.
%    In MATLAB: pyenv  (check) / pyenv('Version', '/path/to/python')
% 2) Python packages: suite2p, numpy
%
% USAGE (minimal)
%   generate_suite2p_ops_matlab( ...
%       'data_path',   "/abs/path/to/session_folder", ...
%       'save_path0',  "/abs/path/to/output_parent", ...
%       'fs',          30.0, ...
%       'nplanes',     1, ...
%       'nchannels',   1, ...
%       'functional_chan', 1, ...
%       'tau',         1.0, ...
%       'out_ops_npy', "ops.npy", ...
%       'out_ops_json',"ops.json");
%
% OPTIONAL: also write db.npy (often used with CLI)
%   generate_suite2p_ops_matlab(..., 'write_db', true, 'out_db_npy', "db.npy");

% -----------------------------
% Parse inputs
% -----------------------------
p = inputParser;
p.addParameter('data_path', "", @(x) isstring(x) || ischar(x));
p.addParameter('save_path0', "", @(x) isstring(x) || ischar(x));
p.addParameter('fs', [], @(x) isempty(x) || isnumeric(x));
p.addParameter('nplanes', [], @(x) isempty(x) || isnumeric(x));
p.addParameter('nchannels', [], @(x) isempty(x) || isnumeric(x));
p.addParameter('functional_chan', [], @(x) isempty(x) || isnumeric(x));
p.addParameter('tau', [], @(x) isempty(x) || isnumeric(x));

p.addParameter('extra_ops', struct(), @(x) isstruct(x)); % arbitrary overrides

p.addParameter('out_ops_npy', "ops.npy", @(x) isstring(x) || ischar(x));
p.addParameter('out_ops_json', "ops.json", @(x) isstring(x) || ischar(x));

p.addParameter('write_db', false, @(x) islogical(x) || isnumeric(x));
p.addParameter('out_db_npy', "db.npy", @(x) isstring(x) || ischar(x));
p.addParameter('fast_disk', "", @(x) isstring(x) || ischar(x)); % optional db field

p.parse(varargin{:});
S = p.Results;

% -----------------------------
% Validate Python environment
% -----------------------------
pe = pyenv;
if pe.Status ~= "Loaded"
    % This loads the default Python (or configured one). You can also set it explicitly:
    % pyenv('Version', '/ABS/PATH/TO/python');
    pyenv;
end

% Make sure required Python modules exist
must_import("numpy");
must_import("suite2p");

np = py.importlib.import_module("numpy");
s2p = py.importlib.import_module("suite2p");

% -----------------------------
% Create default ops (full keyset for your suite2p version)
% -----------------------------
ops = s2p.default_ops();   % Python dict-like

% -----------------------------
% Apply user-specified core fields
% -----------------------------
if strlength(string(S.data_path)) > 0
    % Suite2p expects list of paths for data_path
    ops{"data_path"} = py.list({char(string(S.data_path))});
end
if strlength(string(S.save_path0)) > 0
    ops{"save_path0"} = char(string(S.save_path0));
end
if ~isempty(S.fs),              ops{"fs"} = py.float(S.fs); end
if ~isempty(S.nplanes),         ops{"nplanes"} = py.int(S.nplanes); end
if ~isempty(S.nchannels),       ops{"nchannels"} = py.int(S.nchannels); end
if ~isempty(S.functional_chan), ops{"functional_chan"} = py.int(S.functional_chan); end
if ~isempty(S.tau),             ops{"tau"} = py.float(S.tau); end

% -----------------------------
% Apply arbitrary overrides from MATLAB struct: extra_ops
% -----------------------------
if ~isempty(fieldnames(S.extra_ops))
    extraPy = matlabStructToPyDict(S.extra_ops);
    keys = py.list(extraPy.keys());
    for i = 1:int64(keys.len__())
        k = keys{i-1};
        ops{k} = extraPy{k};
    end
end

% -----------------------------
% Save ops.npy
% -----------------------------
outOpsNpy = char(string(S.out_ops_npy));
np.save(outOpsNpy, ops);
fprintf("Wrote %s\n", outOpsNpy);

% -----------------------------
% Save ops.json (human-readable)
% -----------------------------
% Convert numpy scalars/arrays to JSON-safe Python types
json = py.importlib.import_module("json");
builtins = py.importlib.import_module("builtins");

to_jsonable = py.eval([ ...
"lambda x: (" ...
"  x.item() if hasattr(x,'item') else " ...
"  x.tolist() if hasattr(x,'tolist') else " ...
"  {k: (v.item() if hasattr(v,'item') else v.tolist() if hasattr(v,'tolist') else v) for k,v in x.items()} if hasattr(x,'items') else " ...
"  [ (y.item() if hasattr(y,'item') else y.tolist() if hasattr(y,'tolist') else y) for y in x ] if isinstance(x, (list,tuple)) else " ...
"  x" ...
")"], py.dict);

ops_jsonable = to_jsonable(ops);
outOpsJson = char(string(S.out_ops_json));
fid = fopen(outOpsJson, 'w');
if fid < 0, error("Could not open %s for writing.", outOpsJson); end
cleanup = onCleanup(@() fclose(fid));

% json.dumps returns a Python str; write as char
jsonText = json.dumps(ops_jsonable, pyargs("indent", int32(2), "sort_keys", true));
fwrite(fid, char(jsonText), 'char');
fprintf("Wrote %s\n", outOpsJson);

% -----------------------------
% Optionally also write db.npy (commonly used with CLI)
% -----------------------------
if logical(S.write_db)
    db = py.dict;

    if strlength(string(S.data_path)) > 0
        db{"data_path"} = py.list({char(string(S.data_path))});
    end
    if strlength(string(S.save_path0)) > 0
        db{"save_path0"} = char(string(S.save_path0));
    end
    if strlength(string(S.fast_disk)) > 0
        db{"fast_disk"} = char(string(S.fast_disk));
    end

    outDbNpy = char(string(S.out_db_npy));
    np.save(outDbNpy, db);
    fprintf("Wrote %s\n", outDbNpy);
end

end

% ===== Helpers =====

function must_import(modname)
try
    py.importlib.import_module(modname);
catch ME
    error("Python module '%s' not importable from MATLAB. Fix pyenv / install packages.\nOriginal error:\n%s", ...
        modname, string(ME.message));
end
end

function d = matlabStructToPyDict(s)
% Recursively convert MATLAB struct -> Python dict with JSON/numpy-friendly leaves.
d = py.dict;
fn = fieldnames(s);
for i = 1:numel(fn)
    k = fn{i};
    v = s.(k);
    d{char(k)} = matlabToPy(v);
end
end

function vpy = matlabToPy(v)
% Convert MATLAB types to Python types suitable for ops dict values.
if isstring(v) || ischar(v)
    vpy = char(string(v));
elseif isnumeric(v) && isscalar(v)
    % keep ints as int when obvious, else float
    if isinteger(v) || (abs(v - round(v)) < 1e-12 && abs(v) < 2^31)
        vpy = py.int(int64(round(v)));
    else
        vpy = py.float(double(v));
    end
elseif islogical(v) && isscalar(v)
    vpy = py.bool(v);
elseif iscell(v)
    vpy = py.list;
    for i = 1:numel(v)
        vpy.append(matlabToPy(v{i}));
    end
elseif isnumeric(v) && ~isscalar(v)
    % array -> numpy array
    np = py.importlib.import_module("numpy");
    vpy = np.array(v);
elseif isstruct(v)
    vpy = matlabStructToPyDict(v);
else
    % fallback: string representation
    vpy = char(string(v));
end
end
