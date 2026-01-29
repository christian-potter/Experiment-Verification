function masks = digit_masks(maskSize, thickness)
% digitMaskCellArray_0to9  Create a 1x10 cell array of 2D binary masks (0–9).
%
% masks{d+1} is a mask (logical, maskSize x maskSize) that draws digit d.
% Digits are rendered using a 7-segment style inside a 50x50 (default) box.
%
% Inputs (optional)
%   maskSize  - scalar, output size (default 50)
%   thickness - scalar, segment thickness in pixels (default 5)
%
% Output
%   masks - 1x10 cell array, each cell is maskSize x maskSize logical
%
% Example:
%   masks = digitMaskCellArray_0to9();
%   figure; montage(cat(3, masks{:})); title('0-9 masks');

if nargin < 1 || isempty(maskSize),  maskSize  = 50; end
if nargin < 2 || isempty(thickness), thickness = 5;  end

% Safety/clamping
maskSize  = round(maskSize);
thickness = max(1, round(thickness));

masks = cell(1, 10);

% Define a drawing "inset" so digits don't touch borders.
pad = max(2, ceil(0.10 * maskSize));  % ~10% padding
xL  = pad + 1;
xR  = maskSize - pad;
yT  = pad + 1;
yB  = maskSize - pad;

% Segment placement (7-segment): a (top), b (upper-right), c (lower-right),
% d (bottom), e (lower-left), f (upper-left), g (middle).
midY = round((yT + yB) / 2);

% Horizontal segments y-ranges
aY = [yT, min(yT + thickness - 1, maskSize)];
gY = [max(midY - floor(thickness/2), 1), min(midY - floor(thickness/2) + thickness - 1, maskSize)];
dY = [max(yB - thickness + 1, 1), yB];

% Vertical segment x-ranges
fX = [xL, min(xL + thickness - 1, maskSize)];
bX = [max(xR - thickness + 1, 1), xR];
eX = fX;
cX = bX;

% Vertical segments y-ranges (split at middle)
fY = [yT, max(midY - 1, yT)];
bY = fY;
eY = [min(midY + 1, yB), yB];
cY = eY;

% Helper to draw a filled rectangle (inclusive indices)
rect = @(H, W, y1,y2,x1,x2) drawRect(H, W, y1,y2,x1,x2);

% Segment bitmasks (logical)
H = maskSize; W = maskSize;
seg = struct();
seg.a = rect(H,W, aY(1),aY(2), xL,xR);
seg.g = rect(H,W, gY(1),gY(2), xL,xR);
seg.d = rect(H,W, dY(1),dY(2), xL,xR);

seg.f = rect(H,W, fY(1),fY(2), fX(1),fX(2));
seg.b = rect(H,W, bY(1),bY(2), bX(1),bX(2));
seg.e = rect(H,W, eY(1),eY(2), eX(1),eX(2));
seg.c = rect(H,W, cY(1),cY(2), cX(1),cX(2));

% Segment sets for each digit (standard 7-seg)
% Order: [a b c d e f g]
digitSegs = { ...
    [1 1 1 1 1 1 0], ... % 0
    [0 1 1 0 0 0 0], ... % 1
    [1 1 0 1 1 0 1], ... % 2
    [1 1 1 1 0 0 1], ... % 3
    [0 1 1 0 0 1 1], ... % 4
    [1 0 1 1 0 1 1], ... % 5
    [1 0 1 1 1 1 1], ... % 6
    [1 1 1 0 0 0 0], ... % 7
    [1 1 1 1 1 1 1], ... % 8
    [1 1 1 1 0 1 1]  ... % 9
    };

segNames = {'a','b','c','d','e','f','g'};

for d = 0:9
    m = false(H, W);
    flags = digitSegs{d+1};
    for k = 1:numel(flags)
        if flags(k)
            m = m | seg.(segNames{k});
        end
    end
    masks{d+1} = m;
end

end

function m = drawRect(H, W, y1, y2, x1, x2)
% drawRect Create a logical mask with a filled axis-aligned rectangle.
y1 = max(1, min(H, round(y1)));
y2 = max(1, min(H, round(y2)));
x1 = max(1, min(W, round(x1)));
x2 = max(1, min(W, round(x2)));
if y2 < y1, tmp = y1; y1 = y2; y2 = tmp; end
if x2 < x1, tmp = x1; x1 = x2; x2 = tmp; end
m = false(H, W);
m(y1:y2, x1:x2) = true;
end
