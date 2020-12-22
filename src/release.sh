#!/bin/bash

# 1. get the current branch and project name
# 2. checkout current branch
# 3. develop branch validation
# 4. release version validation
# 5. get package version
# 5. pull the latest code from develop
# 6. create empty commit from develop
# 7. create tag for new version from develop
# 8. push commit to remote origin
# 9. push tag to remote origin
# 10. create the release branch from the develop branch
# 11. push local release branch to remote
# 12. merge develop branch
# 13. push commit release branch to remote origin

blue='\033[0;34m'
red='\033[0;31m'
purple='\033[0;35m'
reset='\033[0m'

# current Git branch
branch=$(git symbolic-ref HEAD | sed -e 's,.*/\(.*\),\1,')

# current project name
projectName=$(git config --local remote.origin.url|sed -n 's#.*/\([^.]*\)\.git#\1#p')

# establish develop branch name and develop variables
developBranch=$branch

# checkout to develop branch, this will break if the user has uncommited changes
git checkout $developBranch

# master branch validation
if [ $branch = "develop" ]; then

	packageVersion=$(cat package.json \
		| grep version \
		| head -1 \
		| awk -F: '{ print $2 }' \
		| sed 's/[",]//g' \
		| tr -d '[:space:]')

	printf "\n${purple}Release version $packageVersion${reset}\n\n"

	# 1.0.0, 1.0.1, 1.1.0, etc
	versionLabel=$packageVersion

	# establish branch and tag name variables
	releaseBranch="release/$packageVersion"
	tagName="open-release-v$packageVersion"

	printf "\n${blue}Started releasing $packageVersion for $projectName -->${reset}\n\n"

	# pull the latest version of the code from develop and create empty commit from develop branch
	printf "\n${blue}git pull && git commit --allow-empty -m${reset}\n\n"
	git pull && git commit --allow-empty -m "Creating branch $releaseBranch"

	# create tag for new version from develop and push commit to remote origin
	printf "\n${blue}git tag $tagName && git push${reset}\n\n"
	git tag $tagName && git push

	# push tag to remote origin
	printf "\ngit push --tags origin\n\n"
	git push --tags origin 
	
	# create the release branch from the develop branch
	printf "\n${blue}git checkout -b $releaseBranch $developBranch${reset}\n\n"

	git checkout -b $releaseBranch $developBranch

	# merge develop branch
	printf "\n${blue}git merge $developBranch${reset}\n\n"		
	git merge $developBranch

	# push local releaseBranch to remote
	git push -u origin $releaseBranch

	printf "\n${purple}$packageVersion is successfully created for $projectName!${reset}\n\n"

else 

	printf "${red}Please make sure you are on develop branch!${reset}\n"

fi