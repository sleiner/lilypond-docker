#!/bin/sh

mkdir -p pdfs

FILES=`git diff-tree --no-commit-id --name-only -r "$CI_BUILD_REF" | grep ".ly$" | grep -v setup.ly | wc -l`

if [ $FILES -eq 0 ]; then
	echo No lilypond file changed, rebuilding all files
	find . -name \*.ly ! -name setup.ly -execdir lilypond "--output=`pwd`/pdfs/{}" "{}" \;
else
	echo Building changed files.
	git diff-tree --no-commit-id --name-only -r "$CI_BUILD_REF" | grep ".ly$" | grep -v setup.ly | xargs -I % find "%" -name \*.ly -execdir lilypond "--output=`pwd`/pdfs/{}" "{}" \;
fi

