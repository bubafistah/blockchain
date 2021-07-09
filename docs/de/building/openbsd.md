
You will need to add a few packages to your system. `pkg_add cmake gmake zeromq libiconv boost`.

The `doxygen` and `graphviz` packages are optional and require the xbase set.
Running the test suite also requires `py-requests` package.

Build lethean: `env DEVELOPER_LOCAL_TOOLS=1 BOOST_ROOT=/usr/local gmake release-static`

Note: you may encounter the following error when compiling the latest version of Lethean as a normal user:

```
LLVM ERROR: out of memory
c++: error: unable to execute command: Abort trap (core dumped)
```

Then you need to increase the data ulimit size to 2GB and try again: `ulimit -d 2000000`
