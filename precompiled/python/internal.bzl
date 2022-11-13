precompiled = {
    "grpcio": "//precompiled/python/grpcio",
    "psycopg2-binary": "//precompiled/python/psycopg2_binary",
    "xxhash": "//precompiled/python/xxhash",
}

def is_precompiled(dependency):
    return dependency in precompiled

def map_dependency_precompiled(dependency):
    return precompiled[dependency]
