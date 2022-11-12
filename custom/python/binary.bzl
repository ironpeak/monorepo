load("@rules_python//python:defs.bzl", rules_python_py_binary = "py_binary")
load("//custom/python:internal.bzl", "map_dependency_host", "map_dependency_with_requirements")

def py_binary(name, deps, **kwargs):
    rules_python_py_binary(
        name = name,
        deps = [map_dependency_host(dep) for dep in deps],
        **kwargs
    )

def py_binary_with_requirements(name, deps, **kwargs):
    rules_python_py_binary(
        name = name,
        deps = [map_dependency_with_requirements(dep) for dep in deps],
        **kwargs
    )
