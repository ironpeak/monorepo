test:
    bazel run //product/hello_world:hello_world.binary
    bazel run //product/hello_world:hello_world
    bazel run //product/hello_world_custom:hello_world_custom.binary
    bazel run //product/hello_world_custom:hello_world_custom
    bazel test //product/hello_world:test
    bazel test //product/hello_world_custom:test
