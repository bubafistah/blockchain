The project can be built from scratch by following instructions for Linux above(but use `gmake` instead of `make`).
If you are running Lethean in a jail, you need to add `sysvsem="new"` to your jail configuration, otherwise lmdb will throw the error message: `Failed to open lmdb environment: Function not implemented`.
