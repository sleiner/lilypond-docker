# lilypond musical typesetting

## why another lilypond image

I needed some more packages to use this image for a gitlab CI runner. It is possible
to use this image to build lilypond files from a gitlab repository fully automated.

## gitlab CI configuration

.gitlab-ci.yml

```
image: iskaron/lilypond

stages:
  - build
  - deploy

lilyfy:
  stage: build
  script:
    - mkdir -p /pdfs
    - 'git diff-tree --no-commit-id --name-only -r "$CI_BUILD_REF" | grep ".ly$" | grep -v setup.ly | xargs -I % find "%" -name \*.ly -execdir lilypond "--output=/pdfs/{}" "{}" \;'

# as it is not possible currently to pass files between stages, we have to rebuild in the deploy stage:
deploy:
  stage: deploy
  script:
    - eval $(ssh-agent -s)
    - echo "$DEPLOY_KEY" | ssh-add -
    - mkdir -p ~/.ssh
    - '[[ -f /.dockerinit ]] && echo -e "Host *\n\tStrictHostKeyChecking no\n\n" > ~/.ssh/config'
    - mkdir -p /pdfs
    - 'git diff-tree --no-commit-id --name-only -r "$CI_BUILD_REF" | grep ".ly$" | grep -v setup.ly | xargs -I % find "%" -name \*.ly -execdir lilypond "--output=/pdfs/{}" "{}" \;'
    - scp -r /pdfs/* $SCP_TARGET_PATH
```

The script will deploy via SSH. The required private key has to be stored in the gitlab CI variable "DEPLOY_KEY", the scp target path in SCP_TARGET_PATH (something
like '<user>@<host>:<path>'.

## standalone usage

```bash
    docker run --rm -v $(pwd):/app -w /app iskaron/lilypond lilypond FILE
```
