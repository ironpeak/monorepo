# monorepo

* Works on 3.10
* Cross-platform (Linux and MacOS)
    * Can run binaries
    * Can build images
    * Can run tests
* Supports seperate and joint requirements

## dependencies

We've a product dependencies that are used by default:

~~~python
# WORKSPACE
pip_import(
    name = "product_container",
    repo_prefix = "product_container",
    requirements = "//product:requirements_lock.txt",
)

load("@product_container//:requirements.bzl", product_container_pip_install = "pip_install")

product_container_pip_install([
    "--platform",
    "linux_x86_64",
    "--only-binary",
    ":all",
])

pip_import(
    name = "product_host",
    compile = True,
    repo_prefix = "product_host",
    requirements = "//product:requirements.in",
)

load("@product_host//:requirements.bzl", product_host_pip_install = "pip_install")

product_host_pip_install([
    "--only-binary",
    ":all",
])
~~~

and for service specific dependencies:

~~~python
# WORKSPACE
pip_import(
    name = "hello_world_custom_container",
    repo_prefix = "hello_world_custom_container",
    requirements = "//product/hello_world_custom:requirements_lock.txt",
)

load("@hello_world_custom_container//:requirements.bzl", hello_world_custom_container_pip_install = "pip_install")

hello_world_custom_container_pip_install([
    "--platform",
    "linux_x86_64",
    "--only-binary",
    ":all",
])

pip_import(
    name = "hello_world_custom_host",
    compile = True,
    repo_prefix = "hello_world_custom_host",
    requirements = "//product/hello_world_custom:requirements.in",
)

load("@hello_world_custom_host//:requirements.bzl", hello_world_custom_host_pip_install = "pip_install")

hello_world_custom_host_pip_install([
    "--only-binary",
    ":all",
])
~~~

In both cases we have 2 `pip_imports`, one for container (`{name}_container`) dependencies that use a `requirements_lock.txt` file and another for host (`{name}_host`) dependencies that use a `requirements.in`.

## py_image

A macro that creates an image target and a binary target.

~~~python
load("//custom/python:image.bzl", "py_image")

py_image(
    name = "hello_world",
    srcs = ["main.py"],
    imports = [
        "..",
    ],
    main = "main.py",
    deps = [
        ":lib",
    ],
)
~~~

* //product/hello_world:hello_world.binary
    * A binary target that uses host dependencies.
* //product/hello_world:hello_world
    * A image target that uses container dependencies.

## py_binary

A macro that creates a binary target.

~~~python
load("//custom/python:binary.bzl", "py_binary")

py_binary(
    name = "hello_world",
    srcs = ["main.py"],
    imports = [
        "..",
    ],
    main = "main.py",
    deps = [
        ":lib",
    ],
)
~~~

* //product/hello_world:hello_world
    * A binary target that uses host dependencies.

## py_test

A macro that creates a test target.

~~~python
load("//custom/python:test.bzl", "py_test")

py_test(
    name = "test",
    srcs = ["test.py"],
    imports = [
        "..",
    ],
    visibility = ["//visibility:public"],
    deps = [
        "pytest",
        ":lib",
    ],
)
~~~

* //product/hello_world:test
    * A test target that uses host dependencies.

## py_library

A macro that creates library targets.

~~~python
load("//custom/python:library.bzl", "py_library")

py_library(
    name = "lib",
    srcs = ["lib.py"],
    imports = [
        "..",
    ],
    deps = [
        "django",
        "grpcio",
        "psycopg2-binary",
        "xxhash",
        "//product/logger",
    ],
)
~~~

* //product/hello_world:lib
    * A library target that uses host dependencies.
* //product/hello_world:_lib.container
    * A library target that uses container dependencies.
* //product/hello_world:_lib.srcs
    * A library target with only source files.

## *_with_requirements

The `_with_requirements` macros setup targets that depend on packages from their own requirements file.
They do that by depending only on `py_library` srcs (no deps). This means that the dependencies must be 
listed at the top level.

Example:

~~~python
py_image_with_requirements(
    name = "hello_world_custom",
    srcs = ["main.py"],
    imports = [
        "..",
    ],
    main = "main.py",
    deps = [
        "django",
        "grpcio",
        "psycopg2-binary",
        "xxhash",
        ":lib",
    ],
)
~~~

~~~bash
$ bazel query 'rdeps(//product/hello_world_custom:hello_world_custom, //...)'
//:python
//precompiled/python/grpcio:grpcio
//precompiled/python/psycopg2_binary:psycopg2_binary
//precompiled/python/xxhash:xxhash
//product/hello_world_custom:_hello_world_custom.container.binary
//product/hello_world_custom:_lib.srcs
//product/hello_world_custom:hello_world_custom
//product/logger:_logger.srcs
~~~

We can see that the target only depends on `py_library` srcs which do not include pypi dependencies.
So we need to declare every dependency in the py_image target as well as include it in custom
requirements file.

### py_image_with_requirements

A macro that creates an image target and a binary target that depends on it's own requirements (`pip_import`).

~~~python
load("//custom/python:image.bzl", "py_image_with_requirements")

py_image_with_requirements(
    name = "hello_world_custom",
    srcs = ["main.py"],
    imports = [
        "..",
    ],
    pip_import = "hello_world_custom",
    main = "main.py",
    deps = [
        "django",
        "grpcio",
        "psycopg2-binary",
        "xxhash",
        ":lib",
    ],
)
~~~

* //product/hello_world_custom:hello_world_custom.binary
    * A binary target that uses host dependencies from it's own requirements file.
* //product/hello_world_custom:hello_world_custom
    * A image target that uses container dependencies from it's own requirements file.

### py_binary_with_requirements

A macro that creates a binary target.

~~~python
load("//custom/python:binary.bzl", "py_binary_with_requirements")

py_binary_with_requirements(
    name = "hello_world",
    srcs = ["main.py"],
    imports = [
        "..",
    ],
    pip_import = "hello_world_custom",
    main = "main.py",
    deps = [
        ":lib",
    ],
)
~~~

* //product/hello_world:hello_world
    * A binary target that uses host dependencies from it's own requirements file.

### py_test_with_requirements

A macro that creates a test target.

~~~python
load("//custom/python:test.bzl", "py_test_with_requirements")

py_test_with_requirements(
    name = "test",
    srcs = ["test.py"],
    imports = [
        "..",
    ],
    pip_import = "hello_world_custom",
    visibility = ["//visibility:public"],
    deps = [
        "django",
        "psycopg2-binary",
        "pytest",
        ":lib",
    ],
)
~~~

* //product/hello_world:test
    * A test target that uses host dependencies from it's own requirements file.
