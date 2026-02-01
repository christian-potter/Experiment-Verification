import argparse
import numpy as np
import scipy.io

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--mat", required=True)
    ap.add_argument("--out", required=True)
    args = ap.parse_args()

    mat = scipy.io.loadmat(args.mat, squeeze_me=True, struct_as_record=False)
    ops = mat["ops"]

    d = {}
    for name in ops._fieldnames:
        val = getattr(ops, name)
        if isinstance(val, np.ndarray) and val.shape == ():
            val = val.item()
        d[name] = val

    arr = np.empty(1, dtype=object)
    arr[0] = d
    np.save(args.out, arr, allow_pickle=True)
    print(f"Wrote {args.out}")

if __name__ == "__main__":
    main()
