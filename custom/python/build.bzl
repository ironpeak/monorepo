bash_entry = """#!/bin/bash

set -euo pipefail

ls \
    | grep -v bazel-out \
    | xargs -I @ cp -rL @ {OUTPUT}

pythonpath="$(find bazel-out | grep '/pythonpath.sh')"
cp -L ${{pythonpath}} {OUTPUT}/pythonpath.sh

main="$(find bazel-out | grep '/main.sh')"
cp -L ${{main}} {OUTPUT}/main.sh

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

    # pythonpath
    pythonpath_file = ctx.actions.declare_file(ctx.attr.name + "/pythonpath.sh")
    ctx.actions.expand_template(
        template = ctx.attr._pythonpath.files.to_list()[0],
        output = pythonpath_file,
        substitutions = {
            "{IMPORTS}": "\n".join(ctx.attr.imports),
        },
    )
    inputs.append(pythonpath_file)

    # main.sh
    main = str(ctx.label).replace("//", "./").split(":")[0] + "/" + ctx.attr.main
    main_file = ctx.actions.declare_file(ctx.attr.name + "/main.sh")
    ctx.actions.expand_template(
        template = ctx.attr._main.files.to_list()[0],
        output = main_file,
        substitutions = {
            "{MAIN}": main,
        },
    )
    inputs.append(main_file)

    outputs = []
    outputs.append(ctx.actions.declare_directory(ctx.attr.name + "/" + ctx.attr.output))

    # build entrypoint
    script_name = ctx.actions.declare_file(ctx.attr.name + "/build.sh")
    script_content = bash_entry.format(
        MAIN = inputs[-1].path,
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
        "main": attr.string(mandatory = True),
        "imports": attr.string_list(mandatory = True),
        "output": attr.string(mandatory = True),
        "_pythonpath": attr.label(
            default = ":pythonpath.sh",
            allow_files = True,
        ),
        "_main": attr.label(
            default = ":main.sh",
            allow_files = True,
        ),
    },
)
