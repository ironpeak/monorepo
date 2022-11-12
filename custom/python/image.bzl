load("//custom/python:internal.bzl", "map_dependency_container", "map_dependency_with_requirements")
load("//custom/python:binary.bzl", "py_binary")
load("//custom/python:build.bzl", "py_build")
load("@rules_python//python:defs.bzl", rules_python_py_binary = "py_binary")
load("@io_bazel_rules_docker//container:container.bzl", "container_image")

def py_image(name, deps, **kwargs):
    py_binary(
        name = name + ".binary",
        deps = deps,
        **kwargs
    )

    _py3_image(
        name = name,
        deps = [map_dependency_container(dep) for dep in deps],
        base = "//:python",
        **kwargs
    )

def py_image_with_requirements(name, host_deps, container_deps, **kwargs):
    py_binary(
        name = name + ".binary",
        deps = [map_dependency_with_requirements(dep) for dep in host_deps],
        **kwargs
    )

    _py3_image(
        name = name,
        deps = [map_dependency_with_requirements(dep) for dep in container_deps],
        base = "//:python",
        **kwargs
    )

def _py3_image(name, base = None, deps = [], srcs = [], main = "main.py", **kwargs):
    """Constructs a container image wrapping a py_binary target.

  Args:
    name: Name of the py3_image rule target.
    base: Base image to use for the py3_image.
    deps: Dependencies of the py3_image.
    **kwargs: See py_binary.
  """
    binary_name = name + ".binary.tar"

    py_build(
        name = binary_name,
        deps = deps,
        srcs = srcs,
    )

    container_image(
        name = name,
        base = base,
        directory = "/app",
        files = [
            ":" + binary_name,
        ],
        visibility = ["//visibility:public"],
        workdir = "/app",
    )
