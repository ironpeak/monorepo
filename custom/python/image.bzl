load("//custom/python:internal.bzl", "map_dependency_container", "map_dependency_with_requirements")
load("//custom/python:binary.bzl", "py_binary")
load(
    "@io_bazel_rules_docker//lang:image.bzl",
    "app_layer",
)
load("@rules_python//python:defs.bzl", rules_python_py_binary = "py_binary")

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

def _py3_image(name, base = None, deps = [], layers = [], env = {}, **kwargs):
    """Constructs a container image wrapping a py_binary target.

  Args:
    name: Name of the py3_image rule target.
    base: Base image to use for the py3_image.
    deps: Dependencies of the py3_image.
    layers: Augments "deps" with dependencies that should be put into
           their own layers.
    env: Environment variables for the py_image.
    **kwargs: See py_binary.
  """
    binary_name = "_" + name + ".container.binary"

    if "main" not in kwargs:
        kwargs["main"] = name + ".py"

    # TODO(mattmoor): Consider using par_binary instead, so that
    # a single target can be used for all three.

    rules_python_py_binary(
        name = binary_name,
        python_version = "PY3",
        deps = deps + layers,
        exec_compatible_with = ["@io_bazel_rules_docker//platforms:run_in_container"],
        tags = ["manual"],
        **kwargs
    )

    # TODO(mattmoor): Consider making the directory into which the app
    # is placed configurable.
    base = base or select({
        "@io_bazel_rules_docker//:debug": "@py3_debug_image_base//image",
        "@io_bazel_rules_docker//:fastbuild": "@py3_image_base//image",
        "@io_bazel_rules_docker//:optimized": "@py3_image_base//image",
        "//conditions:default": "@py3_image_base//image",
    })
    tags = kwargs.get("tags", None)
    for index, dep in enumerate(layers):
        base = app_layer(name = "%s.%d" % (name, index), base = base, dep = dep, tags = tags)
        base = app_layer(name = "%s.%d-symlinks" % (name, index), base = base, dep = dep, binary = binary_name, tags = tags)

    visibility = kwargs.get("visibility", None)
    app_layer(
        name = name,
        base = base,
        entrypoint = ["/usr/bin/python"],
        env = env,
        binary = binary_name,
        visibility = visibility,
        tags = tags,
        args = kwargs.get("args"),
        data = kwargs.get("data"),
        testonly = kwargs.get("testonly"),
        # The targets of the symlinks in the symlink layers are relative to the
        # workspace directory under the app directory. Thus, create an empty
        # workspace directory to ensure the symlinks are valid. See
        # https://github.com/bazelbuild/rules_docker/issues/161 for details.
        create_empty_workspace_dir = True,
    )
