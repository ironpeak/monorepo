imports="{IMPORTS}"

packages=$(ls external | xargs -I {} echo "$(pwd)/external/{}")

export PYTHONPATH=$(printf "${packages}\n${imports}" | tr '\n' ':')
