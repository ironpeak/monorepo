load("@rules_python//python:defs.bzl", rules_python_py_library = "py_library")
load("//custom/python:internal.bzl", "map_dependency_container", "map_dependency_host")

def py_library(name, deps, **kwargs):
    rules_python_py_library(
        name = name + ".container",
        deps = [map_dependency_container(dep) for dep in deps],
        exec_compatible_with = ["@io_bazel_rules_docker//platforms:run_in_container"],
        **kwargs
    )

    rules_python_py_library(
        name = name,
        deps = [map_dependency_host(dep) for dep in deps],
        **kwargs
    )
