#!/bin/bash
set -e # Exit with nonzero exit code if anything fails

CURRENT_BRANCH="$(git rev-parse --abbrev-ref HEAD)"
SOURCE_BRANCH="multiple_versions_build"
TARGET_BRANCH="gh-pages"
GH_PAGES_ROOT="$PWD/docs/build/html"
WD="$PWD"

REPO=`git config remote.origin.url`
SSH_REPO="${REPO/https:\/\/github.com\//git@github.com:}"


function doCompile {
  pip install -r docs/requirements.txt
  sphinx-versioning build -r write_the_docs docs/source docs/build/html --run-setup-py
}

# Pull requests and commits to other branches shouldn't try to deploy, just build to verify
#if [ "$TRAVIS_PULL_REQUEST" != "false" -o "$TRAVIS_BRANCH" != "$SOURCE_BRANCH" ]; then
if [ "$CURRENT_BRANCH" != "$SOURCE_BRANCH" ]; then
    echo "Skipping deploy; just doing a build."
    doCompile
    exit 0
fi


# Save some useful information

SHA=`git rev-parse --verify HEAD`

# Clone the existing gh-pages for this repo into out/
# Create a new empty branch if gh-pages doesn't exist yet (should only happen on first deply)
echo "CLONE REPO"
rm -rf "$GH_PAGES_ROOT" || exit 0
echo "CLONE REPO $GH_PAGES_ROOT"
git clone "$REPO" "$GH_PAGES_ROOT"
cd "$GH_PAGES_ROOT"
touch .nojekyll
git checkout "$TARGET_BRANCH" || git checkout --orphan "$TARGET_BRANCH"
cd "$WD"

# Clean out existing contents
rm -rf "$GH_PAGES_ROOT"/* || exit 0

# Run our compile script
doCompile

# Now let's go have some fun with the cloned repo
cd "$GH_PAGES_ROOT"
#git config user.name "Travis CI"
#git config user.email "$COMMIT_AUTHOR_EMAIL"

# If there are no changes to the compiled out (e.g. this is a README update) then just bail.
if git diff --quiet; then
    echo "No changes to the output on this push; exiting."
    exit 0
fi

# Commit the "changes", i.e. the new version.
# The delta will show diffs between new and old versions.
git add -A .
git commit -m "Deploy to GitHub Pages: ${SHA}"
#
## Get the deploy key by using Travis's stored variables to decrypt deploy_key.enc
#ENCRYPTED_KEY_VAR="encrypted_${ENCRYPTION_LABEL}_key"
#ENCRYPTED_IV_VAR="encrypted_${ENCRYPTION_LABEL}_iv"
#ENCRYPTED_KEY=${!ENCRYPTED_KEY_VAR}
#ENCRYPTED_IV=${!ENCRYPTED_IV_VAR}
#openssl aes-256-cbc -K $ENCRYPTED_KEY -iv $ENCRYPTED_IV -in ../deploy_key.enc -out ../deploy_key -d
#chmod 600 ../deploy_key
#eval `ssh-agent -s`
#ssh-add deploy_key
#
## Now that we're all set up, we can push.
git push "$SSH_REPO" "$TARGET_BRANCH"