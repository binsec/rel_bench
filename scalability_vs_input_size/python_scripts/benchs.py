#!/usr/bin/env python3
from pathlib import PurePosixPath

DEFAULT_EXEC_DIR="./"

# Informations for a single executable file
class Executable(object):
    def __init__(self, exec_file, directory,
                 entrypoint="main", high_syms="",
                 memory_file="memory.txt"):
        self.exec_file = exec_file
        self.directory = directory
        self.entrypoint = entrypoint
        self.high_syms = high_syms
        self.memory_file = memory_file

    def get_exec_file(self):
        return PurePosixPath(self.directory).joinpath(self.exec_file)

    def get_entrypoint(self):
        return self.entrypoint

    def get_high_syms(self):
        return self.high_syms

    def get_memory_file(self):
        return PurePosixPath(self.directory).joinpath(self.memory_file)


# Build bench from executables
class BenchsFromExecutables(object):
    def __init__(self, executables):
        self.executables = executables

    def get_executables(self):
        return self.executables

# Benchs with multiple executable starting from main
class BenchsMultiExec(object):
    def __init__(self, exec_files, directory=DEFAULT_EXEC_DIR,
                 entrypoint="main", high_syms="",
                 memory_file="memory.txt"):
        self.executables = []
        for exec_file in exec_files:
            executable = Executable(exec_file, directory, entrypoint,
                                    high_syms, memory_file)
            self.executables.append(executable)

    def get_executables(self):
        return self.executables


def get_executable_names_with_size(names, sizes):
    result = []
    for name in names:
        for size in sizes:
            result.append(name + "_" + str(size))
    return result
