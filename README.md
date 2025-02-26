# Common Dotfiles for different needs
Dotfiles (Configuration files) for git, vscode, etc...

## Activate pre-commit hooks

We use pre-commit hooks to validate commits to the github repository.
To configure/set-up hooks we use the `.pre-commit-config.yaml` file. For example "check yaml" hook to ensure yaml files are correctly formatted before they are committed.

Following is the one time setup process to activate the pre-commit hook. But must be executed again if we add or modify validations in future.

- Install pre-commit if not already installed (requires python installed):

```
pip3 install pre-commit
```

- Install the git hook scripts:

```
pre-commit install
```

- If the above command fails try:

```
python -m pre_commit install
```

- Verification: On successful execution we should be able to see the file named `pre-commit` created in the path `.git\hooks` (The folder is usually hidden by default).

### Talisman installation pre-commit hook

- On Windows:

```
winget install --id Thoughtworks.talisman
```

- On Linux:

```
Look at ./run_talisman.sh to comprehend the install steps and install talisman as a git hook for this local repository by running the script.

```

If you want to learn more about talisman, please have a look at the official github page:
https://github.com/thoughtworks/talisman