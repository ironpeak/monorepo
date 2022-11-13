load("@rules_python//python:defs.bzl", rules_python_py_library = "py_library")
load("//custom/python:internal.bzl", "get_srcs", "is_3rdparty", "map_dependency_container", "map_dependency_host")

def py_library(name, srcs, deps, **kwargs):
    rules_python_py_library(
        name = "_" + name + ".container",
        srcs = srcs,
        deps = [map_dependency_container(dep) for dep in deps],
        exec_compatible_with = ["@io_bazel_rules_docker//platforms:run_in_container"],
        tags = ["manual"],
        **kwargs
    )

    rules_python_py_library(
        name = "_" + name + ".srcs",
        srcs = srcs,
        deps = [get_srcs(dep) for dep in deps if not is_3rdparty(dep)],
        tags = ["manual"],
        **kwargs
    )

    rules_python_py_library(
        name = name,
        srcs = srcs,
        deps = [map_dependency_host(dep) for dep in deps],
        **kwargs
    )
