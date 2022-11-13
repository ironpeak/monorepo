load("@rules_python//python:defs.bzl", rules_python_py_binary = "py_binary")
load("//custom/python:internal.bzl", "map_dependency_host", "map_dependency_with_requirements_host")

def py_binary(name, deps, **kwargs):
    rules_python_py_binary(
        name = name,
        deps = [map_dependency_host(dep) for dep in deps],
        **kwargs
    )

def py_binary_with_requirements(name, deps, pip_import = None, **kwargs):
    if pip_import == None:
        pip_import = name

    rules_python_py_binary(
        name = name,
        deps = [map_dependency_with_requirements_host(pip_import, dep) for dep in deps],
        **kwargs
    )
