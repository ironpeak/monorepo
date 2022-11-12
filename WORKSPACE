load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

# Golang

http_archive(
    name = "io_bazel_rules_go",
    sha256 = "099a9fb96a376ccbbb7d291ed4ecbdfd42f6bc822ab77ae6f1b5cb9e914e94fa",
    urls = [
        "https://mirror.bazel.build/github.com/bazelbuild/rules_go/releases/download/v0.35.0/rules_go-v0.35.0.zip",
        "https://github.com/bazelbuild/rules_go/releases/download/v0.35.0/rules_go-v0.35.0.zip",
    ],
)

load("@io_bazel_rules_go//go:deps.bzl", "go_register_toolchains", "go_rules_dependencies")

go_rules_dependencies()

go_register_toolchains(version = "1.19.1")

http_archive(
    name = "bazel_gazelle",
    sha256 = "448e37e0dbf61d6fa8f00aaa12d191745e14f07c31cabfa731f0c8e8a4f41b97",
    urls = [
        "https://mirror.bazel.build/github.com/bazelbuild/bazel-gazelle/releases/download/v0.28.0/bazel-gazelle-v0.28.0.tar.gz",
        "https://github.com/bazelbuild/bazel-gazelle/releases/download/v0.28.0/bazel-gazelle-v0.28.0.tar.gz",
    ],
)

load("@bazel_gazelle//:deps.bzl", "gazelle_dependencies")

gazelle_dependencies()

# Python
http_archive(
    name = "rules_python",
    sha256 = "8c8fe44ef0a9afc256d1e75ad5f448bb59b81aba149b8958f02f7b3a98f5d9b4",
    strip_prefix = "rules_python-0.13.0",
    url = "https://github.com/bazelbuild/rules_python/archive/refs/tags/0.13.0.tar.gz",
)

load("@rules_python//python:repositories.bzl", "python_register_toolchains")

python_register_toolchains(
    name = "python",
    python_version = "3.10",
)

load("@python//:defs.bzl", "interpreter")

http_archive(
    name = "com_github_ali5h_rules_pip",
    sha256 = "619f337ff54cdcaf090ea2f849ef631f48ea08369374543d747183cf2c45157c",
    strip_prefix = "rules_pip-c3ae659ac0d0967b5f4cc4c8272f36fca9c5b620",
    urls = ["https://github.com/ironpeak/rules_pip/archive/c3ae659ac0d0967b5f4cc4c8272f36fca9c5b620.tar.gz"],
)

load("@com_github_ali5h_rules_pip//:defs.bzl", "pip_import")

# product

pip_import(
    name = "product_container",
    python_runtime = interpreter,
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
    python_runtime = interpreter,
    requirements = "//product:requirements.in",
)

load("@product_host//:requirements.bzl", product_host_pip_install = "pip_install")

product_host_pip_install([
    "--only-binary",
    ":all",
])

## hello-world-custom

# pip_parse(
#     name = "hello_world_custom_container",
#     python_interpreter_target = interpreter,
#     requirements_lock = "//product/hello-world-custom:requirements_linux_lock.txt",
# )

# load("@hello_world_custom_container//:requirements.bzl", hello_world_custom_container_install_deps = "install_deps")

# hello_world_custom_container_install_deps()

# pip_parse(
#     name = "hello_world_custom_host",
#     python_interpreter_target = interpreter,
#     requirements_darwin = "//product/hello-world-custom:requirements_linux_lock.txt",
#     requirements_linux = "//product/hello-world-custom:requirements_darwin_lock.txt",
# )

# load("@hello_world_custom_host//:requirements.bzl", hello_world_custom_host_install_deps = "install_deps")

# hello_world_custom_host_install_deps()

# Docker
http_archive(
    name = "io_bazel_rules_docker",
    sha256 = "b1e80761a8a8243d03ebca8845e9cc1ba6c82ce7c5179ce2b295cd36f7e394bf",
    urls = ["https://github.com/bazelbuild/rules_docker/releases/download/v0.25.0/rules_docker-v0.25.0.tar.gz"],
)

load(
    "@io_bazel_rules_docker//repositories:repositories.bzl",
    container_repositories = "repositories",
)

container_repositories()

load("@io_bazel_rules_docker//repositories:deps.bzl", container_deps = "deps")

container_deps()

load(
    "@io_bazel_rules_docker//python3:image.bzl",
    _py3_image_repos = "repositories",
)

_py3_image_repos()

load(
    "@io_bazel_rules_docker//container:pull.bzl",
    "container_pull",
)

container_pull(
    name = "python_image",
    architecture = "amd64",
    digest = "sha256:eef39ed128b235c95c723eabe2de05670ba87f3273cc784effe4c3d9d0847c09",
    registry = "docker.io",
    repository = "python",
)
