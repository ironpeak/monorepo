load("//precompiled/python:internal.bzl", "is_precompiled", "map_dependency_precompiled")

def map_dependency_container(dependency):
    if is_3rdparty(dependency):
        if is_precompiled(dependency):
            return map_dependency_precompiled(dependency)
        return "@product_container//:" + dependency
    return _fullname(dependency).replace(":", ":_") + ".container"

def map_dependency_host(dependency):
    if is_3rdparty(dependency):
        return "@product_host//:" + dependency
    return dependency

def map_dependency_with_requirements_container(pip_import, dependency):
    if is_3rdparty(dependency):
        if is_precompiled(dependency):
            return map_dependency_precompiled(dependency)
        return "@{}_container//:{}".format(pip_import, dependency)
    return get_srcs(dependency)

def map_dependency_with_requirements_host(pip_import, dependency):
    if is_3rdparty(dependency):
        return "@{}_host//:{}".format(pip_import, dependency)
    return get_srcs(dependency)

def get_srcs(dependency):
    return _fullname(dependency).replace(":", ":_") + ".srcs"

def is_3rdparty(dependency):
    return dependency[0] not in [":", "/"]

def _fullname(dependency):
    if ":" in dependency:
        return dependency
    return dependency + ":" + dependency.split("/")[-1]
