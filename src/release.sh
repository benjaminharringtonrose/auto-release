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

blueText='\033[0;34m'
redText='\033[0;31m'
purpleText='\033[0;35m'
noColor='\033[0m'

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

	

	printf "\nRelease version $packageVersion\n\n"

	# 1.0.0, 1.0.1, 1.1.0, etc
	versionLabel=$packageVersion

	# establish branch and tag name variables
	releaseBranch="release/$packageVersion"
	tagName="open-release-v$packageVersion"

	printf "\n${blueText}Started releasing $packageVersion for $projectName -->\n\n"

	# pull the latest version of the code from develop and create empty commit from develop branch
	printf "\ngit pull && git commit --allow-empty -m\n\n"
	git pull && git commit --allow-empty -m "Creating branch $releaseBranch"

	# create tag for new version from develop and push commit to remote origin
	printf "\ngit tag $tagName && git push\n\n"
	git tag $tagName && git push

	# push tag to remote origin
	printf "\ngit push --tags origin\n\n"
	git push --tags origin 
	
	# create the release branch from the develop branch
	printf "\ngit checkout -b $releaseBranch $developBranch\n\n"

	git checkout -b $releaseBranch $developBranch

	# merge develop branch
	printf "\ngit merge $developBranch\n\n${noColor}"		
	git merge $developBranch

	# push local releaseBranch to remote
	git push -u origin $releaseBranch

	printf "\n${purpleText}$packageVersion is successfully created for $projectName!\n\n${noColor}"

else 

	printf "${redText}Please make sure you are on develop branch!\n${noColor}"

fi