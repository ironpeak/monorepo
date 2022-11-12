bash_entry = """#!/bin/bash

set -euo pipefail

ROOT_DIR="$(pwd)"

find . | grep -v external

exit 0
"""

def _impl(ctx):
    inputs = []

    # srcs
    for src in ctx.attr.srcs:
        for file in src.files.to_list():
            inputs.append(file)

    # deps
    for dep in ctx.attr.deps:
        if PyInfo in dep:
            inputs += dep[PyInfo].transitive_sources.to_list()
        else:
            fail(dep)

    outputs = []
    outputs.append(ctx.actions.declare_directory(ctx.attr.name + "/output"))

    # build entrypoint
    script_name = ctx.actions.declare_file(ctx.attr.name + "/build.sh")
    script_content = bash_entry.format(
        OUTPUT_DIR = "output",
        OUTPUT = outputs[0].path,
    )
    ctx.actions.write(script_name, script_content, is_executable = True)
    inputs.append(script_name)

    ctx.actions.run_shell(
        outputs = outputs,
        inputs = inputs,
        command = script_name.path,
    )

    return [
        DefaultInfo(
            files = depset(outputs),
        ),
    ]

py_build = rule(
    implementation = _impl,
    attrs = {
        "srcs": attr.label_list(mandatory = True, allow_files = True),
        "deps": attr.label_list(mandatory = True, allow_files = False),
    },
)
