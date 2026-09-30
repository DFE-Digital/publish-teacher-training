#!/usr/bin/env python3

import gzip
import shutil
import sys
from pathlib import Path


def wrap_restore(source_path: Path, target_path: Path) -> None:
    with gzip.open(source_path, "rb") as source, gzip.open(target_path, "wb") as target:
        target.write(b"\\set ON_ERROR_STOP on\nBEGIN;\n")
        shutil.copyfileobj(source, target)
        target.write(b"\nCOMMIT;\n")


if __name__ == "__main__":
    if len(sys.argv) != 3:
        raise SystemExit(f"Usage: {sys.argv[0]} SOURCE.sql.gz TARGET.sql.gz")

    wrap_restore(Path(sys.argv[1]), Path(sys.argv[2]))
