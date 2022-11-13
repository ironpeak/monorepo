load("@rules_python//python:defs.bzl", rules_python_py_test = "py_test")
load("//custom/python:internal.bzl", "map_dependency_host", "map_dependency_with_requirements_host")

def py_test(name, deps, **kwargs):
    rules_python_py_test(
        name = name,
        deps = [map_dependency_host(dep) for dep in deps],
        **kwargs
    )

def py_test_with_requirements(name, deps, **kwargs):
    rules_python_py_test(
        name = name,
        deps = [map_dependency_with_requirements_host(dep) for dep in deps],
        **kwargs
    )
